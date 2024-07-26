% test script for recovering one single-channel timeseries from a recording
% day, by contatenating individual mat files pertaining to the desired
% single channel of data

%% CODE
% code assumes that all 1-min long .rhd files for a given recording day have been
% parsed beforehand into single-channel 1-min long files, and that the results of this operation have been recorded in a spreasheet 



% Read in reference spreadsheet for all parsed files
pn = 'C:\Users\bello043\datatemp\data-processing\20230802\parsedMatfiles\';

cd(pn)

fn = 'parsedMatfilesMetadata.xlsx';

tab = readtable(fn);

%% subselect for the files of interest

% channel data
chanLabel = 'A-064';
experimentPhase = 'phase 1&2';

idxChanLabel = strcmp(tab.chanLabel, chanLabel);
idxExperimentPhase = strcmp(tab.experimentPhase, experimentPhase);
subTab = tab(idxChanLabel & idxExperimentPhase, :);

% concatenate files for one single-channel timeseries
subTab = sortrows(subTab, 'fileOrder'); %ensure the concatenation happens in the correct order
nFiles = height(subTab);

concatData = [];
for iFile = 1:nFiles
    iparsedFilename = subTab.parsedFilename{iFile};
    iData = load(iparsedFilename);
    concatData = [concatData iData.data];
    
end

amp_data = concatData;


% TDT sync data dig1
chanLabel = 'DIGITAL-IN-01';
experimentPhase = 'phase 1&2';

idxChanLabel = strcmp(tab.chanLabel, chanLabel);
idxExperimentPhase = strcmp(tab.experimentPhase, experimentPhase);
subTab = tab(idxChanLabel & idxExperimentPhase, :);

% concatenate files for one single-channel timeseries
subTab = sortrows(subTab, 'fileOrder'); %ensure the concatenation happens in the correct order
nFiles = height(subTab);

concatData = [];
for iFile = 1:nFiles
    iparsedFilename = subTab.parsedFilename{iFile};
    iData = load(iparsedFilename);
    concatData = [concatData iData.data];
    
end

dig1 = concatData;



% TDT data sync 2
chanLabel = 'DIGITAL-IN-02';
experimentPhase = 'phase 1&2';

idxChanLabel = strcmp(tab.chanLabel, chanLabel);
idxExperimentPhase = strcmp(tab.experimentPhase, experimentPhase);
subTab = tab(idxChanLabel & idxExperimentPhase, :);

% concatenate files for one single-channel timeseries
subTab = sortrows(subTab, 'fileOrder'); %ensure the concatenation happens in the correct order
nFiles = height(subTab);

concatData = [];
for iFile = 1:nFiles
    iparsedFilename = subTab.parsedFilename{iFile};
    iData = load(iparsedFilename);
    concatData = [concatData iData.data];
    
end

dig2 = concatData;




%% Detect & remove DBS artifacts from the data
% For now this "quick n dirty" method doesn't take advantage of TDT known
% DBS pulse times, we just manually detect artifact with threshold crossing
% for now...
addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));

% Pre-process the data prior to artifact-subtraction steps
fc = 300; % highpass filter cutoff
fs = 30000; % sampling rate of raw acquired data
[b,a] = butter(2, [fc / (fs/2)], 'high');
filt_data = filtfilt(b,a,amp_data);

% Divide the raw data into separate DBS epochs
idxOnset = diff(dig2) == 1;
idxDBSchange = [idxOnset 0];
nEpochs = sum(idxDBSchange);
begIdx = find(idxDBSchange)';
endIdx = [begIdx(2:end)-1; length(filt_data) ];

% Perform artifact subtraction on one epoch at a time
iEpoch = 1;

i_data = filt_data(begIdx(iEpoch):endIdx(iEpoch));

% detect artifact occurrences in data
idxArt = detectArt(i_data, -1000);
stimSamps = find(idxArt);

% subtract artifact waveforms from data
params.fc = [300 6000]; % Hz, bandpass filter
params.blankSamps = 30; % set all values to zero up to n samples to the right of each detected stim
[dataClean] = subtractArt(i_data, fs, stimSamps, params);
