function [Segs,SegIndices] = segments(sig,refs,segLength)
% Organize a single-channel time-series into segments based off of
% periodic reference events. Note: window idicies must not exceed the
% indices of the original signal. 
%
% [Segs,SegIndices] = segments(sig,refs,segLength)
%       Output is an m-by-n matrix of segment windows according to "m"
%       number of reference events, as well as the indices of these
%       segments from the original time-series vector. Window-boundaries:
%       ref-event + "segLength" to the right.
% [Segs,SegIndices] = segments(sig,refs,[loffset, roffset])
%       Same as above, except that segment windows boundaries are defined
%       "loffset" samples to the left of ref-event and "roffset" samples to
%       the right of ref-event.

if ~isvector(sig), error('input "sig" must be a single vector value!'); end
if ~isvector(refs), error('input "refs" must be a single vector vaclue!'); end

%check segLength input
if length(segLength)>1
    if length(segLength)>2
        error('input exceeds allowed dimensions');
    end
    loffset = segLength(1);
    roffset = segLength(2);
elseif isscalar(segLength)
    loffset = 0;
    roffset = segLength-1;
else
    error('improper input for segLength')
end

refCount = length(refs);
Segs = zeros(refCount,loffset+1+roffset);
SegIndices = zeros(refCount,loffset+1+roffset);

for i = 1:refCount
    try
    SegIndices(i,:) = (refs(i)-loffset):(refs(i)+roffset);
    Segs(i,:) = sig(SegIndices(i,:));
    
    catch
        error(['i == ' num2str(i)])
        
    end
end  
% if nargout == 1
%     varargout{1} = SegIndices;
% end


end
