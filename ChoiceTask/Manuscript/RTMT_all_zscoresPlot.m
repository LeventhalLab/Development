% [unitEventsRT,all_zscoresRT_000100] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,0,.100);
% [unitEventsRT,all_zscoresRT_100200] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.100,.200);
% [unitEventsRT,all_zscoresRT_200300] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.200,.300);
% [unitEventsRT,all_zscoresRT_300400] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.300,.400);
% [unitEventsRT,all_zscoresRT_400500] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.400,.500);
% [unitEventsRT,all_zscoresRT_500] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,0.5,1);

n = 0;
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById_RT(curTrials,.5,2);
    useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi];
    n = n + numel(useTrials);
end
n

myColorMap = lines(10);
figuree(1200,400);
curColor = 1;
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(smooth(nanmean(squeeze(all_zscoresRT_000100(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(curColor,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-.5 1]);
    grid on;
    title([eventFieldnames{iEvent}]);
    hold on;
end
curColor = curColor + 1;

for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(smooth(nanmean(squeeze(all_zscoresRT_100200(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(curColor,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-.5 1]);
    grid on;
    title([eventFieldnames{iEvent}]);
    hold on;
end
curColor = curColor + 1;

for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(smooth(nanmean(squeeze(all_zscoresRT_200300(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(curColor,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-.5 1]);
    grid on;
    title([eventFieldnames{iEvent}]);
    hold on;
end
curColor = curColor + 1;
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(smooth(nanmean(squeeze(all_zscoresRT_300400(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(curColor,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-.5 1]);
    grid on;
    title([eventFieldnames{iEvent}]);
    hold on;
end
curColor = curColor + 1;
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(smooth(nanmean(squeeze(all_zscoresRT_400500(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(curColor,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-.5 1]);
    grid on;
    title([eventFieldnames{iEvent}]);
    hold on;
end
curColor = curColor + 1;
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(smooth(nanmean(squeeze(all_zscoresRT_500(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(curColor,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-.5 1]);
    grid on;
    title([eventFieldnames{iEvent}]);
    hold on;
end
curColor = curColor + 1;
% % for iEvent = 1:numel(eventFieldnames)
% %     subplot(1,7,iEvent);
% %     plot(smooth(nanmean(squeeze(all_zscoresRT_125128(:,iEvent,:))),3),'LineWidth',0.5,'Color','k');
% %     xlim([1 40]);
% %     xticks([1 20 40]);
% %     xticklabels({'-1','0','1'});
% %     ylim([-.5 1]);
% %     grid on;
% %     title([eventFieldnames{iEvent}]);
% %     hold on;
% % end
% % curColor = curColor + 1;
% % for iEvent = 1:numel(eventFieldnames)
% %     subplot(1,7,iEvent);
% %     plot(smooth(nanmean(squeeze(all_zscoresRT_148150(:,iEvent,:))),3),'LineWidth',0.5,'Color','r');
% %     xlim([1 40]);
% %     xticks([1 20 40]);
% %     xticklabels({'-1','0','1'});
% %     ylim([-.5 1]);
% %     grid on;
% %     title([eventFieldnames{iEvent}]);
% %     hold on;
% % end
% % curColor = curColor + 1;
% legend('long RT (short MT)','long MT (short RT)');
% legend('short RT','long RT');
legend('RT 0-100ms (3199)','RT 100-200ms (19812)','RT 200-300ms (4991)','RT 300-400ms (1690)','RT 400-500ms (662)','RT 500+ms (366)');