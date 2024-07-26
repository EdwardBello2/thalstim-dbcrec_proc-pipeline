% test script for visualizing spike activity in the context of reach event
% times and intervals of different DBS conditions
clear all

  % example multi-platform data for phase 3
rootpn = 'D:\PROJECTS\ET RO1 Preclinical\';

sessionpn = '20240131\'; % changes often

acqDatapn = [rootpn 'data-acquisition\' sessionpn];
procDatapn = [rootpn 'data-processing\' sessionpn];

TDTtankpn = 'DCNrs_pB-231206-112317\'; % changes often
% TDTtankpn = 'DCNrs_pA-231205-154908\';

TDTblock = 'Zebel-240131-121644'; % changes often
% TDTblock = 'Zebel-240122-122431';

RHDfolderpn = 'ThalDbsCxRec01_240131_121649\'; % changes often
RHDfileFirst = 'ThalDbsCxRec01_240131_121649'; % changes often

% RHDfolderpn = 'ThalDbsCxRec01_240122_122436\';
% RHDfileFirst = 'ThalDbsCxRec01_240122_122436';

acqParsedPn = [acqDatapn RHDfolderpn 'parsedMatfiles\'];
procParsedPn = [procDatapn RHDfolderpn 'parsedMatfiles\'];
procOutputPn = [procDatapn RHDfolderpn 'PSTHprelim\'];

reachInfoPn = [procDatapn RHDfolderpn 'StartpadInfo.xlsx'];
dbsInfoPn = [procDatapn RHDfolderpn 'dbsInfo.xlsx'];
 
analysisOutputRoot = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\';

outputSessionPn = [analysisOutputRoot '20240131_DCNfastigial\']; % changes often 

kilosortResultsDir = '45_1088_Kilosort_02_20_2024_01_39_39'; % changes often 

kilosortResultsPn = [outputSessionPn 'KilosortCurated\' kilosortResultsDir '\'];

curationResultsDir = 'record-1088-curation-862'; % changes often 

curationResultsPn = [outputSessionPn 'KilosortCurated\' curationResultsDir '\'];

clusterGrpCSV = 'cluster_group862_EdManualEntry.csv'; % changes often
spkCulstersNPY = 'spike_clusters862.npy'; % changes often

% Location to save series of PETH images for later viewing:
 figSavePn = [outputSessionPn 'PeriReach\'] ;
 YYYYMMDD = sessionpn(1:end-1);   
    

TDTsynapseProgram = 'ETRO1_pB'; % 'ETRO1_pA' | 'ETRO1_pB' note that for DCNrs_pA and DCNrs_pB, just use the ETRO1 suffix for now, code should do the same thing for both...

% add fullpath on your PC to the "thalstim-dbcrec_proc-pipeline" code repo
addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));
addpath(genpath('C:\Users\bello043\Downloads\rasterscripts'));
addpath(genpath('C:\Users\bello043\Documents\GitHub\spikes_psthViewerFix'));

% % % add fullpath
% % addpath(genpath('C:\Users\bello043\Downloads\rasterscripts'));
% 
% 
% % specify kilosort results directory fullpath
% myKsDir = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\sorted\163_1072_Kilosort_02_01_2024_17_46_36';
% 
% % specify the curation results .csv file fullpath
% curationTabPn = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\sorted\record-1072-curation-842\cluster_group842.csv'
% 
% % specify the updated spike cluster assignments pertaining to the curation
% % results above, fullpath
% clusterResPn = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\sorted\record-1072-curation-842\spike_clusters842.npy'
% 
% % specify the fullpath to the DBS event timing info table
% dbsInfoPn = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\dbsInfo.xlsx';
% 
% % specify the fullpath to the reach timing event info table
% reachInfoPn = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\StartpadInfo.xlsx';
% % specify the output folder fullpath, where the figure images will be saved en masse



tic
%%
% Load in sorted spike times of interest
% First crack at getting responses of neurons at eacsh of 12 specific dbs electrodes 

% Specify settings for psth viewer
% window = [0 (7.7/1000)]; % look at spike times from 0 sec before each event to 1 sec after


% load in kilosort output with spike times an cluster identities
% myKsDir = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\exKilosortOutputs\dataset\';
% myKsDir = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\163_1072_Kilosort_02_01_2024_17_46_36';
% myKsDir = 'D:\PROJECTS\ET RO1 Preclinical\data-processing\20240122\ThalDbsCxRec01_240122_120200\sorted\163_1072_Kilosort_02_01_2024_17_46_36';
sp = loadKSdir(kilosortResultsPn);



%% Load in reaching event times

reachTab = readtable(reachInfoPn);
rchTimes = reachTab.offPadTstTDT;
% hold on; scatter(rchTimes, 20*ones(1,length(rchTimes)));
% set(gca, 'YLim', [0 60])
% h = line([timestamps{k}(:)'; timestamps{k}(:)'], height,'LineWidth',1.5); 



%% load in DBS stim event times, with their metadata
dbsInfo = readtable(dbsInfoPn);

% find which # reach event pertains to DBS starting
% NOTE: for 20240122 I had to delete teh first 243 rows of dbs times,
% because we accidentally turned on stim briefly before any reaches, then
% waited for 25 reaches, then turned on stim!

i = 1;
while rchTimes(i) < dbsInfo.ts_pulse(1), i=i+1; end

dbsOnReach = i;

% 

%%

% Get 1 cell's PSTH for all 12 DBS conditions
chanLabels = unique(dbsInfo.ChnA_data);
nStimChs = length(chanLabels);
    
    
    eventTimes = dbsInfo.ts_pulseIntan;
% % if dbsInfo.ts_pulseIntan can't be found in the table, try putting _1 at
% % the end:
%     eventTimes = dbsInfo.ts_pulseIntan_1;
    
    trialGroups = dbsInfo.ChnA_data; 
%     psthViewer(sp.st, sp.clu, eventTimes, window, trialGroups);
    
% re-assign cluster ids for each spike time occurrence according to Steven's curation
% Also update the list of unique cluster ids accordingly
sp.clu = readNPY([curationResultsPn spkCulstersNPY]) ; 
sp.cids = unique(sp.clu);

tab_clGp = readtable([curationResultsPn clusterGrpCSV]);

% T = readtable(clusterResPn) ; 
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





% nCids = length(sp.cids);
nCids = height(tab_clGp);

for iCid = 1:nCids
    
    % Generate figure of single cluster responses to all 12 channels stim
    spTest = sp;
    cluster_id = tab_clGp.cluster_id(iCid);
%     idx_cid = (sp.clu == sp.cids(iCid));
    idx_cid = (sp.clu == cluster_id);

    spTest.clu = sp.clu(idx_cid);
    spTest.st = sp.st(idx_cid);
%     psthViewer(spTest.st, spTest.clu, eventTimes, window, trialGroups);
%     f1 = gcf;
%     f1.Position = [582 142 829 834];
%     
%     
%     % Save the figure as jpeg, then close it
%     idxTab = tab_clGp.cluster_id == unique(spTest.clu);
%     iGroup = tab_clGp.group{idxTab};
%     
%     
%     SaveName = ['DCN_DBS+TS_' RHDfileFirst '_Clu-' num2str(unique(spTest.clu)) '_' iGroup ];
%     title(f1.Children(3), SaveName, 'Interpreter', 'none')
%     print('-djpeg100', '-r200', [procOutputPn SaveName]); %low quality for saving
%     saveas(f1, [procOutputPn SaveName], 'fig');
%     saveas(f1, [procOutputPn SaveName], 'eps');
%     saveas(f1, [procOutputPn SaveName], 'svg');
%     close(f1)
    
    
    
    % try using Noe's PETH raster code!
%     unitName = unique(spTest.clu);
    
%     idxTab = tab_clGp.cluster_id == cluster_id;
    iGroup = tab_clGp.group{iCid};

    figure;
    periLims = [1 3]; % seconds before reach onset, seconds after
    raster_trials(spTest.st, rchTimes, periLims)
    set(gca, 'YLim', [dbsOnReach-30 dbsOnReach+60]);
    ax1 = gca;
    % posRect = [-0.5 30 1.5 30];
    % rectangle('Position', posRect, 'FaceColor', 'yellow');
     figSaveFn = [YYYYMMDD '_clu' num2str(cluster_id) '_PeriReach_DBS-OFF-ON_' iGroup];

%     title(['clu' num2str(unitName) ' reach-initiation PETH'])
    title(figSaveFn, 'Interpreter', 'none')
    yL = get(gca,'YLim'); line([0 0],yL,'Color','r','LineWidth',1.5); %zero time
    line([-periLims(1), periLims(2)],[dbsOnReach dbsOnReach],'Color','k','LineWidth',1.5); % line after which DBS started, good reference
    f1 = gcf;
    f1.Position = [496 164 869 667];

%     figSavePn = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\Peri-reach DBS figures\';
%  figSaveFn = [YYYYMMDD '_clu' num2str(unitName) '_PETH_DBS-OFF-ON_' iGroup];

        saveas(f1, [figSavePn figSaveFn], 'tiff');
%         saveas(f1, [figSavePn figSaveFn], 'fig');
% %         saveas(f1, [figSavePn figSaveFn], 'eps');
%         saveas(f1, [figSavePn figSaveFn], 'svg');
%         saveas(f1, [figSavePn figSaveFn], 'png');


    
    
    
    close(f1)
    clear f1
    
        
end

disp('DONE generating Peri-reach figures!')
toc


% 
% 
% %% Load in reaching event times
% 
% reachTab = readtable('StartpadInfo.xlsx');
% rchTimes = reachTab.offPadTstTDT;
% hold on; scatter(rchTimes, 20*ones(1,length(rchTimes)));
% set(gca, 'YLim', [0 60])
% h = line([timestamps{k}(:)'; timestamps{k}(:)'], height,'LineWidth',1.5); 
% 
% 
% 
% %% Load in DBS times 
% 
% dbsInfo = readtable('dbsInfo.xlsx');
% 
% 
% 
% %% try using Noe's PETH raster code!
% 
% addpath(genpath('C:\Users\bello043\Downloads\rasterscripts'));
% 
% figure;
% raster_trials(spikeTimes, rchTimes, [0.5 1])
% set(gca, 'YLim', [1 60]);
% ax1 = gca;
% % posRect = [-0.5 30 1.5 30];
% % rectangle('Position', posRect, 'FaceColor', 'yellow');
% title([unitName ' reach-initiation PETH'])
% yL = get(gca,'YLim'); line([0 0],yL,'Color','r','LineWidth',1.5); %zero
% f1 = gcf;
% f1.Position = [640 105 520 779];
% 
% figSavePn = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\Peri-reach DBS figures\';
% figSaveFn = ['20240119_' unitName '_PETH_DBS-OFF-ON'];
% 
% %     saveas(f1, [figSavePn figSaveFn], 'fig');
% %     saveas(f1, [figSavePn figSaveFn], 'eps');
% %     saveas(f1, [figSavePn figSaveFn], 'svg');
%     saveas(f1, [figSavePn figSaveFn], 'png');
%     
% 

