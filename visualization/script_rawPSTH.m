% script for generating many jpeg images of DBS artifact stacks. Each stack
% corresponds to one DBS setting, on one channel. This script performs this
% for all channels in a given experimental phase (e.g. .rhd files and TDT
% block pertaining to "phase 3" touchscreen stuff. 
% 
% clear all
% 
% % to set constants and data pathways, first edit the matlab script
% % "script_rawPSTH_parameters.m" to update paths for your particular PC.
% % Then run this script. 
% script_rawPSTH_parameters
% % 
% % %% CONSTANTS
% % % Specify the locations of data on your PC
% % 
% % rootPn = 'D:\PROJECTS\ET RO1 Preclinical\';
% % 
% % dataSession = '20230717';
% % 
% % TDTtank = 'ETRO1_pB-230419-102301'; 
% % 
% % TDTblock = 'Zebel-230717-112522'; 
% % 
% % RHDfolder = 'ThalDbsCxRec01_230717_112527';
% % 
% % 
% % fsRHD = 30000; % samples per second; the sampleing rate of the Intan RHD system for DBC array recordings
% % dbsSampOffset = 6; % number of samples to correct the tracked detections of DBS events according to TDT system tracking
% % voltageRange = [-1500 1500]; % microvolts range to display in the figures
% % 
% % 
% % %------------------------------------------------
% % 
% % sessionPn = [rootPn 'data\' dataSession '\']; 
% % dataAcqPn = [sessionPn 'acquisition\'];
% % dataProcPn = [sessionPn 'processing\'];
% % dataAnalyPn = [sessionPn 'analysis\'];
% % TDTtankPn = [TDTtank '\']; 
% % RHDfolderPn = [dataAcqPn RHDfolder '\'];  
% % RHDparsedPn = [RHDfolderPn 'parsedMatfiles\'];
% % analysisName = mfilename();
% 
% % addpath(genpath('C:\Users\umoh0002\Downloads\MJ\ETRO1\thalstim-dbcrec_proc-pipeline-main\thalstim-dbcrec_proc-pipeline-main'));
% 
% % enforce existence of processing & analysis output directories
% analysisName = mfilename();
% enforce_dir(dataProcPn);
% enforce_dir(dataAnalyPn);
% enforce_dir([dataAnalyPn analysisName])
%  
% 
% TDTsynapseProgram = TDTtank(1:8); % ETRO1_pA | ETRO1_pB
% 
% switch TDTsynapseProgram
%     case 'ETRO1_pA'
%         expPhase = 'phase1';
%         
%     case 'ETRO1_pB'
%         expPhase = 'phase3';
%         
% end
% 
% 
% 
% %% Parse out the contents of the .rhd files (if not already done)
% 
% % 1) Parse out original .rhd files into single channel data .mat files, tracking every new parsed file and its metadata in a spreadsheet
% % based on "script_rhd_parse2matheader_batch.m"
% % sessionTab = table(); % initialize a table object to track all processed files that will be created from amplifier data
% disp('BEGIN RUNNING CODE FOR CONVERTING RAW RHD FILES TO PARSED MAT FILES...')
% func_rhd_parse2matheader_batch_v2(RHDfolderPn, RHDparsedPn);
% 
% disp('DONE RUNNING CODE FOR CONVERTING RAW RHD FILES TO PARSED MAT FILES!')



%% Concatenate certain useful single channel data first 

% read in the parsedMatfiles table
parseDir = RHDparsedPn;
% 'D:\PROJECTS\ET RO1 Preclinical\data\20230712\acquisition\ThalDbsCxRec01_230712_124848\parsedMatfiles\';
tab = readtable([parseDir 'parsedMatfilesMetadata.xlsx']);

% Construct the fully concatenated data for DIGITAL-IN-02
chanLabelSelect = 'DIGITAL-IN-02';
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
subTab = tab((idxChanLabel),:);
dig2 = concatParsed_sg(subTab, parseDir);

% Construct the fully concatenated data for timestamps of the amplifier
% data
dataType = 't_amplifier';
idxDataType= strcmp(tab.dataType, dataType);
subTabTst = tab((idxDataType),:);
tst = concatParsed_sg(subTabTst, parseDir);

% remove all data points that pertain to negative time in timeseries
idxNegTst = tst < 0;
dig2(idxNegTst) = [];
tstCorr = tst;
tstCorr(idxNegTst) = [];



%% Get DBS pulse event times 

disp('Loading TDT-based DBS event times, re-referencing to Intan-time...')

% Extract DBS pulse timing info and settings
tic
blk = TDTbin2mat([TDTtankPn TDTblock], 'TYPE', [2]);
[dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(blk, TDTsynapseProgram);
dbsInfo = join(dbsPulseInfo, dbsStimInfo);

% Perform a correction for the time drift between Intan and TDT systems,
% get corrected dbs times
nPulses = height(dbsPulseInfo);
ts_pulse_TDT = dbsPulseInfo.ts_pulse;

risingEdgeIdx = find(diff(dig2) == 1) + 1;
IntanSyncTimes = tstCorr(risingEdgeIdx);
TdtSyncTimes = blk.epocs.Pu1_.onset;

[~,b] = makeCorrection(IntanSyncTimes, TdtSyncTimes, false);

dbsInfo.ts_pulseIntan = applyCorrection(dbsInfo.ts_pulse, b);
dbsInfo.samp_pulseIntan = round(dbsInfo.ts_pulseIntan*30000);

% final step to remove any DBS stim events that aren't high-frequency
dbsInfo(dbsInfo.PeA_data > 7.8,:) = [];


toc



%% Concatenate single channel data and display voltage trace around DBS pulses

% get amplifier channel info
subTab = tab(strcmp(tab.dataType, 'amplifier_data'),:);
chLabels = unique(subTab.chanLabel);

% for each channel
nChs = length(chLabels);
dbsElecs = unique(dbsInfo.ChnA_data);
nDbs = length(dbsElecs);


% initialize column data for an excel sheet tracking each image generated
nRows = nChs * nDbs; 

   YYYY = cell(nRows,1); 
     MM = cell(nRows,1); 
     DD = cell(nRows,1); 
  phase = cell(nRows,1);
recChan = cell(nRows,1);
dbsElec = zeros(nRows,1);
filename = cell(nRows,1);


 YYYY(:) = {dataSession(1:4)};
   MM(:) = {dataSession(5:6)};
   DD(:) = {dataSession(7:8)};
phase(:) = {expPhase};
i = 1;

%% THIS FOR LOOP IS THE PART WHERE THE FIGURES GET GENERATED AND SAVED
for ich = 1:nChs
    
    ichLabel = chLabels{ich};


    % concatenate all data for that channel
    ichTab = subTab(strcmp(subTab.chanLabel, ichLabel),:);
    [concatSg, iFileSampIdx] = concatParsed_sg(ichTab, parseDir);


    % highpass the single channel
    fs = 30000; % sampling frequency of amplifier data (samples/sec)
    fc = 300; % highpass filter cutoff frequency, Hz
    [b,a] = butter(2, fc/(fs/2), 'high');
    filtSg = filtfilt(b,a,concatSg);
    filtSg(idxNegTst) = []; % get rid of data pertaining to negative time...


    % gather unique DBS settings
%     dbsElecs = unique(dbsInfo.ChnA_data);



    % for each dbs setting (i.e. each electrode)
%     nDbs = length(dbsElecs);
    for iDbs = 1:nDbs
    
        % get each DBS pulse time
        iElec = dbsElecs(iDbs);
        tDbs = dbsInfo.ts_pulseIntan(dbsInfo.ChnA_data == iElec); % timestamps of DBS, seconds
        sDbs = round(tDbs * fs); % samples indices for each DBS pulse
        sDbs = sDbs + dbsSampOffset; % any corrections needed for true DBS event time of occurrence

        % gather a window of amplifier channel data around each DBS pulse
        segLength = floor(fs * (7.7/1000));
        [Segs,~] = segments(filtSg,sDbs,segLength);

        % plot all the waveforms at once
        tSeg = (0:(size(Segs,2)-1))/fs;
        f1 = figure;
        ax1 = axes;
        plot(tSeg * 1000, Segs');
        xlabel('time since DBS onset (ms)')
        ylabel('microvolts')
        title(['peri-stim voltage trace, ch: ' ichLabel ', DBS-elec: ' num2str(iElec) ', tot stims: ' num2str(size(Segs,1))]);
        ax1.YLim = voltageRange;

        %%%figure size/ orientation
        screen_size = get(0, 'ScreenSize'); %get screen resolution
        set(f1, 'Position', [0 0 screen_size(3) screen_size(4)] );
        figure_prop_name = {'PaperPositionMode','units','Position'};
        figure_prop_val =  { 'auto'            ,'inches', [0.25 0.25 10.5 8]};%left bottom width height
        set(f1,'PaperOrientation', 'landscape', 'PaperPositionMode', 'auto','units', 'inches', 'Position', [0.25 0.25 19.5 10])

        % save the image in the analysis folder under this script name
        saveName = [dataSession '-' expPhase '_' ichLabel '_' 'dbs-' num2str(iElec)];
        saveas(f1, [dataAnalyPn analysisName '\' saveName], 'jpeg');
        disp(['saved ' saveName])
        
        close(f1);
        clear f1;
        
        % update the metadata columns
        recChan(i) = {ichLabel};
        dbsElec(i) = iElec;
        filename(i) = {saveName};
        i = i+1;
        
        
    end

end

imageTab = table();

imageTab.YYYY = YYYY;
imageTab.MM = MM;
imageTab.DD = DD;
imageTab.phase = phase;
imageTab.recChan = recChan;
imageTab.dbsElec = dbsElec;
imageTab.filename = filename;

writetable(imageTab, [dataAnalyPn analysisName '\' dataSession '-' expPhase '.xlsx'])



