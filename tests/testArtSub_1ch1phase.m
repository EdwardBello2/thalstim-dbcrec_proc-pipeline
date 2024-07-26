% test script for removing artifacts from an entire block of recordings



% example multi-platform data for phase 3
rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
sessionFolder = '20240122';
datapn = [rootpn 'data-acquisition\' sessionFolder '\'];

% TDTtank = 'DCNrs_pB-231206-112317';
TDTtank = 'DCNrs_pA-231205-154908';


% TDTblock = 'Zebel-240122-120155';
TDTblock = 'Zebel-240122-122431';

% RHDfolder = 'ThalDbsCxRec01_240122_120200';
% RHDfileFirst = 'ThalDbsCxRec01_240122_120200';
RHDfolder = 'ThalDbsCxRec01_240122_122436';
RHDfileFirst = 'ThalDbsCxRec01_240122_122436';



addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));

medianFullPath = [rootpn 'data-processing\' sessionFolder '\' RHDfolder '\'];

%% read in TDT-related info, extract DBS event times

blk = TDTbin2mat([datapn TDTtank '\' TDTblock]);
[dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(blk, 'ETRO1_pA');



%% Read in each rhd file one at a time and get a median common mode of all good channels saved

% read in parsedMatfilesMetadata table
tab = readtable([datapn RHDfolder '\parsedMatfiles\parsedMatfilesMetadata.xlsx']);

nRHDfiles = max(tab.fileOrder); 

% prepare a metadata table for the median common mode channel tracking, to
% be saved in the processing folder
chanLabelSelect = 'A-100'; % just pick an arbitrary label
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
medTab = tab((idxChanLabel),:);   
    
nRHDfiles = height(medTab);
for iRHDfile = 1:nRHDfiles
    name = medTab.parsedFilename{iRHDfile};
    medTab.parsedFilename{iRHDfile} = [name(1:end-9) 'MED'];
    
end


% 
for iRHDfile = 1:nRHDfiles
    % Specify all parsed files related to one RHD file
    idxFile = tab.fileOrder == iRHDfile;

    % Specify all parsed files that hold amplifier data
    idxAmp = strcmp(tab.dataType, 'amplifier_data');

    subTab = tab((idxFile & idxAmp),:);

    % Populate a matrix of corresponding amplifier data
    nChans = height(subTab);
    nSamps = subTab.nsamples(1);
    ampRaw = zeros(nChans, nSamps);

    fileFullpath = [datapn RHDfolder '\parsedMatfiles\']; 
    tic
    for iChan = 1:nChans
        load([fileFullpath subTab.parsedFilename{iChan}]); % loads variable called "data"
        ampRaw(iChan,:) = data;

    end
    toc
    
    % Get a common mode signal based on global median of good channels
    data = median(ampRaw,1);
    
    % Save this data to its own matfile with similar name
    parsedFilename = subTab.parsedFilename{iChan};
    medFileName = [parsedFilename(1:end-9) 'MED'];
    
    save([medianFullPath medTab.parsedFilename{iRHDfile}], 'data');
    
    
end

writetable(medTab, [medianFullPath 'medianCommonModeMetadata.xlsx']);



%% read in an entire experiment phase of one channel of data from Intan-based files, concatenate

% read in parsedMatfilesMetadata table
tab = readtable([datapn RHDfolder '\parsedMatfiles\parsedMatfilesMetadata.xlsx']);


chanLabelSelect = 'A-100';
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
subTab = tab((idxChanLabel),:);

% Populate a matrix of corresponding amplifier data & timestamps
nSamps = sum(subTab.nsamples(:));
ampRaw_sg = zeros(1, nSamps);
timestamps = zeros(1,nSamps);

% prep sample indices matrix
nSampCol = cumsum(subTab.nsamples);
idxbeg = [0; nSampCol(1:end-1)] + 1;
idxend = nSampCol;
iFileSampIdx = [idxbeg, idxend];

fileFullpath = [datapn RHDfolder '\parsedMatfiles\']; 

nFiles = height(subTab);
for iRHDfile = 1:nFiles
    idxL = iFileSampIdx(iRHDfile,:);
    
    load([fileFullpath subTab.parsedFilename{iRHDfile}]); % loads variable called "data"
    ampRaw_sg(idxL(1):idxL(2)) = data;   
    
    
end

% Perform a similar operation to get concatenated timestamps corresponding
% to the data
dataType = 't_amplifier';
idxDataType= strcmp(tab.dataType, dataType);
subTabTst = tab((idxDataType),:);

% Populate a matrix of corresponding amplifier data & timestamps
nSamps = sum(subTabTst.nsamples(:));
timestamps = zeros(1,nSamps);

% prep sample indices matrix
nSampCol = cumsum(subTabTst.nsamples);
idxbeg = [0; nSampCol(1:end-1)] + 1;
idxend = nSampCol;
iFileSampIdx = [idxbeg, idxend];

nFiles = height(subTabTst);
for iRHDfile = 1:nFiles
    idxL = iFileSampIdx(iRHDfile,:);
    
    load([fileFullpath subTabTst.parsedFilename{iRHDfile}]); % loads variable called "data"
    timestamps(idxL(1):idxL(2)) = data;   
    
    
end

% figure; plot(timestamps, ampRaw_sg);


%% Also read in and concatenate the common mode data

% read in medianCommonModeMetadata table
medTab = readtable([medianFullPath 'medianCommonModeMetadata.xlsx']);

% Populate a matrix of corresponding amplifier data
nSamps = sum(medTab.nsamples(:));
medCM = zeros(1, nSamps);

% prep sample indices matrix
nSampCol = cumsum(medTab.nsamples);
idxbeg = [0; nSampCol(1:end-1)] + 1;
idxend = nSampCol;
iFileSampIdx = [idxbeg, idxend];

nFiles = height(medTab);
for iRHDfile = 1:nFiles
    idxL = iFileSampIdx(iRHDfile,:);
    
    load([medianFullPath medTab.parsedFilename{iRHDfile}]); % loads variable called "data"
    medCM(idxL(1):idxL(2)) = data;   
    
end

figure; plot(ampRaw_sg); hold on; plot(medCM);



%% Read in digital lines from Intan recording

% read in parsedMatfilesMetadata table
tab = readtable([datapn RHDfolder '\parsedMatfiles\parsedMatfilesMetadata.xlsx']);


% Construct the fully concatenated data for DIGITAL-IN-01
chanLabelSelect = 'DIGITAL-IN-01';
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
subTab = tab((idxChanLabel),:);

% Populate a matrix of corresponding amplifier data & timestamps
nSamps = sum(subTab.nsamples(:));
dig1 = zeros(1, nSamps);


% prep sample indices matrix
nSampCol = cumsum(subTab.nsamples);
idxbeg = [0; nSampCol(1:end-1)] + 1;
idxend = nSampCol;
iFileSampIdx = [idxbeg, idxend];

nFiles = height(subTab);
for iRHDfile = 1:nFiles
    idxL = iFileSampIdx(iRHDfile,:);
    
    load([fileFullpath subTab.parsedFilename{iRHDfile}]); % loads variable called "data"
    dig1(idxL(1):idxL(2)) = data;   
    
end


% Construct the fully concatenated data for DIGITAL-IN-01
chanLabelSelect = 'DIGITAL-IN-02';
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
subTab = tab((idxChanLabel),:);

% Populate a matrix of corresponding amplifier data & timestamps
nSamps = sum(subTab.nsamples(:));
dig2 = zeros(1, nSamps);


% prep sample indices matrix
nSampCol = cumsum(subTab.nsamples);
idxbeg = [0; nSampCol(1:end-1)] + 1;
idxend = nSampCol;
iFileSampIdx = [idxbeg, idxend];

nFiles = height(subTab);
for iRHDfile = 1:nFiles
    idxL = iFileSampIdx(iRHDfile,:);
    
    load([fileFullpath subTab.parsedFilename{iRHDfile}]); % loads variable called "data"
    dig2(idxL(1):idxL(2)) = data;   
    
end



%% Perform common mode subtraction & filter signal ahead of artifact subtraction

ampRaw_sgSub = ampRaw_sg - medCM;
figure; plot(ampRaw_sgSub)



%% Detect DBS artifacts in Intan data based on TDT timing info

% get corresponding timestamps for amplifier data
% idxTstAmp = strcmp(tab.dataType, 't_amplifier');
% tTab = tab((idxWin & idxTstAmp),:);
% load([fileFullpath tTab.parsedFilename{:}]); % loads variable called "data"
tst = timestamps;

% set up DBS event tracking
% offset = -54; % number of samples & direction (+/1) to offset TDT-based dbs event detection in Intan data
offset = 0; % number of samples & direction (+/1) to offset TDT-based dbs event detection in Intan data

nPulses = height(dbsPulseInfo);
ts_pulse_TDT = dbsPulseInfo.ts_pulse;
ts_pulse_Intan = zeros(nPulses,1);
samp_pulse_Intan = zeros(nPulses,1);

% First find the timestamp values in Intan closest to the TDT time values

% % ---------OLD WAY-------------
% ts_pulse_Intan = interp1(tst,tst,ts_pulse_TDT,'nearest');
% %------------------------------

% ---------NEW WAY-------------
dbsInfo = genTable_dbsIntan(dig2,30000,dbsStimInfo,dbsPulseInfo);
ts_pulse_Intan = dbsInfo.ts_pulseIntan;
%------------------------------


% Next get the sample index of each Intan timestamp value
samp_pulse_Intan = round(ts_pulse_Intan * 30000);





%% Subtract average artifact templates off of mode-corrected data and bandpass filter

% First highpass filter the signal to get rid of drift
fc = 300;
fs = 30000;
[b,a] = butter(2, fc/(fs/2), 'high');
ampFilt_sg = filtfilt(b,a,ampRaw_sgSub);

% Quick check to verify artifact detection times are accurate
% get mode-subtracted & filtered version of signal
samp_pulse_IntanCorr = samp_pulse_Intan + offset;

% sampWin = floor((7.5/1000) * fs);
sampWin = median(diff(samp_pulse_IntanCorr));


[Segs,SegIndices] = segments(ampFilt_sg, samp_pulse_Intan, [0 sampWin]);

st = 1;
wd = 7800;
% figure; plot(Segs(st:(st+wd),:)')



% Next run the filtered data thru artifact subtraction
% figure; plot(ampRaw_sgSub);
% hold on;

% plot(ampFilt_sg)

fs = 30000;
stimSamps = samp_pulse_IntanCorr;
params.blankSamps = 46;
params.fc = [300 10000];
[ampArtsub_sg] = subtractArt(ampFilt_sg, fs, stimSamps, params);
% plot(ampArtsub_sg)

% spike-filter the final product
fc = [300 10000];
fs = 30000;
[b,a] = butter(2, fc/(fs/2), 'bandpass');
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
figure; plot(ampCln_sg, 'color', 'magenta')


% Final quality check for DBS removal
% get PSDs of signal before dbs art removal vs after:

fsIntan = 30000;
figure; 
ax1 = gca;

[pxx1, f] = periodogram(ampFilt_sg,rectwin(length(ampFilt_sg)),length(ampFilt_sg),fsIntan);
% title('DBS present: PSD');
% ax1.YLim = [-100 60];
% ax1.XLim = [0 1];

% figure; 
% ax2 = gca;
[pxx2, f] = periodogram(ampCln_sg,rectwin(length(ampCln_sg)),length(ampCln_sg),fsIntan);
% title('DBS subtracted: PSD')
% ax2.YLim = [-100 60];
% ax2.XLim = [0 1];

plot(f,10*log10(pxx1));
hold on; plot(f,10*log10(pxx2));
title('PSD')
ylabel('dB scale of power')
xlabel('Frequency (Hz)')
legend('Pre-subtaction', 'Post-subtraction')





