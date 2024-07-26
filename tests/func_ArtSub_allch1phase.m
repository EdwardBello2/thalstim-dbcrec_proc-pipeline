function func_ArtSub_allch1phase(p)
% Test Script for reading in all TDT and Intan data for Phase3 of the
% experiment, performs DBS artifact removal to fully pre-process, then save
% First draft based largly on "testArtSub_1ch1phase.m"

%%
% tic
% test script for removing artifacts from an entire block of recordings

% clear; 
% 
% % example multi-platform data for phase 3
% rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
% sessionpn = '20240122\';
% acqDatapn = [rootpn 'data-acquisition\' sessionpn];
% procDatapn = [rootpn 'data-processing\' sessionpn];
% 
% TDTtankpn = 'DCNrs_pB-231206-112317\';
% % TDTtankpn = 'DCNrs_pA-231205-154908\';
% 
% TDTblock = 'Zebel-240122-120155';
% % TDTblock = 'Zebel-240122-122431';
% 
% RHDfolderpn = 'ThalDbsCxRec01_240122_120200\';
% RHDfileFirst = 'ThalDbsCxRec01_240122_120200';
% % RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% % RHDfileFirst = 'ThalDbsCxRec01_240122_122436';
% 
% acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
% procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
% 
% TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...
% 
% addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));
% 
% % medianFullPath = [rootpn 'data-processing\' sessionFolder '\' RHDfolder '\'];
% 
% 
sessionTab = table(); % initialize a table object to track all processed files that will be created from amplifier data


%% Read in each rhd file one at a time and get a median common mode of all good channels saved 
% save in parsed format in data processing
disp('Getting common mode of all channels...')
tic

% read in parsedMatfilesMetadata table
tab = readtable([p.acqDatapn p.RHDfolderpn 'parsedMatfiles\parsedMatfilesMetadata.xlsx']);

% Generate median channel common mode data and save as parsed mat files
% acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
% procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
medTab = proc_genCMparsed(tab, p.acqParsedPn, p.procParsedPn);

% writetable(medTab, [procParsedPn 'medianCommonModeMetadata.xlsx']);

sessionTab = [sessionTab; medTab];


toc

%% Load several concatenated single channels of data to be used in processing
disp('Loading digital in 2, amplifier timestamps, common mode of all channels...')
tic
tab = readtable([p.acqParsedPn 'parsedMatfilesMetadata.xlsx']);

% Construct the fully concatenated data for DIGITAL-IN-02
chanLabelSelect = 'DIGITAL-IN-01';
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
subTab = tab((idxChanLabel),:);
dig1 = concatParsed_sg(subTab, p.acqParsedPn);

% Construct the fully concatenated data for DIGITAL-IN-02
chanLabelSelect = 'DIGITAL-IN-02';
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
subTab = tab((idxChanLabel),:);
dig2 = concatParsed_sg(subTab, p.acqParsedPn);

% Construct the fully concatenated data for timestamps of the amplifier
% data
dataType = 't_amplifier';
idxDataType= strcmp(tab.dataType, dataType);
subTabTst = tab((idxDataType),:);
tst = concatParsed_sg(subTabTst, p.acqParsedPn);

% Construct the fully concatenated data for the common mode signal
% medTab = readtable([procParsedPn 'medianCommonModeMetadata.xlsx']);
medCM = concatParsed_sg(medTab, p.procParsedPn);
toc

% remove all data points that pertain to negative time in timeseries
idxNegTst = tst < 0;
dig1(idxNegTst) = [];
dig2(idxNegTst) = [];
medCM(idxNegTst) = [];
tstCorr = tst;
tstCorr(idxNegTst) = [];



%% read in TDT-related info, extract DBS event times
disp('Loading TDT-based DBS event times, re-referencing to Intan-time...')

tic
blk = TDTbin2mat([p.acqDatapn p.TDTtankpn p.TDTblock], 'TYPE', [2]);
[dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(blk, p.TDTsynapseProgram);
dbsInfo = join(dbsPulseInfo, dbsStimInfo);

nPulses = height(dbsPulseInfo);
ts_pulse_TDT = dbsPulseInfo.ts_pulse;
% ts_pulse_Intan = zeros(nPulses,1);
% samp_pulse_Intan = zeros(nPulses,1);

% First find the timestamp values in Intan closest to the TDT time values

% % ---------OLD WAY-------------
% ts_pulse_Intan = interp1(tst,tst,ts_pulse_TDT,'nearest');
% %------------------------------

% ---------NEW WAY-------------
% dbsInfo = genTable_dbsIntan(dig2,30000,dbsStimInfo,dbsPulseInfo);
% Re-do TDT stim event times by regressing their times to Intan time using
% sync pulses.. regression handles both the offset and the different time
% scaling between teh two systems!
% Detect the onset times of dbs epocs in Intant time using digital line 2
risingEdgeIdx = find(diff(dig2) == 1) + 1;
IntanSyncTimes = tstCorr(risingEdgeIdx);
TdtSyncTimes = blk.epocs.Pu1_.onset;

[~,b] = makeCorrection(IntanSyncTimes, TdtSyncTimes, false);

dbsInfo.ts_pulseIntan = applyCorrection(dbsInfo.ts_pulse, b);

% ts_pulse_Intan = dbsInfo.ts_pulseIntan;
% negTimeSampOffset = sum(tstCorr < 0);
% dbsInfo.samp_pulseIntan = round(dbsInfo.ts_pulseIntan*30000) + negTimeSampOffset;
dbsInfo.samp_pulseIntan = round(dbsInfo.ts_pulseIntan*30000);

%------------------------------

% Next get the sample index of each Intan dbs timestamp value
% samp_pulse_Intan = round(ts_pulse_Intan * 30000);
samp_pulseIntan = dbsInfo.samp_pulseIntan;

% Final step, write the table for DBS pulse timing info
writetable(dbsInfo, [p.procDatapn p.RHDfolderpn 'dbsInfo.xlsx']);

toc


%% One channel at a time, concatenate, artifact subtract, then de-concatenate & save
disp('Artifact-subtracting one concatenated channel at a time, then de-contatenated & saving the parsed files...')

tic
offset = 0; % number of samples & direction (+/1) to offset TDT-based dbs event detection in Intan data
fs = 30000; % samples/sec, of Intan data
fcL = 300; % Hz, lower-bound of bandpass filter
fcH = 10000; % Hz, upper-bound of bandpass filter

tabAmp = tab(strcmp(tab.dataType, 'amplifier_data'),:);
chanLabels = unique(tabAmp.chanLabel);
nChans = length(chanLabels);

% for one channel:
for iChan = 1:nChans
    chLab = chanLabels{iChan};
    
    % Read in a concatenated amp channels raw data 
    tabChan = tabAmp(strcmp(tabAmp.chanLabel, chLab),:);
    [amp_iChan, concatIdx] = concatParsed_sg(tabChan, p.acqParsedPn);
    
    % Remove data points pertaining to negative time
    amp_iChan(idxNegTst) = [];
    concatIdx = concatIdx - sum(idxNegTst); % Also update the concat index to reflect the loss of some data points pertaining to negative time
    concatIdx(1,1) = 1;
    
    % Perform common mode subtraction & filter signal ahead of artifact subtraction
    ampRaw_sgSub = amp_iChan - medCM;
    
    
    % ARTIFACT SUBTRACT & CLEAN IT

    % First highpass filter the signal to get rid of drift
    [b,a] = butter(2, fcL/(fs/2), 'high');
    ampFilt_sg = filtfilt(b,a,ampRaw_sgSub);

    samp_pulse_IntanCorr = samp_pulseIntan + offset;

    % Next run the filtered data thru artifact subtraction
    stimSamps = samp_pulse_IntanCorr;
    params.blankSamps = 46;
    params.fc = [fcL fcH];
    [ampArtsub_sg] = subtractArt(ampFilt_sg, fs, stimSamps, params);

    % spike-filter the final product
    [b,a] = butter(2, [fcL fcH]/(fs/2), 'bandpass');
    ampArtsub_sg = filtfilt(b,a,ampArtsub_sg);

    % Final step for blanking out residual of subtraction step for within-DBS data points
    blankWin = ones(1,params.blankSamps);
    offsetConv = floor(length(blankWin)/2);
    L = length(ampArtsub_sg);
    eventMask = zeros(1,L);
    eventMask(samp_pulse_IntanCorr + offsetConv) = 1;
    blankMask = conv(eventMask, blankWin, 'same');
    blankMask = not(blankMask); % so that when multiplying the mask with the signal you'll zero out event data
    ampCln_sg = ampArtsub_sg.*blankMask;
    
    
    
%     figure; plot(ampCln_sg);

    % break it back down into parsed data, save individually in data processing
    % folder
    
    nFiles = height(tabChan);
    tabiChanProc = tabChan;
    tabiChanProc.nsamples(1) = tabiChanProc.nsamples(1) - sum(idxNegTst);
    
    % for each original rhd file:
    for iFile = 1:nFiles
        % pull data out
        data = ampCln_sg(concatIdx(iFile,1):concatIdx(iFile,2));
    
        % Save this data to its own matfile with similar name as original
        % parsed file
        [~,parsedFilename,~] = fileparts(tabChan.parsedFilename{iFile});
        spkFileName = [parsedFilename 'SPK'];
        
        tabiChanProc.parsedFilename{iFile} = spkFileName;
        save([p.procParsedPn spkFileName], 'data');
        
    end
    
    sessionTab = [sessionTab; tabiChanProc];
    
    
    % Final check for quality of artifact removal, look at spectral content
    % before/after
    [pxx1, f] = periodogram(ampFilt_sg,rectwin(length(ampFilt_sg)),length(ampFilt_sg),fs);

    [pxx2, f] = periodogram(ampCln_sg,rectwin(length(ampCln_sg)),length(ampCln_sg),fs);

    f1 = figure;
    plot(f,10*log10(pxx1));
    hold on; plot(f,10*log10(pxx2));
    chLab = tabiChanProc.chanLabel{iFile};
    title([chLab ' PSD'])
    set(gca, 'XLim', [0 2000])
    ylabel('dB scale of power')
    xlabel('Frequency (Hz)')
    legend('Pre-subtaction', 'Post-subtraction')
    
    saveas(f1, [p.procArtSubPn 'ch' chLab '_artPSD'], 'jpeg')
    close(f1)
    clear f1
    


    
end

% Final step, write the metadata table
writetable(sessionTab, [p.procParsedPn 'parsedMatfilesMetadata.xlsx']);

toc

end

