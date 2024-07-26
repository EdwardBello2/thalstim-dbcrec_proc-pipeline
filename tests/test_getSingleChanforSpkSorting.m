% test script for extracting a single clean channel of interest, and saving
% the data as a .nex file for sorting in Plexon Offline sorter


% example multi-platform data for phase 3
params.rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
params.sessionpn = '20230719\';
params.acqDatapn = [params.rootpn 'data-acquisition\' params.sessionpn];
params.procDatapn = [params.rootpn 'data-processing\' params.sessionpn];

params.TDTtankpn = 'ETRO1_pB-230419-102301\';
% TDTtankpn = 'DCNrs_pA-231205-154908\';

params.TDTblock = 'Zebel-230719-111214';
% TDTblock = 'Zebel-240122-122431';

params.RHDfolderpn = 'ThalDbsCxRec01_230719_111219\';
params.RHDfileFirst = 'ThalDbsCxRec01_230719_111219';
% RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% RHDfileFirst = 'ThalDbsCxRec01_240122_122436';

params.acqParsedPn = [params.acqDatapn params.RHDfolderpn 'parsedMatfiles\'];
params.procParsedPn = [params.procDatapn params.RHDfolderpn 'parsedMatfiles\'];
params.procOutputPn = [params.procDatapn params.RHDfolderpn 'PSTHprelim\'];

params.TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...

% include code repo for the pipeline 
addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));

% include code repo for messing with Neuroexplorer data in matlab
addpath(genpath('C:\Users\bello043\Documents\GitHub\NeuroExplorer-Matlab'));



%%

% Specify the location of parsed files, load in the metadata table
tab = readtable([params.procParsedPn 'parsedMatfilesMetadata.xlsx']);


% concatenate a sub-selected single channel of data
sgchLabel = 'A-072'; % channel of interest for spike sorting
tabSub = tab(strcmp(tab.chanLabel, sgchLabel),:);
[concatSg, ~] = concatParsed_sg(tabSub, params.procParsedPn);

% Also get the original timestamps from Intan acquisition, and exclude all
% data from negative times.. this will make lining up with DBS & TS events
% much easier...
% Construct the fully concatenated data for timestamps of the amplifier
% data
tabAcq = readtable([params.acqParsedPn 'parsedMatfilesMetadata.xlsx']);
dataType = 't_amplifier';
idxDataType= strcmp(tabAcq.dataType, dataType);
subTabTst = tabAcq((idxDataType),:);
tst = concatParsed_sg(subTabTst, params.acqParsedPn);


idxExclude = tst < 0;
tst(idxExclude) = [];
concatSg(idxExclude) = [];



% export it to a .nex file for sorting
fs = 30000;
[ nexFile ] = nexCreateFileData(fs);
nexFile = nexAddContinuous(nexFile, 0, fs, concatSg, sgchLabel); 
writeNexFilev2(nexFile, [params.procDatapn params.RHDfolderpn sgchLabel '_spkContinuous.nex'])
