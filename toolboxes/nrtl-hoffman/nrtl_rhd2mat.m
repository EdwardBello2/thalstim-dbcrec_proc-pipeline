
%% nrtl_rhd2mat
%Converts all the .rhd files into .mat files
%
%Run at the session level (where all the .rhd files are)
%Output = .mat files 
%10/1/2023

%dependencies: read_Intan.m
rename = 1 ; %If rename == 1, will add a more logical .0001 file ending to them, instead of the somewhat criptic

directory = pwd ; %run at the data directory (where the .rhd files are)
mkdir data
% Get a list of all files in the directory
fileList = dir('*.rhd'); %get all the .rhd files

% outputFile = 'concatenated_data.bin';
% fid = fopen(outputFile, 'wb');
% Loop through each file in the directory
%fileID = fopen([directory,'concatedata.bin']);
for i = 1:size(fileList,1)
    %if ~fileList(i).isdir % Check if it's not a directory
    % Construct the full file path
    filePath = fullfile(directory, fileList(i).name);
    % Read the data from the file
    %data = fileread(filePath);
    rhd = read_Intan2('filename',fileList(i).name);
    data = [] ;
    data = rhd.amplifier_data;
    

    filename = fileList(i).name(1:end-4) ; %removing the ".rhd" section of the filename 
    if rename == 1  
        faddend = [num2str(zeros(1,4-numel(num2str(i)))) num2str(i)] ; %padding with up to 3 zeros in case we have up to 9,999 trials (not likely to need more, I hope at least!)
        faddend = faddend(find(~isspace(faddend))) ; 
        filename = [filename '_' faddend '.mat'] ;  %adding on the more logical naming scheme
    end
    
    cd data
    save(filename,"data")
    cd .. %This could be dangerous as we're assuming directory is just up one level

    % Write the data to the output file
    %fileID = fopen([path fn '.bin'], 'a');
   % fileID = fopen([path,'concatedata.bin'],'a'); %opening the file in append mode
    %fwrite(fid, data, 'int16','a');
    %concatedata = fwrite(fid, data, 'uchar');
    %end
end
%fclose(fid);
% Close the output file
% Display a message indicating the process completion
disp('.rhd files converted to .mat in data folder');