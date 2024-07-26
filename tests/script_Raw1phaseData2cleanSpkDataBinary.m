% first draft of the pipeline going all the way from "raw" data from data
% acquisition, to a final output of 128 channels of continuous spike data,
% cleaned of DBS artifacts; full pre-processing pipeline going from
% taking in the original raw data acquisition files, to preparation for
% packaging into a format that KILOSORT expects

%% Add codebase to matlab path, and specify file and directory paths

clear all; 

% example multi-platform data for phase 3
params.rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
params.sessionpn = '20240131\';
params.acqDatapn = [params.rootpn 'data-acquisition\' params.sessionpn];
params.procDatapn = [params.rootpn 'data-processing\' params.sessionpn];

params.TDTtankpn = 'DCNrs_pB-231206-112317\';
% TDTtankpn = 'DCNrs_pA-231205-154908\';

params.TDTblock = 'Zebel-240131-121644';
% TDTblock = 'Zebel-240122-122431';

params.RHDfolderpn = 'ThalDbsCxRec01_240131_121649\';
params.RHDfileFirst = 'ThalDbsCxRec01_240131_121649';
% RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% RHDfileFirst = 'ThalDbsCxRec01_240122_122436';

params.acqParsedPn = [params.acqDatapn params.RHDfolderpn 'parsedMatfiles\'];
params.procParsedPn = [params.procDatapn params.RHDfolderpn 'parsedMatfiles\'];
params.procOutputPn = [params.procDatapn params.RHDfolderpn 'PSTHprelim\'];
params.procArtSubPn = [params.procDatapn params.RHDfolderpn 'artSubResults\'];

params.TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...

addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));


% include my local version of the spikes toolbox 
addpath(genpath('C:\Users\bello043\Documents\GitHub\spikes_psthViewerFix'));


% enforce existence of processing output directories
enforce_dir([params.rootpn 'data-processing\']);
enforce_dir(params.procDatapn);
enforce_dir(params.acqParsedPn);
enforce_dir(params.procParsedPn);
enforce_dir(params.procArtSubPn);


% 



%% 
% 1) Parse out original .rhd files into single channel data .mat files, tracking every new parsed file and its metadata in a spreadsheet
% based on "script_rhd_parse2matheader_batch.m"
% sessionTab = table(); % initialize a table object to track all processed files that will be created from amplifier data
disp('BEGIN RUNNING CODE FOR CONVERTING RAW RHD FILES TO PARSED MAT FILES...')
func_rhd_parse2matheader_batch(params)

disp('DONE RUNNING CODE FOR CONVERTING RAW RHD FILES TO PARSED MAT FILES!')



%%
% Detect startpad-based reach events, based on detections of leaving the
% startpad

stpdTab = func_getStartpadTimesCorrected(params);





%% 
% 2) Get clean spike data on all channels and parse the results out too, similar to above for raw
% 2a) read in spreadsheet that tracks parsed raw data, and get some necessary 
% 2b) Get single-channel fully concatenated data for each channel, remove common noise and dbs artifacts
% 2c) saves parsed files of now clean data, much like what was done for the original raw data, but this data gets stored in the data-processing directory instead
% based on "testArtSub_allch1phase.m"
disp('BEGIN RUNNING CODE FOR DBS-ARTIFACT REMOVAL & CLEANING ON ALL CHANNELS...')

func_ArtSub_allch1phase(params)

disp('DONE RUNNING CODE FOR DBS-ARTIFACT REMOVAL & CLEANING ON ALL CHANNELS!')

% %% 
% % 3) Generate large binary based on parsed proc data
% % "testTDTandIntan_artDetect.m"
% 
% disp('BEGIN RUNNING CODE FOR DBS-ARTIFACT REMOVAL & CLEANING ON ALL CHANNELS...')
% 
% func_ArtSub_allch1phase(params)
% 
% disp('DONE RUNNING CODE FOR DBS-ARTIFACT REMOVAL & CLEANING ON ALL CHANNELS!')
% 


%% Assemble the now cleaned data into one large multichannel binary file
% that Kilosort expects, taking bad channels into proper account
disp('BEGIN RUNNING CODE FOR GENERATING CLEAN MULTICHANNEL BINARY FILE...')

func_concatProc2binary(params)

disp('DONE RUNNING CODE FOR GENERATING CLEAN MULTICHANNEL BINARY FILE!')
