function [meanSDE,stdSDE] = getMeanSDE(tsArr,tWindow)

all_s = [];
for iTrial = 1:size(tsArr,1)
    ts = tsArr{iTrial};
    s = spikeDensityEstimate_periEvent(ts,tWindow);
    all_s(iTrial,:) = s;
end
meanSDE = mean(all_s);
stdSDE = std(all_s);