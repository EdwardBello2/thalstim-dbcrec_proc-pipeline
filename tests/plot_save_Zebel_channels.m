%%%%%% 

%%% each channel is a different figure
%%% each subplot is a different stim electrode

ExpInfo.Subject_ID = 'Zebel';
ExpInfo.Experiment = 'Phase3';
ExpInfo.Date = '20240131';
ExpInfo.Target = 'DCN';

ch_rec = 1; %1:128
    disp(['Ch rec : ' num2str(ch_rec)]);
    f1=figure(ch_rec); hold on
    SaveName = [ExpInfo.Subject_ID '_' ExpInfo.Target '_' ExpInfo.Experiment '_' ExpInfo.Date '_RecCh' num2str(ch_rec)];


%% open data

%% extract the data

    for ch_stim = 1:12 %1:12

        
% % %         x - x axis
% % %         y1 - y axis 1
% % %         y2 - y axis 2

        %% plot the data
        ax(ch_stim) = subplot(3,4,ch_stim); hold on; %grid on
        x = rand(10,1);
        plot(x,'Color','b','LineWidth',1)
        plot(x*ch_stim,'Color','r','LineWidth',1)

        title(['Stim Elec ' num2str(ch_stim)]);

        %xlabel('time (sec) 0 indicates first peak','FontSize',16)

    end
    sgtitle([ExpInfo.Subject_ID ' ' ExpInfo.Target ' ' ExpInfo.Experiment ' ' ExpInfo.Date '. Recording: Ch ' num2str(ch_rec)]) 

    linkaxes(ax,'x');
    %%linkaxes %%to link both x and y


%% %%figure size/ orientation
screen_size = get(0, 'ScreenSize'); %get screen resolution
set(f1, 'Position', [0 0 screen_size(3) screen_size(4)] );
figure_prop_name = {'PaperPositionMode','units','Position'};
figure_prop_val =  { 'auto'            ,'inches', [0.25 0.25 10.5 8]};%left bottom width height
set(f1,'PaperOrientation', 'landscape', 'PaperPositionMode', 'auto','units', 'inches', 'Position', [0.25 0.25 18 13])

%% %%saving figure
saveas(f1,['plots\' SaveName], 'fig'); %figure format
print('-djpeg100', '-r200', ['plots\' SaveName]); %low quality for saving


% saveas(f1,['plots\' SaveName], 'svg'); %figure format

%for actual posters/ papers - open matlab figure and run this line
% print -dtiff -r1200 name1; %high quality for posters/ papers - takes a long time
%%%'svg' format for final figures

close all



