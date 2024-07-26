% test script for visualizing spike activity in the context of reach event
% times and intervals of different DBS conditions
clear


addpath(genpath('C:\Users\bello043\Documents\GitHub\thalstim-dbcrec_proc-pipeline'));
addpath(genpath('C:\Users\bello043\Documents\GitHub\NeuroExplorer-Matlab'));

%%


% Load in sorted spike times of interest
nexFilename = 'A-061_spkContinuous_sorted.nex';
unitIdx = 2;
n = readNexFile(nexFilename);
spikeTimes = n.neurons{unitIdx,1}.timestamps; % seconds
unitName = n.neurons{unitIdx,1}.name;
binSize = 0.1; % seconds
tst = n.tbeg:binSize:n.tend;
% spikeLogical = zeros(1,length(tst));
% 
% h = histogram(spikeTimes, tst);
% 
% 
% % convert 
% nSpks = length(spikeTimes);
% i = 1; % initialize the index 
% for iSpk = 1:nSpks
%     iSpkTime = spikeTimes(iSpk);
%     
%     while tst(i) < iSpkTime
%         i = i + 1;
%         
%     end
%     
%     spikeLogical(i) = 1;
%     
% end


% % plot an estimate of spike rate over time
% if nargin < 2 || isempty(binSize); binSize = 0.05; end % in seconds
% if nargin < 3 || isempty(kernelWindow); kernelWindow = 2; end % in seconds 
% if nargin < 4 || isempty(tau); tau = 0.1; end 
% if nargin < 5 || isempty(alpha); alpha = 20; end 
% % spike counts
% % [Nhist,edges] = histcounts(1000*spikeTimes,'BinWidth',1000*binSize);
% [Nhist,edges] = histcounts(spikeTimes,'BinWidth',binSize);
% 
% sprate = Nhist./binSize;
% tbins = edges(1:end-1)./1000;
% 
% % causal kernel (alpha function)
% kernelWindow = 1; 
% tau = 0.1;
% alpha = 20;
% kernelT = -kernelWindow/2 : binSize : kernelWindow/2; % kernel length default 2s
% kernel = (kernelT.*(alpha^2).*tau).*exp(-alpha.*tau.*kernelT).* (kernelT > 0);
% kernel = kernel / sum(kernel); % normalize kernel so its integral is 1
% 
% % Convolve firing rates with kernel to obtain smoothed PSTH
% frEst = conv(spikeLogical, kernel, 'same');
% 
% figure; plot(tst, spikeLogical); hold on; plot(tst, frEst);


%% try using Noe's PETH raster code!

addpath(genpath('C:\Users\bello043\Downloads\rasterscripts'));

figure;
raster_trials(spikeTimes, rchTimes, [0.5 1])
set(gca, 'YLim', [1 60]);
ax1 = gca;
% posRect = [-0.5 30 1.5 30];
% rectangle('Position', posRect, 'FaceColor', 'yellow');
title([unitName ' reach-initiation PETH'])
yL = get(gca,'YLim'); line([0 0],yL,'Color','r','LineWidth',1.5); %zero
f1 = gcf;
f1.Position = [640 105 520 779];

figSavePn = 'L:\Shared drives\Johnson\Lab Projects\Project - ET RO1 preclinical\docs\RO1 Grant\2024_RO1_Renewal\Peri-reach DBS figures\';
figSaveFn = ['20240119_' unitName '_PETH_DBS-OFF-ON'];

    saveas(f1, [figSavePn figSaveFn], 'fig');
    saveas(f1, [figSavePn figSaveFn], 'eps');
    saveas(f1, [figSavePn figSaveFn], 'svg');
    saveas(f1, [figSavePn figSaveFn], 'png');
    

%% Load in reaching event times

reachTab = readtable('StartpadInfo.xlsx');
rchTimes = reachTab.offPadTstTDT;
hold on; scatter(rchTimes, 20*ones(1,length(rchTimes)));
set(gca, 'YLim', [0 60])
h = line([timestamps{k}(:)'; timestamps{k}(:)'], height,'LineWidth',1.5); 


%% Load in DBS times 

dbsInfo = readtable('dbsInfo.xlsx');





%% try implementing nStat for perievent spike rasters...

