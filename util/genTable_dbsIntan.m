function [dbsInfo] = genTable_dbsIntan(dig2,fsIntan,dbsStimInfo,dbsPulseInfo)
% function for migrating TDT-based pulse times into Intan pulse times using
% the common TTL pulse sent from TDT into Intan's digital 2 line on every
% DBS epoc start

%% Specify data sources and locations
% 
% % example multi-platform data for phase 3
% rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
% sessionFolder = '20240122';
% datapn = [rootpn 'data-acquisition\' sessionFolder '\'];
% 
% % TDTtank = 'DCNrs_pB-231206-112317';
% TDTtank = 'DCNrs_pA-231205-154908';
% 
% 
% % TDTblock = 'Zebel-240122-120155';
% TDTblock = 'Zebel-240122-122431';
% 
% RHDfolder = 'ThalDbsCxRec01_240122_122436';
% RHDfileFirst = 'ThalDbsCxRec01_240122_122436';
% 
% addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));
% 
% medianFullPath = [rootpn 'data-processing\' sessionFolder '\' RHDfolder '\'];
% 
% 
% % CONSTANTS
% fsIntan = 30000;
% fsTDT = 24414.0625;

%%

% % First read in TDT dbs data and pulse data
% blk = TDTbin2mat([datapn TDTtank '\' TDTblock]);
% [dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(blk, 'ETRO1_pA');

% Detect the onset times of dbs epocs in Intant time using digital line 2
risingEdgeIdx = find(diff(dig2) == 1) + 1;
Intan_onset = [risingEdgeIdx * (1/fsIntan)]';
dbsStimInfo = [dbsStimInfo, table(Intan_onset)];


% track dbs stim pulse times referenced to stim epoc initiation
dbsInfo = join(dbsPulseInfo, dbsStimInfo);
ts_pulseEpocRef = dbsInfo.ts_pulse - dbsInfo.Pu1_onset;
dbsInfo = [dbsInfo, table(ts_pulseEpocRef)];

% calculate Intan referenced pulse times now
dbsInfo.ts_pulseIntan = dbsInfo.Intan_onset + dbsInfo.ts_pulseEpocRef;

% Next get the sample index of each Intan timestamp value
dbsInfo.samp_pulseIntan = round(dbsInfo.ts_pulseIntan * fsIntan);

% dbsInfo = [dbsInfo, table(ts_pulseIntan), table(samp_pulse_Intan)];



end




















