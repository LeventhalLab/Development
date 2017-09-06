function [zMean,zStd] = zParams(ts,binMs)
% --- find MEAN & STD from random trials

tWindow = 1;
binS = binMs / 1000;
nSamples = 500;

nBins_tWindow = [-tWindow:binS:tWindow];

tsPeths = {};
a = tWindow;
b = max(ts) - tWindow;
r = (b-a).*rand(nSamples,1) + a;
for iir = 1:numel(r)
    tsPeths{iir,1} = tsPeth(ts,r(iir),tWindow);
end
all_hValues = [];
for iTrial = 1:size(tsPeths,1)
    ts_event1 = tsPeths{iTrial,1};
    hCounts = histcounts(ts_event1,nBins_tWindow);
    all_hValues(iTrial,:) = hCounts;
end
zStd = std(mean(all_hValues));
zMean = mean(mean(all_hValues));