function [dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(tdtblk, tdtSynapseName)
% TDT2dbsinfo takes in the struct output by TDTbin2mat, and generate two
% tables of info around DBS, both on a per-stim and per-pulses basis (as
% defined by TDT Synapse program).
%   define "tdtblk" struct as the output of TDTbin2mat. The only thing
%   necessary for tdtblk to have is the "epocs" field. 

%% Version for ETRO1_pB

switch tdtSynapseName
    case 'ETRO1_pB'
        
% selpath = uigetdir

% Read in TDT events 
% heads = TDTbin2mat([selpath], 'HEADERS', 1);
% tdtblk = TDTbin2mat([selpath], 'TYPE', {'epocs', 'scalars'});


% Create TDT-based event tables for DBS stim events
ts_stim = tdtblk.epocs.DurA.onset;
idxStim = [1:length(ts_stim)]';
 CnA_onset = tdtblk.epocs.CnA_.onset;
  CnA_data = tdtblk.epocs.CnA_.data;
DurA_onset = tdtblk.epocs.DurA.onset;
 DurA_data = tdtblk.epocs.DurA.data;
 Pu1_onset = tdtblk.epocs.Pu1_.onset;
  Pu1_data = tdtblk.epocs.Pu1_.data;
 PC2_onset = tdtblk.epocs.PC2_.onset; 
  PC2_data = tdtblk.epocs.PC2_.data;
  
  dbsStimInfo = table(idxStim, ts_stim, CnA_onset, CnA_data, DurA_onset, ...
      DurA_data, Pu1_onset, Pu1_data, PC2_onset, PC2_data);


% Create TDT-based event tables for DBS pulse events
ts_pulse = tdtblk.epocs.ChnA.onset;
idxPulse = [1:length(ts_pulse)]';
 PeA_onset = tdtblk.epocs.PeA_.onset;
  PeA_data = tdtblk.epocs.PeA_.data;
ChnA_onset = tdtblk.epocs.ChnA.onset;
 ChnA_data = tdtblk.epocs.ChnA.data;
AmpA_onset = tdtblk.epocs.AmpA.onset;
 AmpA_data = tdtblk.epocs.AmpA.data;

idx_pulse2stim = zeros(size(ts_pulse));

% detect stim time concurrent with pulse time
nStims = length(ts_stim);
for iStim = 1:nStims
    its = ts_stim(iStim);
    ref = ts_pulse - its;
    idx = find(ref == min(abs(ref)));
    idx_pulse2stim(idx) = iStim;
    
end

% update indices connecting stim event with corresponding pulse events
nPulses = length(ts_pulse);
for iPulse = 1:nPulses
    if idx_pulse2stim(iPulse) == 0
        idx_pulse2stim(iPulse) = idx_pulse2stim(iPulse-1); 
        
    end
    
end

idxPulse = [1:nPulses]';
idxStim = idx_pulse2stim;

dbsPulseInfo = table(idxPulse, idxStim, ts_pulse, PeA_onset, PeA_data, ...
   ChnA_onset, ChnA_data, AmpA_onset, AmpA_data);



    case 'ETRO1_pA'
%% Version for ETRO1_pA

% selpath = uigetdir
% 
% % Read in TDT events 
% % heads = TDTbin2mat([selpath], 'HEADERS', 1);
% tdtblk = TDTbin2mat([selpath], 'TYPE', {'epocs', 'scalars'});


% Create TDT-based event tables for DBS stim events
 CnA_onset = tdtblk.epocs.CnA_.onset;
  CnA_data = tdtblk.epocs.CnA_.data;
 Pu1_onset = tdtblk.epocs.Pu1_.onset;
  Pu1_data = tdtblk.epocs.Pu1_.data;
%  PC2_onset = tdtblk.epocs.PC2_.onset; 
%   PC2_data = tdtblk.epocs.PC2_.data;
  
  ts_stim = tdtblk.epocs.CnA_.onset;
  idxStim = [1:length(ts_stim)]';
  
  dbsStimInfo = table(idxStim, ts_stim, CnA_onset, CnA_data, Pu1_onset, Pu1_data);
  
  
 % Create TDT-based event tables for DBS pulse events

 PeA_onset = tdtblk.epocs.PeA_.onset;
  PeA_data = tdtblk.epocs.PeA_.data;
ChnA_onset = tdtblk.epocs.ChnA.onset;
 ChnA_data = tdtblk.epocs.ChnA.data;
AmpA_onset = tdtblk.epocs.AmpA.onset;
 AmpA_data = tdtblk.epocs.AmpA.data;
 ts_pulse = tdtblk.epocs.ChnA.onset;
idxPulse = [1:length(ts_pulse)]';
  

idx_pulse2stim = zeros(size(ts_pulse));

% detect stim time concurrent with pulse time
nStims = length(ts_stim);
for iStim = 1:nStims
    its = ts_stim(iStim);
    ref = ts_pulse - its;
    idx = find(ref == min(abs(ref)));
    idx_pulse2stim(idx) = iStim;
    
end

% update indices connecting stim event with corresponding pulse events
nPulses = length(ts_pulse);
for iPulse = 1:nPulses
    if idx_pulse2stim(iPulse) == 0
        idx_pulse2stim(iPulse) = idx_pulse2stim(iPulse-1); 
        
    end
    
end

idxPulse = [1:nPulses]';
idxStim = idx_pulse2stim;

dbsPulseInfo = table(idxPulse, idxStim, ts_pulse, PeA_onset, PeA_data, ...
   ChnA_onset, ChnA_data, AmpA_onset, AmpA_data);


    otherwise
        error('asdfasdfasdgga')
        
end

end

