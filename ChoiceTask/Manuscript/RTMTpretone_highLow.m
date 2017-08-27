if true
    RTmin = 0;
    RTmax = median(all_rt) + std(all_rt);
    RTmin = .15;
    RTmax = .1811;
    tWindow = 2;
    [unitEventsRTlow,all_zscoresRTlow] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,RTmin,RTmax);
    n_all_zscoresRTlow = numel(find(all_rt > RTmin & all_rt < RTmax));

    RTmin = median(all_rt) + std(all_rt);
    RTmax = 2;
    [unitEventsRThigh,all_zscoresRThigh] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,RTmin,RTmax);
    n_all_zscoresRThigh = numel(find(all_rt > RTmin & all_rt < RTmax));
end

figuree(1200,400);
colors = lines(2);
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    lns(1) = plot(smooth(nanmean(squeeze(all_zscoresRTlow(:,iEvent,:))),3),'LineWidth',1,'Color',colors(1,:));
    hold on;
    lns(2) = plot(smooth(nanmean(squeeze(all_zscoresRThigh(:,iEvent,:))),3),'LineWidth',1,'Color',colors(2,:));
    xlim([1 80]);
    xticks([1 40 80]);
    xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
    ylim([-2 8]);
    grid on;
    title([eventFieldnames{iEvent}]);
end

legend(lns,{['low RT ',num2str(n_all_zscoresRTlow)],['high RT ',num2str(n_all_zscoresRThigh)]});