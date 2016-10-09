function [tsISI,tsLTS,tsPoisson] = tsBurstFilters(ts)
maxBurstISI = 0.007; % seconds

tsISI = [];
tsLTS = [];
burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
if ~isempty(burstIdx) % ISI-based bursts and TLS bursts exist
    burstStartIdx = [1;diff(burstIdx)>1];
    tsISI = ts(burstIdx(logical(burstStartIdx)));
    tsLTS = filterLTS(tsISI);
end

[~,~,poissonIdx] = burst(ts);
tsPoisson = [];
if ~isempty(poissonIdx)
    tsPoisson = ts(poissonIdx);
end