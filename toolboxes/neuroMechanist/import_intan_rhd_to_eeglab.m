function import_intan_rhd_to_eeglab(filename, output_filename)
    % import_intan_rhd_to_eeglab Import Intan RHD2000 file and save as EEGLAB .set file
    %
    %   import_intan_rhd_to_eeglab(filename, output_filename) imports an Intan RHD2000
    %   file and saves it as an EEGLAB .set file. Requires the read_Intan_RHD2000_file
    %   function and EEGLAB toolbox.
    %
    %   INPUTS:
    %   filename       - String, path to the RHD2000 file containing ECoG data
    %   output_filename - String, path to save the converted EEGLAB .set file
    %
    %   EXAMPLE:
    %   import_intan_rhd_to_eeglab('sample_data.rhd', 'output_data');
    %
    %   (c) Seyed Yahya Shirazi, SCCN, 04-16-2023

    % Check if EEGLAB is installed
    if isempty(which('eeglab'))
        error('EEGLAB toolbox is not installed or not in the MATLAB path. Please install EEGLAB and try again.');
    end

    % Load the Intan RHD2000 data
    data = read_Intan(filename);

    % Extract ECoG data (assumes ECoG data is stored in 'amplifier_channels')
    ecog_data = data.amplifier_data;

    % Extract the sampling rate
    fs = data.frequency_parameters.amplifier_sample_rate;

    % Create an EEGLAB EEG structure
    EEG = eeg_emptyset;
    EEG.setname = output_filename;
    EEG.nbchan = size(ecog_data, 1);
    EEG.srate = fs;
    EEG.data = ecog_data;
    EEG.xmin = 0;
    EEG.xmax = (size(ecog_data, 2) - 1) / fs;
    EEG.times = (0:size(ecog_data, 2) - 1) / fs;
    EEG.pnts = size(ecog_data, 2);
    EEG.trials = 1;
    EEG.filepath = fileparts(output_filename);
    EEG.filename = [output_filename '.set'];
    EEG.ref = 'common';
    
    % Add channel labels
    for i = 1:EEG.nbchan
        EEG.chanlocs(i).labels = ['Ch' num2str(i)];
    end

    % Save the EEG structure as a .set file
    pop_saveset(EEG, 'filename', output_filename,'savemode','twofiles');
end