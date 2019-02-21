function zSDE = tsPeths_to_zSDE(tsPeths)
tWindow = 0.5;
SDE = [];
for iTrial = 1:size(tsPeths,1)
    for iEvent = 1:size(tsPeths,2)
        ts = tsPeths{iTrial,iEvent};
        SDE(iTrial,iEvent,:) = spikeDensityEstimate_periEvent(ts,tWindow);
    end
end
zMean = mean(mean(SDE(:,1,:)));
zStd = mean(std(SDE(:,1,:),[],3));
zSDE = (SDE - zMean) ./ zStd;