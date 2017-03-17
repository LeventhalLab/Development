function [zMean,zStd] = meanPETZ(rasterData,tWindow)

allZs = [];
for iTrial = 1:size(rasterData,1)
    ts = rasterData{iTrial};
    sigma = mean(diff(ts)) * 2;
    % shift ts to non-negative values
    [s,binned,kernel] = spikeDensityEstimate(ts+tWindow,tWindow*2,sigma);
    allZs(iTrial,:) = (s - mean(s)) / std(s);
end

zMean = mean(allZs);
zStd = std(allZs);