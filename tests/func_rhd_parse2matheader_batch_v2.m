function parsedMatfilesMetadata = func_rhd_parse2matheader_batch_v2(RHDfullpath, parseMatDir)
% script for converting a batch of .rhd "traditional" to many smaller files in .mat format. For the type
% of recording that's running during the experimental protocol, an .rhd
% file with all recording info is generated for every 1 min of recording.
% The idea is to parse out all relevant data into smaller chunks and save
% them as .mat files for ease of loading -- currently each file is pretty
% big and takes a while to load!
% 
% NOTE on v2: identical to "" except that RHDfullpath and parseMatDir are
% specified at the level of function call rather than being passed in as
% fields of a struct constrained by the same name for the fields with every
% function call. Better this way.



%% Input defined by rhd metadata table
tic
% clear; 
% addpath(genpath('C:\Users\bello043\Documents\GitHub\ET-RO1-preclinical'));

% cd 'C:\Users\bello043\datatemp\ThalDbsCxRec01_230524_230524_113017'
% cd 'D:\PROJECTS\ET RO1 Preclinical\data-acquisition\20240122\ThalDbsCxRec01_240122_122436'
% RHDfullpath = [p.acqDatapn p.RHDfolderpn];
cd(RHDfullpath);


% parseMatDir = p.acqParsedPn;

list = ls('*.rhd')

% convert character array to cells
nFiles = size(list,1);
for iFile = 1:nFiles
    filename(iFile,1) = {list(iFile,:)};
    
end

% load spreadsheet of rhd files
% [file, path, idx] = uigetfile();
% inputTab = readtable([path file]);
inputTab = cell2table(filename);



tic
%% Run thru each file, parse it into mat files, collected parsed file
% metadata
sessTab = table();

nFiles = height(inputTab);
f = waitbar(0, ['0 of ' num2str(nFiles) ' files parsed'])

for iFile = 1:nFiles
    % Create updated matlab header as "rhd", also write parsed mat files
    rhdname = strrep(inputTab.filename{iFile}, '''', '');
    rhd = read_Intan([rhdname]);
%     rhd_parse2headermat(rhd, 'writefiles', true);
    rhd = rhd_parse2headermat(rhd, 'writefiles', true, ...
        'parsedDir', ...
        parseMatDir);
    
    % Specify table object from parsedDataPointer field
    itab = struct2table(rhd.parsedDataPointer);
    nRows = height(itab);
    itab.filename(1:nRows) = inputTab.filename(iFile);
    itab.fileOrder(1:nRows) = iFile;
    
    % Update overall table from session of .rhd files
    sessTab = [sessTab; itab];
    
    waitbar(iFile/nFiles, f, [num2str(iFile), ' of ', num2str(nFiles), ...
        ' files parsed'])
    
end

% join the input table and session parsed table for full info on each
% parsed file, then save in same parsed mat file directory!
parsedMatfilesMetadata = join(sessTab, inputTab);
writetable(parsedMatfilesMetadata, [parseMatDir, 'parsedMatfilesMetadata.xlsx']);
toc

end


% nFiles = length(file);
% T = table;
% fileNum = zeros(nFiles,1);
% f = waitbar(0, ['0 of ' num2str(nFiles) ' files parsed'])
% for iFile = 1:nFiles
%     rhd = read_Intan([path file{iFile}]);
% %     rhd_parse2headermat(rhd, 'writefiles', true);
%     rhd = rhd_parse2headermat(rhd, 'writefiles', true);
% 
% %     fileNum = ones(height(T_iFile), 1) * iFile;
% %     T_iFile = [table(fileNum), T_iFile];
% %     T = [T; T_iFile];
%     
%     waitbar(iFile/nFiles, f, [num2str(iFile), ' of ', num2str(nFiles), ...
%         ' files parsed'])
%     
% end
% 
% 
% 
% %% Code
% 
% 
% 
% % % Specify one .rhd file to load
% % pn = 'C:\Users\bello043\IntanToNWB\IntanToNWB-main\';
% % fn = 'ThalDbsCxRec01_230519_111757.rhd';
% 
% % select a range of .rhd files to parse and convert to .mat files
% [file, path, idx] = uigetfile('*.rhd', 'MultiSelect','on');
% % if file == 0
% %     error('No file chosen!')
% %     
% % end
% 
% 
% % Parse and save each .rhd files variables
% % By default the save location will be the same as the load location
% 
% nFiles = length(file);
% T = table;
% fileNum = zeros(nFiles,1);
% f = waitbar(0, ['0 of ' num2str(nFiles) ' files parsed'])
% for iFile = 1:nFiles
%     rhd = read_Intan([path file{iFile}]);
% %     rhd_parse2headermat(rhd, 'writefiles', true);
%     rhd = rhd_parse2headermat(rhd, 'writefiles', true);
% 
% %     fileNum = ones(height(T_iFile), 1) * iFile;
% %     T_iFile = [table(fileNum), T_iFile];
% %     T = [T; T_iFile];
%     
%     waitbar(iFile/nFiles, f, [num2str(iFile), ' of ', num2str(nFiles), ...
%         ' files parsed'])
%     
% end
% 
% % % write the table of metadata for the parsed mat files
% % [~,tabfn,~] = fileparts(file{1});
% % writetable(T, [path tabfn '.csv' ]);
% 
% % 
% toc
