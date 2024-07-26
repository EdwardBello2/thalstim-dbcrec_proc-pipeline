% script for testing the following: 
% Reading in just one 1-min window of rhd data "parsed" .mat version, so
% that we can test dbs event detection, cross-channel cleaning, and dbs art
% subtraction

% example multi-platform data for phase 3
datapn = 'D:\PROJECTS\ET RO1 Preclinical\data-acquisition\20240122\';

TDTtank = 'DCNrs_pB-231206-112317';
TDTblock = 'Zebel-240122-120155';

RHDfolder = 'ThalDbsCxRec01_240122_120200';
RHDfileFirst = 'ThalDbsCxRec01_240122_120200';

addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));


%% read in TDT-related info, extract DBS event times

blk = TDTbin2mat([datapn TDTtank '\' TDTblock]);
[dbsStimInfo, dbsPulseInfo] = TDT2dbsinfo(blk, 'ETRO1_pB');


%% read in Intan related parsed info

% read in parsedMatfilesMetadata table
tab = readtable([datapn RHDfolder '\parsedMatfiles\parsedMatfilesMetadata.xlsx']);

% select one window of parsed files 
windowNum = 4;
idxWin = tab.fileOrder == windowNum;

% populate a matrix of corresponding amplifier data
idxAmp = strcmp(tab.dataType, 'amplifier_data');
subTab = tab((idxWin & idxAmp),:);

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

figure; plot(ampRaw(1,:))

% get corresponding timestamps for amplifier data
idxTstAmp = strcmp(tab.dataType, 't_amplifier');
tTab = tab((idxWin & idxTstAmp),:);
load([fileFullpath tTab.parsedFilename{:}]); % loads variable called "data"
tst = data;



%% See about detecting DBS artifacts in Intan using TDT times
offset = -52; % number of samples & direction (+/1) to offset TDT-based dbs event detection in Intan data

% subselect DBS onsets by time window
idxDbsWin = (dbsPulseInfo.ts_pulse >= min(tst)) & ...
    (dbsPulseInfo.ts_pulse < max(tst)); 

dbsSub = dbsPulseInfo(idxDbsWin,:);


iPulse = 3154;
% find Intan timestamp closest the DBS pulse timestamp
ptime_TDT = dbsSub.ts_pulse(iPulse);
[difSm, sampClose] = min(abs(tst - ptime_TDT));
tstClosest = tst(sampClose + offset);

figure; 
plot(tst,ampRaw(1,:)); hold on;
scatter(tstClosest, 0);


%% mess around with commmon mode rejection

ampRawMed = median(ampRaw,1);
ampRawSub = ampRaw - ampRawMed;

% compare filtered versions of the signal
fc = 300;
fs = 30000;
[b,a] = butter(2, [fc/(fs/2)], 'high');

figure; plot(filtfilt(b,a,ampRaw(100,:)));
hold on
plot(filtfilt(b,a,ampRawSub(100,:)));

%% mess around with detecting artifacts in Intan data based on TDT timing info

offset = -54; % number of samples & direction (+/1) to offset TDT-based dbs event detection in Intan data
nPulses = height(dbsSub);
ts_pulse_TDT = dbsSub.ts_pulse;
ts_pulse_Intan = zeros(nPulses,1);
samp_pulse_Intan = zeros(nPulses,1);

for iPulse = 1:nPulses
    % find Intan timestamp closest the DBS pulse timestamp
%     ptime_TDT = dbsSub.ts_pulse(iPulse);
    [difSm, samp_pulse_Intan(iPulse)] = min(abs(tst - ts_pulse_TDT(iPulse)));
    ts_pulse_Intan(iPulse) = tst(samp_pulse_Intan(iPulse) + offset);
    
end


% get mode-subtracted & filtered version of signal
fc = 300;
fs = 30000;
[b,a] = butter(2, [fc/(fs/2)], 'high');
sig = filtfilt(b,a,ampRawSub(100,:));

samp_pulse_IntanCorr = samp_pulse_Intan + offset;

% sampWin = floor((7.5/1000) * fs);
sampWin = median(diff(samp_pulse_IntanCorr));


[Segs,SegIndices] = segments(sig, samp_pulse_Intan(1:end-1) + offset, [0 sampWin]);

figure; plot(Segs')


%% Try removing artifacts by simple blanking around known pulse times..


blankWin = ones(1,46);
offsetConv = floor(length(blankWin)/2);
L = length(ampRaw);
eventMask = zeros(1,L);
eventMask(samp_pulse_IntanCorr + offsetConv) = 1;

blankMask = conv(eventMask, blankWin, 'same');
blankMask = not(blankMask); % so that when multiplying the mask with the signal you'll zero out event data
figure; plot(eventMask); hold on; plot(blankMask);

sigClean = sig.*blankMask;
figure; plot(sigClean);
sampWin = median(diff(samp_pulse_IntanCorr));
[Segs,SegIndices] = segments(sigClean, samp_pulse_IntanCorr(1:end-1), [0 sampWin]);
figure; plot(Segs')

% final filtering & extra blanking step
fc = [300 10000];
fs = 30000;
[b,a] = butter(2, fc/(fs/2), 'bandpass');
sigFilt = filtfilt(b,a,sigClean);

sigFinal = sigFilt.*blankMask;

figure; plot(sigClean); hold on; 
plot(sigFilt); 
plot(sigFinal);


%% try removeing artifacts with good ol' dynamic average

figure; plot(ampRawSub(100,:));

fs = 30000;
stimSamps = samp_pulse_IntanCorr;
params.blankSamps = 46;
params.fc = 300;
[dataClean] = subtractArt(ampRawSub(100,:), fs, stimSamps(1:end-1), params);
figure; plot(dataClean)

dataClean = dataClean.*blankMask;
hold on; plot(dataClean)


%% Compare simple highpass vs bandpass versions




fs = 30000;
stimSamps = samp_pulse_IntanCorr;
params.blankSamps = 46;

params.fc = 300;
[dataClean] = subtractArt(ampRawSub(100,:), fs, stimSamps(1:end-1), params);
dataClean = dataClean.*blankMask;
figure; plot(dataClean)



params.fc = [300 10000];
[dataClean] = subtractArt(ampRawSub(100,:), fs, stimSamps(1:end-1), params);
dataClean = dataClean.*blankMask;
hold on; plot(dataClean)





