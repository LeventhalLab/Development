function [tsISI,tsLTS,tsPoisson,tsPoissonLTS,ISI_n,LTS_n,poisson_n,poissonLTS_n] = tsBurstFilters(ts)
% tsISI,tsLTS,tsPoisson,tsPoissonLTS contain timestamps (in seconds) that
% represent the time of the first spike in that classification type.
% ISI_n,LTS_n,poisson_n,poissonLTS_n correspond to the first four outputs
% and contain a number (n) representing how many spikes are contained
% within that class of burst (including the first spike); therefore, n >= 2.

% Tip: you can use the *_n arrays to discard bursts containing less than
% some amount of spikes.

maxBurstISI = 0.01; % seconds

tsISI = [];
tsLTS = [];
ISI_n = [];
LTS_n = [];

burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
if ~isempty(burstIdx) % ISI-based bursts and TLS bursts exist
    burstStartIdx = find([1;diff(burstIdx)>1]);
    burstEndIdx = [burstStartIdx(2:end)-1;length(burstIdx)];
    ISI_n = ((burstIdx(burstEndIdx)+1) - burstIdx(burstStartIdx)) + 1;
    tsISI = ts(burstIdx(burstStartIdx));
    [tsLTS, LTS_n] = filterLTS(tsISI, ISI_n);
end

[~,poisson_n,poissonIdx] = burst(ts);
tsPoisson = [];
if ~isempty(poissonIdx)
    tsPoisson = ts(poissonIdx);
end

[tsPoissonLTS, poissonLTS_n] = filterLTS(tsPoisson,poisson_n);