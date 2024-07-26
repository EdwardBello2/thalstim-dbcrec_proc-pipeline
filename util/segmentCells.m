function [segCells, segIdx] = segmentCells(sig, refs)
% Rather than have a matrix of equal-length segments like "segments.m", the
% idea here is to have a cell array of segment-ish data of arbitrary length
% from segment to segment, based only on the sample indices in "refs". 

if ~isvector(sig), error('input "sig" must be a single vector value!'); end
if ~isvector(refs), error('input "refs" must be a single vector vaclue!'); end


dSamp = median(diff(refs));

refCount = length(refs);
segCells = cell(refCount, 1);
segIdx = cell(refCount, 1);

for i = 1:(refCount-1)
    segIdx{i} = refs(i):refs(i+1);
    segCells{i} = sig(refs(i):refs(i+1));
    
end  

% Specify extent of segment after last ref-event:
if (refs(end) + dSamp) <= length(sig)
    segIdx{end} = refs(end):(refs(end) + dSamp);
    segCells{end} = sig(refs(end):(refs(end) + dSamp));
    
else
    segIdx{end} = refs(end):length(sig);
    segCells{end} = sig(refs(end):length(sig));   
    
end
% if nargout == 1
%     varargout{1} = SegIndices;
% end





end