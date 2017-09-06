if false % setup
    useEvents = 1:7;

    % get unit classes
    tWindow = 0.5;
    binMs = 50;
    [~,~,unitClasses] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,{'correctContra','correctIpsi'},useEvents,{});

    tWindow = 1;
    % make RT data
    [unitEventsRT_000300,all_zscoresRT_000300,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,{'RT',[0 0.3]});
    [unitEventsRT_3001000,all_zscoresRT_3001000,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,{'RT',[0.3 1]});

    % make MT data
    [unitEventsMT_000300,all_zscoresMT_000300,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,{'MT',[0 0.3]});
    [unitEventsMT_3001000,all_zscoresMT_3001000,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,{'MT',[0.3 1]});
end

figuree(1200,700)
colors = lines(3);
lns = [];
for iEvent = 1:numel(eventFieldnames)
    subplot(2,7,iEvent);
    lns(1) = plot(smooth(nanmean(squeeze(all_zscoresRT_000300(unitClasses == 4,iEvent,:))),3),'LineWidth',1,'Color',colors(1,:)); hold on;
    lns(2) = plot(smooth(nanmean(squeeze(all_zscoresRT_3001000(unitClasses == 4,iEvent,:))),3),'LineWidth',1,'Color',colors(3,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-5 15]);
    grid on;
    title(['RT ',eventFieldnames{iEvent}]);
    hold on;
end
legend(lns,{'0-300ms','300-1000ms'});

lns = [];
for iEvent = 1:numel(eventFieldnames)
    subplot(2,7,iEvent+7);
    lns(1) = plot(smooth(nanmean(squeeze(all_zscoresMT_000300(unitClasses == 4,iEvent,:))),3),'LineWidth',1,'Color',colors(1,:)); hold on;
    lns(2) = plot(smooth(nanmean(squeeze(all_zscoresMT_3001000(unitClasses == 4,iEvent,:))),3),'LineWidth',1,'Color',colors(3,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-5 15]);
    grid on;
    title(['MT ',eventFieldnames{iEvent}]);
    hold on;
end
legend(lns,{'0-300ms','300-1000ms'});