function [medTab] = proc_genCMparsed(tab, inputParsedPn, outputParsedPn)
% function for taking in all good amplifier data from each rhd file
% sequentially and generating a common mode signal to save into data
% processing in the same format


% prepare a metadata table for the median common mode channel tracking, to
% be saved in the processing folder
chanLabelSelect = 'A-100'; % just pick an arbitrary label
idxChanLabel = strcmp(tab.chanLabel, chanLabelSelect);
medTab = tab((idxChanLabel),:);   
  

nRHDfiles = height(medTab);
for iRHDfile = 1:nRHDfiles
    name = medTab.parsedFilename{iRHDfile};
    medTab.parsedFilename{iRHDfile} = [name(1:end-9) 'MED'];
    medTab.chanLabel{iRHDfile} = 'common_mode';
    
end


% 
for iRHDfile = 1:nRHDfiles
    % Specify all parsed files related to one RHD file
    idxFile = tab.fileOrder == iRHDfile;

    % Specify all parsed files that hold amplifier data
    idxAmp = strcmp(tab.dataType, 'amplifier_data');

    subTab = tab((idxFile & idxAmp),:);

    % Populate a matrix of corresponding amplifier data
    nChans = height(subTab);
    nSamps = subTab.nsamples(1);
    ampRaw = zeros(nChans, nSamps);

%     fileFullpath = [datapn RHDfolder '\parsedMatfiles\']; 
%     tic
    for iChan = 1:nChans
        load([inputParsedPn subTab.parsedFilename{iChan}]); % loads variable called "data"
        ampRaw(iChan,:) = data;

    end
%     toc
    
    % Get a common mode signal based on global median of good channels
    data = median(ampRaw,1);
    
    % Save this data to its own matfile with similar name
    parsedFilename = subTab.parsedFilename{iChan};
    medFileName = [parsedFilename(1:end-9) 'MED'];
    
    save([outputParsedPn medTab.parsedFilename{iRHDfile}], 'data');
    
    
end

end