function allZs = eventPetz(trials,ts,tWindow)
tsPeths = eventsPeth(trials,ts,tWindow);
[s,~,~,sigma] = spikeDensityEstimate(ts); % whole session

for iEvent = 1:size(tsPeths,2)
    rasterData = tsPeths(:,iEvent);
    for iTrial = 1:size(rasterData,1)
        tsRaster = rasterData{iTrial};
        [sR,~,~,~] = spikeDensityEstimate(ts+tWindow,tWindow*2,sigma);
        allZs{iEvent,iTrial} = (sR - mean(s)) / std(s);
    end
end