function [stpdInfo] = func_getStartpadTimesCorrected(p)
% script for detecting startpad-off times for Zebels hand, and
% re-referenceing these to spike times within the Intant system

% clear
% 
% % example multi-platform data for phase 3
% p.rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
% p.sessionpn = '20240122\';
% p.acqDatapn = [p.rootpn 'data-acquisition\' p.sessionpn];
% p.procDatapn = [p.rootpn 'data-processing\' p.sessionpn];
% 
% p.TDTtankpn = 'DCNrs_pB-231206-112317\';
% % TDTtankpn = 'DCNrs_pA-231205-154908\';
% 
% p.TDTblock = 'Zebel-240122-120155';
% % TDTblock = 'Zebel-240122-122431';
% 
% p.RHDfolderpn = 'ThalDbsCxRec01_240122_120200\';
% params.RHDfileFirst = 'ThalDbsCxRec01_240122_120200';
% % RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% % RHDfileFirst = 'ThalDbsCxRec01_240122_122436';
% 
% params.acqParsedPn = [params.acqDatapn params.RHDfolderpn 'parsedMatfiles\'];
% params.procParsedPn = [params.procDatapn params.RHDfolderpn 'parsedMatfiles\'];
% params.procOutputPn = [params.procDatapn params.RHDfolderpn 'PSTHprelim\'];
% 
% p.TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...
% 
% addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));

% 
% % include my local version of the spikes toolbox 
% addpath(genpath('C:\Users\bello043\Documents\GitHub\spikes_psthViewerFix'));



%%

% Read in TDT-based startpad info

blk = TDTbin2mat([p.acqDatapn p.TDTtankpn p.TDTblock]);

fsTDT = 24414.0625; % system sampling rate for TDT 

% determine the full extent of timestamps to fill out based on the stream
% data from the start pad voltage trace data
stpd = blk.streams.Stpd.data;
tst_stpd = [0:(length(stpd)-1)] / blk.streams.Stpd.fs;


%% first clean up the raw voltage detections into having either 0 or 1,
% depending on the two levels. Here 1 means hand off the pad; 0 means hand
% on the pad.

stpdOffset = stpd - mean(stpd);
stpdTTL = stpdOffset;
stpdTTL(stpdTTL > 0) = 1;
stpdTTL(stpdTTL <= 0) = 0;

% Obtain stardpad off-times
idx_offStpd = [0, diff(stpdTTL)] == 1; % detect rising edge 

% figure; plot(tst_stpd, stpdTTL); hold on;
samp_offStpd = find(idx_offStpd);
tst_offStpd = tst_stpd(idx_offStpd);
% scatter(tst_offStpd, 0.5*ones(1,length(tst_offStpd)));




%% Re-reference them to Intan time
% 
% blk = TDTbin2mat([p.acqDatapn p.TDTtankpn p.TDTblock], 'TYPE', [2]);
% [dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(blk, p.TDTsynapseProgram);
% dbsInfo = join(dbsPulseInfo, dbsStimInfo);

stpdInfo = table();
stpdInfo.offPadSampTDT = samp_offStpd';
stpdInfo.offPadTstTDT = tst_offStpd';


% nPulses = height(dbsPulseInfo);
% ts_pulse_TDT = dbsPulseInfo.ts_pulse;
% 
% % Detect the onset times of dbs epocs in Intant time using digital line 2
% risingEdgeIdx = find(diff(dig2) == 1) + 1;
% IntanSyncTimes = tst(risingEdgeIdx);
% TdtSyncTimes = blk.epocs.Pu1_.onset;
% 
% [~,b] = makeCorrection(IntanSyncTimes, TdtSyncTimes, false);
% 
% dbsInfo.ts_pulseIntan = applyCorrection(dbsInfo.ts_pulse, b);
% 
% % ts_pulse_Intan = dbsInfo.ts_pulseIntan;
% negTimeSampOffset = sum(tst < 0);
% dbsInfo.samp_pulseIntan = round(dbsInfo.ts_pulseIntan*30000) + negTimeSampOffset;
% %------------------------------
% 
% % Next get the sample index of each Intan dbs timestamp value
% % samp_pulse_Intan = round(ts_pulse_Intan * 30000);
% samp_pulseIntan = dbsInfo.samp_pulseIntan;

% Final step, write the table for DBS pulse timing info
writetable(stpdInfo, [p.procDatapn p.RHDfolderpn 'StartpadInfo.xlsx']);

end





