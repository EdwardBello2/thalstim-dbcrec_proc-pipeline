
%% nrtl_rhd2mat_concat
%Converts all the .rhd files into one concatenated .bin file that kilosort
%can run on.
%Run at the session level (where all the .rhd files are)
%Output = concatenated_data.bin
%9/5/2023 sh

%dependencies: read_Intan.m
%clear ; close all
directory = pwd ; %run at the data directory (where the .rhd files are)
% Get a list of all files in the directory

fileList = dir('*.rhd'); %get all the .rhd files
day = '231220' ; % will eventually automate this!!!
dir = 'mat_files' ; %the folder where everything will be saved. 
%trying to figure out a way to isolate the date folder in order to add to
%the concatenated_data.bin' file. So it would be e.g.
%230728_concatenated_data.bin' ;  

%[fileList.folder] -13 :fileList.folder - 7

%Keep figureing out above for automation pipeline. 

% Create a binary file for writing the concatenated data
outputFile = [day '_concatenated'];
%fid = fopen(outputFile, 'w');
% Loop through each file in the directory
%fileID = fopen([directory,'concatedata.bin']);


if isdir(dir) %not sure why it's 7
    display('warning test dir already exsists')
    pause
    display('you sure you want to overide???') ;
    pause
    display('You totally sure, this takes a while you know')
    
    %cd('test_mat') ; 
    %mkdir('test_mat')
else
    mkdir(dir)
    display('Running a new session, should be good')
end
tic
data = [] ; 
for i = 1:size(fileList,1) %will eventually automate/loop this %size(fileList,1)
    i
    %if ~fileList(i).isdir % Check if it's not a directory
    % Construct the full file path
    % filePath = fullfile(directory, fileList(i).name);
    % Read the data from the file
    %data = fileread(filePath);
    rhd = read_Intan2('filename',fileList(i).name);
    datatemp = [] ;
    datatemp = rhd.amplifier_data;

    % Write the data to the output file
    %fileID = fopen([path fn '.bin'], 'a');


   
    if i == 1 %day one
%         %outputFile = 'concatenated_data.bin'; %change 11/27/2023 sh
%         fid = fopen(outputFile, 'w');
        data = datatemp ;
  %   fwrite(fid, data, 'uint32')   
      %  fclose(fid)
%         data = [] ;
    else
%         fid = fopen(outputFile,'a') ;
%         data = datatemp ;
%         fwrite(fid, data, 'uint32')
%         fclose(fid)
        data = [data,datatemp] ; %concatenating
    end
    %concatedata = fwrite(fid, data, 'uint32');
    %end
    
end
toc

 cd(dir)
 save(outputFile,"data",'-v7.3') ;
 cd(directory)
%fclose(fid);
% Close the output file
% Display a message indicating the process completion
disp('File concatenation completed, Bro');