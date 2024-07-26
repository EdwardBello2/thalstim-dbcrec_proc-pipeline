% test script for generating a large binary file, derived from 1-minute
% long parsed mat files of all 128 channels. 

% example multi-platform data for phase 3
rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
sessionpn = '20240122\';
acqDatapn = [rootpn 'data-acquisition\' sessionpn];
procDatapn = [rootpn 'data-processing\' sessionpn];

TDTtankpn = 'DCNrs_pB-231206-112317\';
% TDTtankpn = 'DCNrs_pA-231205-154908\';

TDTblock = 'Zebel-240122-120155';
% TDTblock = 'Zebel-240122-122431';

RHDfolderpn = 'ThalDbsCxRec01_240122_120200\';
RHDfileFirst = 'ThalDbsCxRec01_240122_120200';
% RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% RHDfileFirst = 'ThalDbsCxRec01_240122_122436';

acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];

addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));

% binFilename = 'spikeDataContinuous';


tic
%% Prep pointers to data to be concatenated and written to binary

% Read in metadata table tracking all artifact cleaned data 
tab = readtable([procDatapn RHDfolderpn 'parsedMatfiles\parsedMatfilesMetadata.xlsx']);

% Keep only cleaned spike data by excluding common mode data
tabSpk = tab(~strcmp(tab.chanLabel, 'common_mode'),:);



%% Iteratively write an int16-based binary file 

binFilename = [sessionpn(1:end-1) '_' erase(tab.experimentPhase{1}, ' ') '_128spkContinuous'];


disp('Concatenating parsed multichannel data and writing large single binary file...')
fileID = fopen([procDatapn RHDfolderpn binFilename '.bin'], 'wb');

nRHDfiles = max(tabSpk.fileOrder);
for iRHDfile = 1:nRHDfiles
    
    % join the 128 channels for each RHD file
    tabiRHD = tabSpk((tabSpk.fileOrder == iRHDfile),:);
    
    nChans = height(tabiRHD);
    dataJoin = zeros(nChans,tabiRHD.nsamples(1)); % all rows will specify the same number of samples, just pick one
    for iChan = 1:nChans
        load([procParsedPn tabiRHD.parsedFilename{iChan}]); % loads variable called "data"
        dataJoin(iChan,:) = data;
        
    end
    
    % write to open binary file
    dataJoinInt = int16(dataJoin);
    fwrite(fileID, dataJoinInt, 'int16');
    
end

fclose(fileID);

disp('done!')

toc
