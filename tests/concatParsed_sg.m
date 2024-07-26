function [concatSg, iFileSampIdx] = concatParsed_sg(subTab, dataFullPath)
% Function for concatenating parsed files into a single channel of data. It
% expects a matlab table input of metadata where each row corresponds to a
% part of the single desired 1-D array of data, and a string specifying the
% full path to the folder holding that data. Note that you need to enter a
% sub-selected table in this for things to work. 

% Populate a matrix of corresponding amplifier data
nSamps = sum(subTab.nsamples(:));
concatSg = zeros(1, nSamps);

% prep sample indices matrix
nSampCol = cumsum(subTab.nsamples);
idxbeg = [0; nSampCol(1:end-1)] + 1;
idxend = nSampCol;
iFileSampIdx = [idxbeg, idxend];

nFiles = height(subTab);
for iRHDfile = 1:nFiles
    idxL = iFileSampIdx(iRHDfile,:);
    
    load([dataFullPath subTab.parsedFilename{iRHDfile}]); % loads variable called "data"
    concatSg(idxL(1):idxL(2)) = data;   
    
end

end