function [tsISI,tsLTS,tsPoisson,tsPoissonLTS, ISI_n, LTS_n, poisson_n, poissonLTS_n] = tsBurstFilters(ts)
maxBurstISI = 0.007; % seconds

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