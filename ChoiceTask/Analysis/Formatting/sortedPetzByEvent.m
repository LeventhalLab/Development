% close all;
totalRows = 1; % sorted by: trial #, RT, MT, Z-score (w/ RT&MT markers)
% [sorted_petz,sorted_times] = sortEventPetz(all_eventPetz,allTrials,[3,0.5,1000]);
timingField = 'RT';
[sorted_petz,sorted_times] = sortEventPetz(all_eventPetz,allTrials,timingField,[4,2,1500]);
% [sorted_petz,sorted_times] = sortEventPetz(all_eventPetz,allTrials,timingField,[]);
figure('position',[0 0 1200 800]);
iSubplot = 1;
for iEvent = plotEventIds
    ax = subplot(totalRows,numel(plotEventIds)+1,iSubplot);
    imagesc(sorted_petz{1,iEvent});
    hold on;
    plot([2000,2000],[1,numel(sorted_times)],'k--','LineWidth',1);
    colormap(jet);
    caxis([-2 2]);
    xtickVals = [1000 2000 3000];
    xticks(xtickVals);
    xticklabels({'-1','0','1'});
    xlim([xtickVals(1) xtickVals(end)]);
    xlabel('time (s)');
    if iEvent == 1
        ylabel('unit #');
    end
    title([eventFieldnames{iEvent}]);
    iSubplot = iSubplot + 1;
end

ax = subplot(totalRows,numel(plotEventIds)+1,iSubplot);
plot(flip(sorted_times),linspace(1,numel(sorted_times),numel(sorted_times)));
yticks([0]);
ylim([1 numel(sorted_times)]);
hold on;
plot(smooth(flip(sorted_times),20),linspace(1,numel(sorted_times),numel(sorted_times)),'r','linewidth',2);
title(timingField);
xlim([min(sorted_times) max(sorted_times)]);
xlim([.2 .5]);
xlabel('time (s)');