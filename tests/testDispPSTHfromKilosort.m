% test script for generating peristimulus time histograms 

clear all


%% 20230712_Cx

 % example multi-platform data for phase 3
rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';

sessionpn = '20230712\'; % 20240119_DCNinterposed

acqDatapn = [rootpn 'data-acquisition\' sessionpn];
procDatapn = [rootpn 'data-processing\' sessionpn];

TDTtankpn = 'ETRO1_pB-230419-102301\'; % 20240119_DCNinterposed

TDTblock = 'Zebel-230712-124842'; % 20240119_DCNinterposed

RHDfolderpn = 'ThalDbsCxRec01_230712_124848\'; % 
RHDfileFirst = 'ThalDbsCxRec01_230712_124848'; % 2


acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
procOutputPn = [procDatapn RHDfolderpn 'PSTHprelim\'];

reachInfoPn = [procDatapn RHDfolderpn 'StartpadInfo.xlsx'];
dbsInfoPn = [procDatapn RHDfolderpn 'dbsInfo.xlsx'];
 
analysisOutputRoot = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\';

outputSessionPn = [analysisOutputRoot '20230712_Cx\']; % changes often 

kilosortResultsDir = '45_1086_Kilosort_02_18_2024_18_28_34'; % 20240205_DCNdentate 

kilosortResultsPn = [outputSessionPn 'KilosortCurated\' kilosortResultsDir '\'];

curationResultsDir = 'record-1086-curation-859'; % 20240205_DCNdentate 

curationResultsPn = [outputSessionPn 'KilosortCurated\' curationResultsDir '\'];

clusterGrpCSV = 'cluster_group859_EdManualEntry.csv'; % 20240205_DCNdentate
spkCulstersNPY = 'spike_clusters859.npy'; % 20240205_DCNdentate

% Location to save series of PETH images for later viewing:
 figSavePn = [outputSessionPn 'PeriReach\'] ;
 YYYYMMDD = sessionpn(1:end-1);   
 


%% 20240119_DCNinterposed

%  % example multi-platform data for phase 3
% rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
% 
% sessionpn = '20240119\'; % 20240119_DCNinterposed
% 
% acqDatapn = [rootpn 'data-acquisition\' sessionpn];
% procDatapn = [rootpn 'data-processing\' sessionpn];
% 
% TDTtankpn = 'DCNrs_pB-231206-112317\'; % 20240119_DCNinterposed
% 
% TDTblock = 'Zebel-240119-123221'; % 20240119_DCNinterposed
% 
% RHDfolderpn = 'ThalDbsCxRec01_240119_123226\'; % 
% RHDfileFirst = 'ThalDbsCxRec01_240119_123226'; % 2
% 
% 
% acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
% procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
% procOutputPn = [procDatapn RHDfolderpn 'PSTHprelim\'];
% 
% reachInfoPn = [procDatapn RHDfolderpn 'StartpadInfo.xlsx'];
% dbsInfoPn = [procDatapn RHDfolderpn 'dbsInfo.xlsx'];
%  
% analysisOutputRoot = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\';
% 
% outputSessionPn = [analysisOutputRoot '20240119_DCNinterposed\']; % changes often 
% 
% kilosortResultsDir = '163_1074_Kilosort_02_08_2024_04_29_43'; % 20240205_DCNdentate 
% 
% kilosortResultsPn = [outputSessionPn 'KilosortCurated\' kilosortResultsDir '\'];
% 
% curationResultsDir = 'record-1074-curation-857'; % 20240205_DCNdentate 
% 
% curationResultsPn = [outputSessionPn 'KilosortCurated\' curationResultsDir '\'];
% 
% clusterGrpCSV = 'cluster_group857_EdManualEntry.csv'; % 20240205_DCNdentate
% spkCulstersNPY = 'spike_clusters857.npy'; % 20240205_DCNdentate
% 
% % Location to save series of PETH images for later viewing:
%  figSavePn = [outputSessionPn 'PeriReach\'] ;
%  YYYYMMDD = sessionpn(1:end-1);   
 


%% 20240131_DCNfastigial

%  % example multi-platform data for phase 3
% rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
% 
% sessionpn = '20240131\'; % 20240119_DCNinterposed
% 
% acqDatapn = [rootpn 'data-acquisition\' sessionpn];
% procDatapn = [rootpn 'data-processing\' sessionpn];
% 
% TDTtankpn = 'DCNrs_pB-231206-112317\'; % 
% 
% TDTblock = 'Zebel-240131-121644'; % 
% 
% RHDfolderpn = 'ThalDbsCxRec01_240131_121649\'; % 
% RHDfileFirst = 'ThalDbsCxRec01_240131_121649'; % 2
% 
% 
% acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
% procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
% procOutputPn = [procDatapn RHDfolderpn 'PSTHprelim\'];
% 
% reachInfoPn = [procDatapn RHDfolderpn 'StartpadInfo.xlsx'];
% dbsInfoPn = [procDatapn RHDfolderpn 'dbsInfo.xlsx'];
%  
% analysisOutputRoot = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\';
% 
% outputSessionPn = [analysisOutputRoot '20240131_DCNfastigial\']; % changes often 
% 
% kilosortResultsDir = '45_1088_Kilosort_02_20_2024_01_39_39'; % 20240205_DCNdentate 
% 
% kilosortResultsPn = [outputSessionPn 'KilosortCurated\' kilosortResultsDir '\'];
% 
% curationResultsDir = 'record-1088-curation-862'; % 20240205_DCNdentate 
% 
% curationResultsPn = [outputSessionPn 'KilosortCurated\' curationResultsDir '\'];
% 
% clusterGrpCSV = 'cluster_group862_EdManualEntry.csv'; % 20240205_DCNdentate
% spkCulstersNPY = 'spike_clusters862.npy'; % 20240205_DCNdentate
% 
% % Location to save series of PETH images for later viewing:
%  figSavePn = [outputSessionPn 'PeriReach\'] ;
%  YYYYMMDD = sessionpn(1:end-1);   
%  


%% 20240205_DCNdentate
    
%  % example multi-platform data for phase 3
% rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';
% 
% sessionpn = '20240205\'; % 20240205_DCNdentate
% 
% acqDatapn = [rootpn 'data-acquisition\' sessionpn];
% procDatapn = [rootpn 'data-processing\' sessionpn];
% 
% TDTtankpn = 'DCNrs_pB-231206-112317\'; %
% TDTblock = 'Zebel-240205-120704'; % 20240119_DCNinterposed
% 
% RHDfolderpn = 'ThalDbsCxRec01_240205_120709\'; % 20240205_DCNdentate
% RHDfileFirst = 'ThalDbsCxRec01_240205_120709'; % 20240205_DCNdentate
% 
% acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
% procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
% procOutputPn = [procDatapn RHDfolderpn 'PSTHprelim\'];
% 
% reachInfoPn = [procDatapn RHDfolderpn 'StartpadInfo.xlsx'];
% dbsInfoPn = [procDatapn RHDfolderpn 'dbsInfo.xlsx'];
%  
% analysisOutputRoot = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\';
% 
% outputSessionPn = [analysisOutputRoot '20240205_DCNdentate\']; % changes often 
% 
% kilosortResultsDir = '163_1075_Kilosort_02_09_2024_03_30_42'; % 20240205_DCNdentate 
% 
% kilosortResultsPn = [outputSessionPn 'KilosortCurated\' kilosortResultsDir '\'];
% 
% curationResultsDir = 'record-1075-curation-846'; % 20240205_DCNdentate 
% 
% curationResultsPn = [outputSessionPn 'KilosortCurated\' curationResultsDir '\'];
% 
% clusterGrpCSV = 'cluster_group846_EdManualEntry.csv'; % 20240205_DCNdentate
% spkCulstersNPY = 'spike_clusters846.npy'; % 20240205_DCNdentate
% 
% % Location to save series of PETH images for later viewing:
%  figSavePn = [outputSessionPn 'PeriReach\'] ;
%  YYYYMMDD = sessionpn(1:end-1);   
    
 
 %% common

TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...

% add fullpath on your PC to the "thalstim-dbcrec_proc-pipeline" code repo
addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));
addpath(genpath('C:\Users\bello043\Downloads\rasterscripts'));
addpath(genpath('C:\Users\bello043\Documents\GitHub\spikes_psthViewerFix'));

tic
%% First crack at getting responses of neurons at eacsh of 12 specific dbs electrodes 

% Specify settings for psth viewer
window = [0 (7.7/1000)]; % look at spike times from 0.3 sec before each event to 1 sec after


% load in kilosort output with spike times an cluster identities
% myKsDir = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\exKilosortOutputs\dataset\';
% myKsDir = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\163_1072_Kilosort_02_01_2024_17_46_36';

% myKsDir = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\sorted\163_1072_Kilosort_02_01_2024_17_46_36';
% sp = loadKSdir(myKsDir);

sp = loadKSdir(kilosortResultsPn);





% load in DBS stim event times, with their metadata
dbsInfo = readtable([procDatapn RHDfolderpn 'dbsInfo.xlsx']);

% Get 1 cell's PSTH for all 12 DBS conditions
chanLabels = unique(dbsInfo.ChnA_data);
nStimChs = length(chanLabels);


% for each DBS setting
% for iStimCh = 1:nStimChs
%     subplot(3,4,iStimCh)
%     
%     % get indices of DBS pulse event pertaining to iChannel
%     idx_iStimCh = dbsInfo.ChnA_data == chanLabels(iStimCh);
%     eventTimes = dbsInfo.ts_pulseIntan(idx_iStimCh);
%     
%     trialGroups = ones(size(eventTimes)); 
% 
%     psthViewer(sp.st, sp.clu, eventTimes, window, trialGroups);
    
    
%     eventTimes = dbsInfo.ts_pulseIntan + (1+0.0035); % necessary for 20230719
%     eventTimes = dbsInfo.ts_pulseIntan + (0.0012); % necessary for 20230719
%     eventTimes = dbsInfo.ts_pulseIntan + (0.001); % necessary for 20230719
%     eventTimes = dbsInfo.ts_pulseIntan + (0.0015); % necessary for 20240205
%     eventTimes = dbsInfo.ts_pulseIntan + (0.0005); % necessary for 20240119

    eventTimes = dbsInfo.ts_pulseIntan; % necessary for 20240131

    trialGroups = dbsInfo.ChnA_data; 
%     psthViewer(sp.st, sp.clu, eventTimes, window, trialGroups);
    
% re-assign cluster ids for each spike time occurrence according to Steven's curation
% Also update the list of unique cluster ids accordingly


spike_clusters = readNPY([curationResultsPn spkCulstersNPY]) ; 
sp.clu = spike_clusters;
% sp.cids = unique(sp.clu);

tab_clGp = readtable([curationResultsPn clusterGrpCSV]);
sp.cids = tab_clGp.cluster_id;


% T = readtable([curationPn 'cluster_group842.csv']) ; 
% ids = T.cluster_id ; %The ID of the cluster
% groups = T.group ; %whether it's been curated as good (SUA), MUA, or noise
% clid = zeros(size(ids)) ; %preseting
% sua_counter = 0 ; %resetting
% mua_counter = 0;
% noise_counter = 0;
% sua_ids = [] ; 
% mua_ids = [];
% noise_ids = [];
% clid = [] ; 
% 
% for i = 1:size(ids,1)  
%     if strcmp(groups{i},'good') ; %SUA
%         clid(i) = 1 ; 
%         sua_counter = sua_counter + 1 ; 
%         sua_ids(sua_counter) = ids(i) ;
%         
%     elseif strcmp(groups{i},'mua') ; %MUA
%         clid(i) = 2 ; 
%         mua_counter = mua_counter + 1 ; 
%         mua_ids(mua_counter) = ids(i) ;
%         
%         
%     else strcmp(groups{i},'noise') ; %NOISE
%         clid(i) = 3 ; 
%         noise_counter = noise_counter + 1 ; 
%         noise_ids(noise_counter) = ids(i) ;
%         
%         
%     end
%     
% end





nCids = length(sp.cids);
for iCid = 1:nCids
    
    % Generate figure of single cluster responses to all 12 channels stim
    spTest = sp;
    
    idx_cid = (sp.clu == sp.cids(iCid));
    spTest.clu = sp.clu(idx_cid);
    spTest.st = sp.st(idx_cid);
    psthViewer(spTest.st, spTest.clu, eventTimes, window, trialGroups);
    f1 = gcf;
    f1.Position = [381 158 1299 674];
    
    
    % Save the figure as jpeg, then close it
    idxTab = tab_clGp.cluster_id == unique(spTest.clu);
    iGroup = tab_clGp.group{idxTab};
    
    
%     SaveName = ['DCN_DBS+TS_' RHDfileFirst '_Clu-' num2str(unique(spTest.clu)) '_' iGroup ];
    SaveName = ['DCN_DBS+TS_' RHDfileFirst '_Clu-' num2str(unique(spTest.clu)) '_' iGroup '_cm'];

    title(f1.Children(3), SaveName, 'Interpreter', 'none')
    print('-djpeg100', '-r200', [outputSessionPn 'PSTHs\' SaveName]); %low quality for saving
    saveas(f1, [outputSessionPn 'PSTHs\' SaveName], 'tiff');
    saveas(f1, [outputSessionPn 'PSTHs\' SaveName], 'fig');
    saveas(f1, [outputSessionPn 'PSTHs\' SaveName], 'svg');
    close(f1)
    clear f1
    
    
        
end

disp('DONE generating PSTH figures!')
toc


% %% 
% %reads the curated output from the DB Cloud kilosort/spike sorting. 
% 
% T = readtable('cluster_group842.csv') ; 
% ids = T.cluster_id ; %The ID of the cluster
% groups = T.group ; %whether it's been curated as good (SUA), MUA, or noise
% clid = zeros(size(ids)) ; %preseting
% sua_counter = 0 ; %resetting
% mua_counter = 0;
% noise_counter = 0;
% sua_ids = [] ; 
% mua_ids = [];
% noise_ids = [];
% clid = [] ; 
% 
% for i = 1:size(ids,1)  
%     if strcmp(groups{i},'good') ; %SUA
%         clid(i) = 1 ; 
%         sua_counter = sua_counter + 1 ; 
%         sua_ids(sua_counter) = ids(i) ;
%         
%     elseif strcmp(groups{i},'mua') ; %MUA
%         clid(i) = 2 ; 
%         mua_counter = mua_counter + 1 ; 
%         mua_ids(mua_counter) = ids(i) ;
%         
%         
%     else strcmp(groups{i},'noise') ; %NOISE
%         clid(i) = 3 ; 
%         noise_counter = noise_counter + 1 ; 
%         noise_ids(noise_counter) = ids(i) ;
%         
%         
%     end
%     
% end
% 
% 
% %Read in the curated spike clusters. 
% spike_clusters = readNPY('spike_clusters842.npy') ; 
% 
% 
% 
%     
%     
% %% Copied Noe's code below:
% %%% each channel is a different figure
% %%% each subplot is a different stim electrode
% 
% ExpInfo.Subject_ID = 'Zebel';
% ExpInfo.Experiment = 'Phase3';
% ExpInfo.Date = '20240131';
% ExpInfo.Target = 'DCN';
% 
% ch_rec = 1; %1:128
%     disp(['Ch rec : ' num2str(ch_rec)]);
%     f1=figure(ch_rec); hold on
%     SaveName = [ExpInfo.Subject_ID '_' ExpInfo.Target '_' ExpInfo.Experiment '_' ExpInfo.Date '_RecCh' num2str(ch_rec)];
% 
% 
% %% open data
% 
% %% extract the data
% 
%     for ch_stim = 1:12 %1:12
% 
%         
% % % %         x - x axis
% % % %         y1 - y axis 1
% % % %         y2 - y axis 2
% 
%         %% plot the data
%         ax(ch_stim) = subplot(3,4,ch_stim); hold on; %grid on
%         x = rand(10,1);
%         plot(x,'Color','b','LineWidth',1)
%         plot(x*ch_stim,'Color','r','LineWidth',1)
% 
%         title(['Stim Elec ' num2str(ch_stim)]);
% 
%         %xlabel('time (sec) 0 indicates first peak','FontSize',16)
% 
%     end
%     sgtitle([ExpInfo.Subject_ID ' ' ExpInfo.Target ' ' ExpInfo.Experiment ' ' ExpInfo.Date '. Recording: Ch ' num2str(ch_rec)]) 
% 
%     linkaxes(ax,'x');
%     %%linkaxes %%to link both x and y
% 
% 
% %% %%figure size/ orientation
% screen_size = get(0, 'ScreenSize'); %get screen resolution
% set(f1, 'Position', [0 0 screen_size(3) screen_size(4)] );
% figure_prop_name = {'PaperPositionMode','units','Position'};
% figure_prop_val =  { 'auto'            ,'inches', [0.25 0.25 10.5 8]};%left bottom width height
% set(f1,'PaperOrientation', 'landscape', 'PaperPositionMode', 'auto','units', 'inches', 'Position', [0.25 0.25 18 13])
% 
% %% %%saving figure
% saveas(f1,['plots\' SaveName], 'fig'); %figure format
% print('-djpeg100', '-r200', ['plots\' SaveName]); %low quality for saving
% 
% 
% % saveas(f1,['plots\' SaveName], 'svg'); %figure format
% 
% %for actual posters/ papers - open matlab figure and run this line
% % print -dtiff -r1200 name1; %high quality for posters/ papers - takes a long time
% %%%'svg' format for final figures
% 
% close all
% 
% 
% 
% 
