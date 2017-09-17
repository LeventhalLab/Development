allRasters_sorted = allRasters(k);
% prepare for raster
all_burstTs_sorted = all_burstTs(k);
for iTrial = 1:size(all_burstTs_sorted,2)
    spikevect = all_burstTs_sorted{iTrial};
    if isempty(spikevect)
        all_burstTs_sorted{iTrial} = NaN;
    end
end

figure;
[xPoints,yPoints] = plotSpikeRaster(all_burstTs_sorted','PlotType','scatter','AutoLabel',false);
all_unitClasses_sorted = all_unitClasses(k);
% setup for raster function
groups = all_unitClasses_sorted;
colors = lines(3);
figPos = [0 0 600 600];
markerSize = 3;
plotSpikeRaster_color(xPoints,yPoints,groups,colors([1,3],:),figPos,markerSize)
xlimVals = [-tWindow tWindow];
xlim(xlimVals);
hold on;
toneLine = plot(0-all_curUseTime_sorted,1:numel(all_curUseTime_sorted),'g','linewidth',2);