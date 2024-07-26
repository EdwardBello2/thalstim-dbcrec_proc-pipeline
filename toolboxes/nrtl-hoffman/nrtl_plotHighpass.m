


%might need to highpass the data first
%also need to convert to seconds/ms (not samples)

sr = 30000 ; %sampling rate (Hz)
ms = 1000 ; %converting to miliseconds
trials = dir('Thal*') %loading up trials list
for t = 1:size(trials,1) %looping through trials
load(trials(t).name) 
trials(t).name
hp_data = nptHighPassFilter(data,30000,300,8000) ; %highpassing the data, from 300-8kHz 
for c = 1:size(hp_data,1) %looping through channels
    c
    figure('Units','Normalized','Position',[.25 .25 0.8 .25]) 
    plot(hp_data(c,:)) ;  
    fig = gca ; fig.TickDir = 'out' ; 
    labs = fig.XTickLabel ; %this is really stupid, please forgive me, but I'm just converting the labels to ms
    for l = 1:size(labs,1) %converting access to ms
        fig.XTickLabel{l} = num2str(str2num(labs{l}) / (sr) ) ; %I know this is dumb, but it's for transparance 
    end
    fig.XTick = 1: length(data)/10 : length(data) ; 
    shg ;pause ; close ; 
    
end
end

