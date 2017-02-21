function [tsLTS, LTS_n] = filterLTS(tsBurst, varargin)
%
% INPUTS:
%
% OUTPUTS:
%   tsLTS - timestamps of first spike in each LTS burst
%   LTS_n - number of spikes in each LTS burst

hp = 0.1; %hyperpolarization 100ms
LTS_idx = (diff(tsBurst) < hp);
tsLTS = tsBurst(LTS_idx);

if nargin == 2
    
    % figure out how many spikes are in each burst if a second argument is
    % provided to this function. That second argument is the number of
    % spikes per burst for tsBurst
    
    LTS_n = varargin{1}(LTS_idx);
    
else
    LTS_n = [];
end