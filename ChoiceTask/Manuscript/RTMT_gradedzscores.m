RTstep = .025; % seconds
startRTs = [0:RTstep:.500];

if false
    graded_unitEventsRT = {};
    grader_all_zscoresRT = {};
    for iStartRT = 1:numel(startRTs)
        startRT = startRTs(iStartRT);
        endRT = startRTs(iStartRT) + RTstep;
        if iStartRT == numel(startRTs) % last one
            endRT = 2;
        end
        [unitEventsRT,all_zscoresRT] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,startRT,endRT);
        graded_unitEventsRT{iStartRT} = unitEventsRT;
        grader_all_zscoresRT{iStartRT} = all_zscoresRT;
    end
end

MTstep = .025; % seconds
startMTs = [0:MTstep:.500];

if true
    graded_unitEventsMT = {};
    grader_all_zscoresMT = {};
    for iStartMT = 1:numel(startMTs)
        startMT = startMTs(iStartMT);
        endMT = startMTs(iStartMT) + MTstep;
        if iStartMT == numel(startMTs) % last one
            endMT = 2;
        end
        [unitEventsMT,all_zscoresMT] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,startMT,endMT);
        graded_unitEventsMT{iStartMT} = unitEventsMT;
        grader_all_zscoresMT{iStartMT} = all_zscoresMT;
    end
end

% % n = 0;
% % for iNeuron = 1:size(all_zscores,1)
% %     neuronName = analysisConf.neurons{iNeuron};
% %     curTrials = all_trials{iNeuron};
% %     trialIdInfo = organizeTrialsById_RT(curTrials,.5,2);
% %     useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi];
% %     n = n + numel(useTrials);
% % end

if true
    colors = jet(numel(grader_all_zscoresRT));
    curColor = 1;
    lns = [];
    legendLabels = {};
    figuree(1200,400);
    centerOutMaxZRT = [];
    for iStartRT = 1:numel(grader_all_zscoresRT)
        all_zscoresRT = grader_all_zscoresRT{iStartRT};
        centerOutMaxZRT(iStartRT) = max(nanmean(squeeze(all_zscoresRT(:,4,10:30))));
        for iEvent = 1:numel(eventFieldnames)
            subplot(1,7,iEvent);
            lns(iStartRT) = plot(smooth(nanmean(squeeze(all_zscoresRT(:,iEvent,:))),3),'LineWidth',1,'Color',colors(curColor,:));
            xlim([1 40]);
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            ylim([-3 10]);
            grid on;
            title([eventFieldnames{iEvent}]);
            hold on;
        end
        legendLabels{iStartRT} = [num2str(startRTs(iStartRT)),'-',num2str(startRTs(iStartRT)+RTstep),' ms'];
        if iStartRT == numel(grader_all_zscoresRT)
            legendLabels{iStartRT} = [num2str(startRTs(iStartRT)),'-2000 ms'];
        end
        curColor = curColor + 1;
    end
    legend(lns,legendLabels);
end

if true
    colors = jet(numel(grader_all_zscoresMT));
    curColor = 1;
    lns = [];
    legendLabels = {};
    figuree(1200,400);
    centerOutMaxZMT = [];
    for iStartMT = 1:numel(grader_all_zscoresMT)
        all_zscoresMT = grader_all_zscoresMT{iStartMT};
        centerOutMaxZMT(iStartMT) = max(nanmean(squeeze(all_zscoresMT(:,4,10:30))));
        for iEvent = 1:numel(eventFieldnames)
            subplot(1,7,iEvent);
            lns(iStartMT) = plot(smooth(nanmean(squeeze(all_zscoresMT(:,iEvent,:))),3),'LineWidth',1,'Color',colors(curColor,:));
            xlim([1 40]);
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            ylim([-3 10]);
            grid on;
            title([eventFieldnames{iEvent}]);
            hold on;
        end
        legendLabels{iStartMT} = [num2str(startMTs(iStartMT)),'-',num2str(startMTs(iStartMT)+MTstep),' ms'];
        if iStartMT == numel(grader_all_zscoresMT)
            legendLabels{iStartMT} = [num2str(startMTs(iStartMT)),'-2000 ms'];
        end
        curColor = curColor + 1;
    end
    legend(lns,legendLabels);
end

lns = [];
figure;
lineColors = lines(2);
lns(1) = plot(startRTs,centerOutMaxZRT,'color',lineColors(1,:));
hold on;
lns(2) = plot(startRTs,centerOutMaxZMT,'color',lineColors(2,:));
xlabel(['start RT/MT - start RT/MT + ',num2str(MTstep)]);
ylabel('z score');
ylim([-1 8]);
title('centerOutMaxZ (mean, all units)');
grid on;
legend(lns,'RT','MT');