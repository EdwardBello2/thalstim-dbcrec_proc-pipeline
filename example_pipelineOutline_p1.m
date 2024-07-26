% EXAMPLE script outline for the full pre-processing pipeline going from
% taking in the original raw data acquisition files, to preparation for
% packaging into a format that KILOSORT expects





%%  Read in files (or metadata about files), including original .rhd files,
% tdt files, and any other necessary files




%% synchronize the disparate data so that DBS events and spike events can be
% properly aligned




%% prep the data (one channel at a time? pre-filter?) for DBS artifact
% subtraction



%% Assemble the now cleaned data into one large multichannel binary file
% that Kilosort expects, taking bad channels into proper account


