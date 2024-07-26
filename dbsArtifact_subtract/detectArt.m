function idxArt = detectArt(data, thresh, varargin)
% DETECTART 
%
% SYNTAX
% idxArt = detectArt(data, thresh, threshCrossEdge)
%
% 
% DESCRIPTION
% idxArt = detectArt(data, thresh, threshCrossEdge) takes in a single 1-D 
% timeseries DATA, and detects artifact events based on threshold crossings, 
% as well as some windowing options around those crossings.
%
%
% INPUT ARGUMENTS
% data -- a 1-D timeseries of arbitrary length
% 1-D vector, of N samples
% 
% thresh -- threshold crossing value
% scalar
% a value specifying the threshold crossing line that an
% artifact waveform would cross in order to detect it.
%
% threshCrossEdge -- option specifying threshold cross type
% 'rising' | 'falling'
% 
% OUTPUT ARGUMENTS
% idxArt -- detected artifact events
% 1-D vector, of N samples
% output is a TF vector of N samples, same length as data input, where 1's
% correspond to detected events.
% 
% 
% TIPS
% Set the threshold value in such a way that each artifact event doesn't
% get "detected" twice.
% 

%% Input parser section
defaulThreshCrossEdge = 'falling';
expectedThreshCrossEdge = {'falling', 'rising'};
defaultSegWindow = [0 0];


p = inputParser;
% addRequired(p,'data',@(x)isvector);
addRequired(p,'data', @(x) isnumeric(x) && isvector(x));
addRequired(p,'thresh',@(x) isnumeric(x) && isscalar(x));
addParameter(p,'threshCrossEdge',defaulThreshCrossEdge,...
    @(x) any(validatestring(x, expectedThreshCrossEdge)));
addParameter(p,'segmentWindow', defaultSegWindow, @(x) length(x) == 2);
parse(p,data,thresh,varargin{:});

  
%% Main Code

threshCrossEdge = p.Results.threshCrossEdge;

% if ~exist('threshCrossEdge')
%     threshCrossEdge = 'falling'; % 'rising' | 'falling'
%     
% end


idxAbove = data > thresh;
idxBelow = data < thresh;
idxDetect = idxAbove + -idxBelow;
idxCross = [0 diff(idxDetect)];

switch threshCrossEdge
    case 'falling'
        idxArt = idxCross == -2;
        
    case 'rising'
        idxArt = idxCross == 2;
        
    otherwise
        error('Enter 3rd input as string, either "falling" or "rising"!');
        
end





end