% first draft of the pipeline going all the way from "raw" data from data
% acquisition, to a final output of 128 channels of continuous spike data,
% cleaned of DBS artifacts; full pre-processing pipeline going from
% taking in the original raw data acquisition files, to preparation for
% packaging into a format that KILOSORT expects

%% Add codebase to matlab path, and specify file and directory paths


% example multi-platform data for phase 3
rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
sessionpn = '20240122\';
acqDatapn = [rootpn 'data-acquisition\' sessionpn];
procDatapn = [rootpn 'data-processing\' sessionpn];

TDTtankpn = 'DCNrs_pB-231206-112317\';
% TDTtankpn = 'DCNrs_pA-231205-154908\';

TDTblock = 'Zebel-240122-120155';
% TDTblock = 'Zebel-240122-122431';

RHDfolderpn = 'ThalDbsCxRec01_240122_120200\';
RHDfileFirst = 'ThalDbsCxRec01_240122_120200';
% RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% RHDfileFirst = 'ThalDbsCxRec01_240122_122436';

acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
procOutputPn = [procDatapn RHDfolderpn 'PSTHprelim\'];

TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...

addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));

addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));

% include my local version of the spikes toolbox 
addpath(genpath('C:\Users\bello043\Documents\GitHub\spikes_psthViewerFix'));


%% 
% 1) Parse out original .rhd files into single channel data .mat files, tracking every new parsed file and its metadata in a spreadsheet
% based on "script_rhd_parse2matheader_batch.m"
clear; 
sessionTab = table(); % initialize a table object to track all processed files that will be created from amplifier data




%% 
% 2) Get clean spike data on all channels and parse the results out too, similar to above for raw
% 2a) read in spreadsheet that tracks parsed raw data, and get some necessary 
% 2b) Get single-channel fully concatenated data for each channel, remove common noise and dbs artifacts
% 2c) saves parsed files of now clean data, much like what was done for the original raw data, but this data gets stored in the data-processing directory instead
% based on "testArtSub_allch1phase.m"




%% 
% 3) Generate large binary based on parsed proc data
% "testTDTandIntan_artDetect.m"



%%  Read in files (or metadata about files), including original .rhd files,
% tdt files, and any other necessary files




%% synchronize the disparate data so that DBS events and spike events can be
% properly aligned




%% prep the data (one channel at a time? pre-filter?) for DBS artifact
% subtraction



%% Assemble the now cleaned data into one large multichannel binary file
% that Kilosort expects, taking bad channels into proper account
