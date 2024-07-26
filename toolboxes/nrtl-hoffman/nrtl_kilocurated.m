

%Run at the "cluster_group***.csv" and spike_clusters***.npy folder
%2/5/2024 sh

%reads the curated output from the DB Cloud kilosort/spike sorting. 

T = readtable('cluster_group842.csv') ; 
ids = T.cluster_id ; %The ID of the cluster
groups = T.group ; %whether it's been curated as good (SUA), MUA, or noise
clid = zeros(size(ids)) ; %preseting
sua_counter = 0 ; %resetting
mua_counter = 0;
noise_counter = 0;
sua_ids = [] ; 
mua_ids = [];
noise_ids = [];
clid = [] ; 

for i = 1:size(ids,1)  
    if strcmp(groups{i},'good') ; %SUA
        clid(i) = 1 ; 
        sua_counter = sua_counter + 1 ; 
        sua_ids(sua_counter) = ids(i) ;
        
    elseif strcmp(groups{i},'mua') ; %MUA
        clid(i) = 2 ; 
        mua_counter = mua_counter + 1 ; 
        mua_ids(mua_counter) = ids(i) ;
        
        
    else strcmp(groups{i},'noise') ; %NOISE
        clid(i) = 3 ; 
        noise_counter = noise_counter + 1 ; 
        noise_ids(noise_counter) = ids(i) ;
        
        
    end
    
end


%Read in the curated spike clusters. 
spike_clusters842 = readNPY('spike_clusters842.npy') ; 

%Get SUA spike times ; 
SU_spikes = {} ; 
for s = 1:size(sua_ids,2) ; 
    SU_spikes{s} = find(spike_clusters842 == sua_ids(s)) ; 
end 


%To show the SU spikes times for "cluster one" you would say 
SU_spikes{1} 
