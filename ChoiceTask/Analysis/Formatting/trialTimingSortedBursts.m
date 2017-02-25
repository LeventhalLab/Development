% rasterData = makeRasterReadable(rasterData,100); % limit to 100 data points
% close all;
% --- FIG 1
figure('position',[0 0 900 900]);
subplot(221);
[~,k] = sort(shortRasterTimes); % plot asc
if size(k,1) == size(shortRasters,1)
    shortRasters = shortRasters(k);
    shortRasters = shortRasters(~cellfun('isempty',shortRasters));
end
[~,k] = sort(longRasterTimes); % plot asc
if size(k,1) == size(longRasters,1)
    longRasters = longRasters(k);
    longRasters = longRasters(~cellfun('isempty',longRasters));
end
maxTrials = max([size(shortRasters,1) size(longRasters,1)]);
plotSpikeRaster(shortRasters,'PlotType','scatter','AutoLabel',false);
title('centerOut Short RTs, ISI');
ylabel('units - all trials');
xlim([-1 1]);
ylim([0 maxTrials]);
hold on;
plot([0 0],[0 maxTrials],':','color','red'); % center line

subplot(222);
plotSpikeRaster(longRasters,'PlotType','scatter','AutoLabel',false);
title('centerOut Long RTs, ISI');
ylabel('unit - all trials');
xlim([-1 1]);
ylim([0 maxTrials]);
hold on;
plot([0 0],[0 maxTrials],':','color','red'); % center line


subplot(223);
plot(sort(shortRasterTimes),[0:length(shortRasterTimes)-1]);
set(gca,'ydir','reverse');
ylim([0 length(shortRasterTimes)-1]);
ylabel('units - all trials');
xlabel('RT (sec)');
title('Short RTs');
xlim([0 0.6]);
ylim([0 maxTrials]);

subplot(224);
plot(sort(longRasterTimes),[0:length(longRasterTimes)-1]);
set(gca,'ydir','reverse');
ylim([0 length(longRasterTimes)-1]);
ylabel('units - all trials');
xlabel('RT (sec)');
title('Long RTs');
xlim([0 0.6]);
ylim([0 maxTrials]);

% --- FIG 2
histBins = 200;

figure('position',[0 0 600 900]);

subplot(211);
shortRasterTs = cat(2,shortRasters{:});
[counts,centers] = hist(shortRasterTs,histBins);
ratePerSecond = (counts*histBins)/(length(shortRasters)*tWindow*2);
bar(centers,ratePerSecond,'k','EdgeColor','k');
ylabel('burst/sec');
title('Short RTs, ISI');
xlim([-1 1]);

subplot(212);
longRasterTs = cat(2,longRasters{:});
[counts,centers] = hist(longRasterTs,histBins);
ratePerSecond = (counts*histBins)/(length(longRasters)*tWindow*2);
bar(centers,ratePerSecond,'k','EdgeColor','k');
ylabel('burst/sec');
title('Long RTs, ISI');
xlim([-1 1]);