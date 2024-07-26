% test script for interpreting the touchscreen task event codes tracked
% within TDT..

% example multi-platform data for phase 3
params.rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
params.sessionpn = '20240119\';
params.acqDatapn = [params.rootpn 'data-acquisition\' params.sessionpn];
params.procDatapn = [params.rootpn 'data-processing\' params.sessionpn];

params.TDTtankpn = 'DCNrs_pB-231206-112317\';
% TDTtankpn = 'DCNrs_pA-231205-154908\';

params.TDTblock = 'Zebel-240119-123221';
% TDTblock = 'Zebel-240122-122431';

params.RHDfolderpn = 'ThalDbsCxRec01_240119_123226\';
params.RHDfileFirst = 'ThalDbsCxRec01_240119_123226';
% RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% RHDfileFirst = 'ThalDbsCxRec01_240122_122436';

params.acqParsedPn = [params.acqDatapn params.RHDfolderpn 'parsedMatfiles\'];
params.procParsedPn = [params.procDatapn params.RHDfolderpn 'parsedMatfiles\'];
params.procOutputPn = [params.procDatapn params.RHDfolderpn 'PSTHprelim\'];

params.TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...

addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));


% include my local version of the spikes toolbox 
addpath(genpath('C:\Users\bello043\Documents\GitHub\spikes_psthViewerFix'));

%%
p = params;

blk = TDTbin2mat([p.acqDatapn p.TDTtankpn p.TDTblock]);

fsTDT = 24414.0625; % system sampling rate for TDT 

% determine the full extent of timestamps to fill out based on the stream
% data from the start pad voltage trace data
stpd = blk.streams.Stpd.data;
tst_stpd = [0:(length(stpd)-1)] / blk.streams.Stpd.fs;

% Synthesize a 4-d timeseries TTL pulse signal based on known timings of TS
% task TTL pulse rising/falling edges 
tst_TTL = 0:(1/fsTDT):tst_stpd(end);
stream_TTL = zeros(4,length(tst_TTL));

epocs_TTL(1) = blk.epocs.TS1_;
epocs_TTL(2) = blk.epocs.TS2_;
epocs_TTL(3) = blk.epocs.TS3_;
epocs_TTL(4) = blk.epocs.TS4_;

% nTTLs = length(epocs_TTL);
for iTTL = 1:4
    % get a given TTL epoc's onset/offset times
    onsetTTL = epocs_TTL(iTTL).onset;
    offsetTTL = epocs_TTL(iTTL).offset;
    
    % for each event onset/offset pair's duration, insert 1's into the zero signal
    nPulses = length(onsetTTL);
    for iPulse = 1:nPulses
        onsetSamp_iP = round(onsetTTL(iPulse) * fsTDT);
        offsetSamp_iP = round(offsetTTL(iPulse) * fsTDT);
        
        stream_TTL(iTTL,onsetSamp_iP:offsetSamp_iP) = 1;
        
    end
  
end

% Assign event labels based on binary code from the 4 TS task signals to
% TDT

% first convert binary 4d signal to numerical 1d signal by interpreting
% base 2 to base 10


N = length(stream_TTL);
% codes = struct();
decCode = zeros(1,N);
for i = 1:N
    b = stream_TTL(:,i)';
    decCode(i) = b(1)*(2^3) + b(2)*(2^2) + b(3)*(2^1) + b(4)*(2^0);   
    
end

figure; plot(tst_stpd, stpd); 
hold on; 
plot(tst_TTL, decCode);
set(gca, 'YLim', [-1 16])
% Figure out interpretation of this binary code into known GoNoGo task
% event codes to get relevant reach event times.. may need to
% offset-correct using helpful startpad voltage data...



%% You know what, screw the TTL codes for now!
% Let's just focus on getting the timepoints when Zebel leaves the start
% pad... 

blk = TDTbin2mat([p.acqDatapn p.TDTtankpn p.TDTblock]);

fsTDT = 24414.0625; % system sampling rate for TDT 

% determine the full extent of timestamps to fill out based on the stream
% data from the start pad voltage trace data
stpd = blk.streams.Stpd.data;
tst_stpd = [0:(length(stpd)-1)] / blk.streams.Stpd.fs;


% first clean up the raw voltage detections into having either 0 or 1,
% depending on the two levels. Here 1 means hand off the pad; 0 means hand
% on the pad.

stpdOffset = stpd - mean(stpd);
stpdTTL = stpdOffset;
stpdTTL(stpdTTL > 0) = 1;
stpdTTL(stpdTTL <= 0) = 0;

samp_offStpd = [0, diff(stpdTTL)] == 1; % detect rising edge 

% figure; plot(tst_stpd, stpdTTL); hold on;
% tst_offStpd = tst_stpd(samp_offStpd);
% scatter(tst_offStpd, 0.5*ones(1,length(tst_offStpd)));










