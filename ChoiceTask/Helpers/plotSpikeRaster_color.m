function plotSpikeRaster_color(xPoints,yPoints,groups,colors,figPos,markerSize)

if numel(xPoints) ~= numel(yPoints) || numel(unique(yPoints)) ~= numel(groups) ||...
        numel(unique(groups)) ~= size(colors,1)
    error('check input dimensions');
end

yPoints_unique = unique(yPoints);

figure('position',figPos);
for iTrial = 1:numel(unique(yPoints))
    cur_y = yPoints_unique(iTrial);
    pointIdxs = find(yPoints == cur_y);
    plot(xPoints(pointIdxs),yPoints(pointIdxs),'.','color',colors(groups(iTrial) == unique(groups),:),'markerSize',markerSize);
    hold on;
end
ylim([1 numel(unique(yPoints))]);
set(gca,'ydir','reverse');
xlabel('time (s)');
ylabel('trials');