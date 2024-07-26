% load one .rhd file

path = 'C:\Users\bello043\datatemp\';
fn = 'ThalDbsCxRec01_230519_112957';

rhd = read_Intan([path fn '.rhd']);

data = rhd.amplifier_data;
figure; plot(data(64,:));

% % convert to binary data
% binaryData = typecast(data(:), 'int16');

% Save the data to file as binary
fileID = fopen([path fn '.bin'], 'wb');
fwrite(fileID, data, 'int16');
fclose(fileID);


% read in new binary file and compare, see that there was no loss
fileID = fopen([path fn '.bin']);
A = fread(fileID, [128 Inf], '*int16');
fclose(fileID);


ch = 1;
figure; plot(data(ch,:)); hold on; plot(A(ch,:));


%% try writing multiple .rhd files to a binary without swamping the RAM!

% Specify the directory path where the files are located
directory = 'C:\Path\To\Directory';

% Get a list of all files in the directory
fileList = dir(directory);

% Create a binary file for writing the concatenated data
outputFile = 'concatenated_data.bin';
fid = fopen(outputFile, 'wb');

% Loop through each file in the directory
for i = 1:numel(fileList)
    if ~fileList(i).isdir % Check if it's not a directory
        % Construct the full file path
        filePath = fullfile(directory, fileList(i).name);
        
        % Read the data from the file
        data = fileread(filePath);
        dataInt = int16(data);
        
        % Write the data to the output file
        fwrite(fid, dataInt, 'int16');
    end
end

% Close the output file
fclose(fid);

% Display a message indicating the process completion
disp('File concatenation completed.');



