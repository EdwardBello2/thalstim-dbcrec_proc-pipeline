% test script for coregistering TDT time to Intan time, and translating DBS
% pulse events & settings to Intan frame of reference

% For this example pick one recording phase with pair of TDT data and
% Intan RHD files

addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));
 
% Read in TDT data
pn = 'D:\PROJECTS\ET RO1 Preclinical\data-acquisition\20240122\';
tdtTank = 'DCNrs_pB-231206-112317';
tdtBlock = 'Zebel-240122-120155';

tdt = TDTbin2mat([pn tdtTank '\' tdtBlock]);

% Get DBS pulse events into precise time values
% use existing custom function to retrieve DBS pulse info
% relate DBS settings to each DBS pulse event
[dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(tdt, 'ETRO1_pB');

% check how those events line up with stream from TDT
dbsData = tdt.streams.eS1r.data(1,:);
fsData = tdt.streams.eS1r.fs;
ts = (1/fsData)*[0:(length(dbsData)-1)];

% figure; plot(ts, dbsData);
% hold on;
% scatter(dbsPulseInfo.ts_pulse, 10*ones(1,length(dbsPulseInfo.ts_pulse)));



% correlate DBS pulse times with the synchronization TTL pulses

