spikeWindow = 1; % second
centerOut = {}; % Mx1 cell of spike times, M = trials, each cell 1xN spike times
trialCount = 1;
sortVals = [];

% ribbon visualization
ribbonWindow = [-250 1000]; % ms
sigma = 0.100;
endTs = length(sevFilt) / Fs;
[s,binned,kernel] = spikeDensityEstimate(ts,endTs,sigma);
sdeRibbonZ = [];
decimateRibbon = 50;

trialIds = find([trials.correct]==1);
for iTrial=trialIds
    centerTs = trials(iTrial).timestamps.centerOut;
    centerTsMs = centerTs * 1000;
    sdeRibbonZ(:,trialCount) = decimate(s(round(centerTsMs+ribbonWindow(1)):round(centerTsMs+ribbonWindow(2))),decimateRibbon);
    % [ ] replace with function I wrote to extract tsCenter spans
    trialTs = ts(ts < centerTs + spikeWindow & ts > centerTs - spikeWindow) - centerTs;
    centerOut(trialCount,1) = {trialTs'};
    sortVals(trialCount) = trials(iTrial).timing.MT;
    trialCount = trialCount + 1;
end
[B,I] = sort(sortVals);
centerOut = centerOut(I,1);
correctCount = trialCount;
% figure; hist(B);

sdeRibbonZ = sdeRibbonZ(:,I);
sdeRibbonY = repmat(decimate(ribbonWindow(1):ribbonWindow(2),decimateRibbon),[size(sdeRibbonZ,2) 1])';
figure;
ribbon(sdeRibbonY,sdeRibbonZ);
xlabel('Trial');
ylabel('Time (ms)');
zlabel('Spike Density Estimate');

trialIds = find([trials.correct]==0);
for iTrial=trialIds
    centerTs = trials(iTrial).timestamps.centerOut;
    trialTs = ts(ts < centerTs + spikeWindow & ts > centerTs - spikeWindow) - centerTs;
    centerOut(trialCount,1) = {trialTs'};
    trialCount = trialCount + 1;
end

figure;
plotSpikeRaster(centerOut,'PlotType','vertline','AutoLabel',true);
hold on;
plot([-spikeWindow spikeWindow],[correctCount correctCount],'r');
sortLine = length(find(B<0.4));
plot([-spikeWindow spikeWindow],[sortLine sortLine],'g');

% x = trials (undefined)
% y = linear vector (i.e. timestamp)
% z = values