clear all

%% CONSTANTS
% This is the only manual input part of the code
% Specify the locations of data on your PC

rootPn = 'D:\PROJECTS\ET RO1 Preclinical\';

dataSession = '20230717';

TDTtank = 'ETRO1_pA-230518-120424'; 

TDTblock = 'Zebel-230717-115106'; 

RHDfolder = 'ThalDbsCxRec01_230717_115111';

% place where your code got downloaded
addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));



fsRHD = 30000; % samples per second; the sampleing rate of the Intan RHD system for DBC array recordings
dbsSampOffset = 6; % number of samples to correct the tracked detections of DBS events according to TDT system tracking
voltageRange = [-1500 1500]; % microvolts range to display in the figures


% DEPENDENCIES
% These variables are all based on what you filled out above, no need to
% mess with

sessionPn = [rootPn 'data\' dataSession '\']; 
dataAcqPn = [sessionPn 'acquisition\'];
dataProcPn = [sessionPn 'processing\'];
dataAnalyPn = [sessionPn 'analysis\'];
TDTtankPn = [dataAcqPn 'Tanks\' TDTtank '\']; 
RHDfolderPn = [dataAcqPn 'IntanRecording\' RHDfolder '\'];  
RHDparsedPn = [RHDfolderPn 'parsedMatfiles\'];


%% CODE

% enforce existence of processing & analysis output directories
analysisName = mfilename();
enforce_dir(dataProcPn);
enforce_dir(dataAnalyPn);
enforce_dir([dataAnalyPn analysisName])
 

TDTsynapseProgram = TDTtank(1:8); % ETRO1_pA | ETRO1_pB

switch TDTsynapseProgram
    case 'ETRO1_pA'
        expPhase = 'phase1';
        
    case 'ETRO1_pB'
        expPhase = 'phase3';
        
end


%% Parse out the contents of the .rhd files (if not already done)

% 1) Parse out original .rhd files into single channel data .mat files, tracking every new parsed file and its metadata in a spreadsheet
% based on "script_rhd_parse2matheader_batch.m"
% sessionTab = table(); % initialize a table object to track all processed files that will be created from amplifier data
disp('BEGIN RUNNING CODE FOR CONVERTING RAW RHD FILES TO PARSED MAT FILES...')
func_rhd_parse2matheader_batch_v2(RHDfolderPn, RHDparsedPn);

disp('DONE RUNNING CODE FOR CONVERTING RAW RHD FILES TO PARSED MAT FILES!')



%% Code that 


disp('BEGIN RUNNING CODE FOR CONCATENATING DATA ARTIFACT VISUALIZATION...')
script_rawPSTH

disp('DONE RUNNING CODE FOR VISUALIZING ALL DBS ARTIFACTS & SPIKES!')

