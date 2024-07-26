spiketimes = data ; 

tab = readtable('cluster_group842.csv');

figure ;

rawdata = data ; 

%Just figureing out what all the Kilosort outputs are
%Reading each of the files in. 

amplitudes = readNPY('amplitudes.npy') ; 

channel_positions = readNPY('channel_positions.npy') ; 
channel_shanks = readNPY('channel_shanks.npy') ; 

% spike_clusters = readNPY('spike_clusters.npy') ; 
spike_clusters = readNPY('spike_clusters842.npy') ; 

numel(unique(spike_clusters)) 

templates = readNPY('templates.npy') ; 
templates_ind = readNPY('templates_ind.npy') ; 
similar_templates = readNPY('similar_templates.npy') ; 
spike_times = readNPY('spike_times.npy') ; 

spiketimes(1:100) ;
spiketimes(end)
numel(unique(spike_clusters)) ; 

numel(unique(spike_clusters)) ; 
rez.connected
numel(unique(spike_clusters))

cd sorted/