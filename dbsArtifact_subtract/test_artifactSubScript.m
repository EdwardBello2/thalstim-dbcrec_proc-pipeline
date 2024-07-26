%% Remove DBS artifact using a template subtraction method

% CONSTANTS

% Peri-stimuls windowing and correction
OFFSET_CORRECT = 27; % samples; if detected stim times were several samples to the left or right of where the pulse appears in data, correct it here...
blankWin = [-4, 8]; % sample-window for blanking around stim pulse detection...


% Spike-filtering
FC = [200, 8000]; % Hz, bandpass for butterworth filter...

% Details
NCHANS = 16;
FS = 24414.0625;


 % Load one channel with stimSamps
    % data = double(SUNx_ch1);
    stimSamps_uncorr = round(stimTime_uncorr * fs_res);
%     stimSamps = stimSamps + OFFSET_CORRECT + blankWin(1); % offset by 4 samps to the left, as was done in SARGE. 
    stimSamps = stimSamps_uncorr + OFFSET_CORRECT; % offset by 4 samps to the left, as was done in SARGE. 
    stimTime = stimSamps / fs_res;
    % loffset = 0;
    % nTempl = 30;

    params.fc = FC; % Hz, bandpass filter

    % Temporarily shift stim-detection times and total blanked samples so
    % taht the desired peri-stim blank window is achieved, then remove
    % Artifacts:
    params.blankSamps = blankWin(2) - blankWin(1); % n samples to right or stim samples to blank
    
%     if isempty(stimSamps) % if no detected DBS, simply spike-filter the data...
%         
%         fc = params.fc;
%         if numel(fc) == 2
%             [b,a] = butter(2, fc / (fs_res/2), 'bandpass');
% 
%         elseif numel(fc) == 1
%             [b,a] = butter(2, fc / (fs_res/2), 'high');
% 
%         else
%             error('fc needs one or two values')
% 
%         end

%         cleanData = filtfilt(b, a, data_res);

spk = raw;
for iCh = 1:nChans
        
%     else % otherwise, remove artifacts based on detected pulses and filter
        spk(:,iCh) = remArt(raw(:,iCh), fs_res, stimSamps + blankWin(1), params);
        
%     end
    
%     spkFiltData = [spkFiltData, cleanData']; % [n x 1] vector to match output of SARGE
    
    
%     % build name for saved single-channel data and save
%     savefn = [blkDataStr(1:end-3) num2str(iCh) '_clean'];
%         
%     save([pn savefn], 'cleanData', 'stimSamps');

end



%% Create virtual pulse time events for the pre- and post- DBS portion of data

isi = median(diff(stimSamps));

% post-DBS virt pulse times
stim0 = stimSamps(end) + isi;
virtPos_idx = stim0:isi:size(spk, 1);
virtPos_idx(end) = []; % remove last index, so theres froom for blanking
virtPos_tst = tst_res(virtPos_idx);

% pre-DBS virt pulse times
stimEnd = stimSamps(1) - isi;
virtPre_idx = 1:isi:stimEnd;
virtPre_idx(1) = []; % remove first index, so theres room for blanking
virtPre_tst = tst_res(virtPre_idx);

% Create zero-blanked regions around all pulses, virtual or real
blankMask = ones(size(spk, 1), 1);

for i = 1:length(virtPre_idx)
    b0 = virtPre_idx(i) + blankWin(1);
    bend = virtPre_idx(i) + blankWin(2);
    blankMask(b0:bend) = 0;
    
end

for i = 1:length(stimSamps)
    b0 = stimSamps(i) + blankWin(1);
    bend = stimSamps(i) + blankWin(2);
    blankMask(b0:bend) = 0;
    
end

for i = 1:length(virtPos_idx)
    b0 = virtPos_idx(i) + blankWin(1);
    bend = virtPos_idx(i) + blankWin(2);
    blankMask(b0:bend) = 0;
    
end

blankMask2 = repmat(blankMask, 1, nChans);

spkClean = spk .* blankMask2;


