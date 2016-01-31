function [zMean,zStd] = helpZscore(ts,tsWindow,histBin)
nRand = 1000;
tsRand = randsample([tsWindow:ts(end)-tsWindow],nRand);
tsPeth = [];

for iRand=1:nRand
    tsPeth = [tsPeth;ts(ts < tsRand(iRand)+tsWindow & ts >= tsRand(iRand)-tsWindow) - tsRand(iRand)];
end

[counts,centers] = hist(tsPeth,histBin);
zMean = counts/nRand;
zStd = std(zMean);
zMean = mean(zMean);