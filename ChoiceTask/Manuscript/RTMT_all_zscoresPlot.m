binMs = 50;
% [unitEventsRT,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);

% plot all z-scores, no neuron class
if false
    myColorMap = lines(10);
    figuree(1200,400);
    lns = [];
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,7,iEvent);
        for iEvent2 = 1:numel(eventFieldnames)
            lns(iEvent2) = plot(smooth(nanmean(squeeze(all_zscores(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(1,:));
            xlim([1 size(all_zscores,3)]);
            xticks([1 round(size(all_zscores,3))/2 size(all_zscores,3)]);
            xticklabels({'-1','0','1'});
            ylim([-5 20]);
            grid on;
            title([eventFieldnames{iEvent}]);
            hold on;
        end
    end
end

% plot with neuron classes
if false
    figuree(1200,400);
    curColor = 1;
    lns = [];
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,7,iEvent);
        for iEvent2 = 1:numel(eventFieldnames)
    %         plot(squeeze(all_zscores(:,iEvent,:))','LineWidth',.2,'Color',myColorMap(curColor,:));
    %         hold on;
            lns(iEvent2) = plot(smooth(nanmean(squeeze(all_zscores(activeNeuronsIdx{iEvent2},iEvent,:))),3),'LineWidth',2,'Color',myColorMap(iEvent2,:));
            hold on;
            text(5,.2,num2str(numel(:)));
            xlim([1 size(all_zscores,3)]);
            xticks([1 round(size(all_zscores,3))/2 size(all_zscores,3)]);
            xticklabels({'-1','0','1'});
            ylim([-5 20]);
            grid on;
            title([eventFieldnames{iEvent}]);
            hold on;
        end
    end
    legend(lns,eventFieldnames);
end

activeNeuronsIdx = {};
for ii = 1:7
    activeNeuronsIdx{ii} = [];
end
for iNeuron = 1:size(all_zscores,1)
    if ~isempty(unitEventsRT{iNeuron}.class) && max(abs(unitEventsRT{iNeuron}.maxz)) > 1.96
        activeNeuronsIdx{unitEventsRT{iNeuron}.class(1)} = [activeNeuronsIdx{unitEventsRT{iNeuron}.class(1)} iNeuron];
    end  
end

% [unitEventsRT,all_zscoresRT_000100] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,0,.100);
% [unitEventsRT,all_zscoresRT_100200] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.100,.200);
% [unitEventsRT,all_zscoresRT_200300] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.200,.300);
% [unitEventsRT,all_zscoresRT_300400] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.300,.400);
% [unitEventsRT,all_zscoresRT_400500] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.400,.500);
% [unitEventsRT,all_zscoresRT_500] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,0.5,1);
% [unitEventsRT,all_zscoresRT_125128] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,.125,.128);

figuree(1200,800);
curColor = 1;
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(smooth(nanmean(squeeze(all_zscoresRT_000100(:,iEvent,:))),3),'LineWidth',2,'Color',myColorMap(curColor,:));
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-3 10]);
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
    ylim([-3 10]);
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
    ylim([-3 10]);
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
    ylim([-3 10]);
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
    ylim([-3 10]);
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
    ylim([-3 10]);
    grid on;
    title([eventFieldnames{iEvent}]);
    hold on;
end
curColor = curColor + 1;

% CONTROL
% % for iEvent = 1:numel(eventFieldnames)
% %     subplot(1,7,iEvent);
% %     plot(smooth(nanmean(squeeze(all_zscoresRT_125128(:,iEvent,:))),3),'LineWidth',0.5,'Color','r');
% %     xlim([1 40]);
% %     xticks([1 20 40]);
% %     xticklabels({'-1','0','1'});
% %     ylim([-3 10]);
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
% %     ylim([-3 10]);
% %     grid on;
% %     title([eventFieldnames{iEvent}]);
% %     hold on;
% % end
% % curColor = curColor + 1;
% legend('long RT (short MT)','long MT (short RT)');
% legend('short RT','long RT');
legend('RT 0-100ms (3199)','RT 100-200ms (19812)','RT 200-300ms (4991)','RT 300-400ms (1690)','RT 400-500ms (662)','RT 500+ms (366)');