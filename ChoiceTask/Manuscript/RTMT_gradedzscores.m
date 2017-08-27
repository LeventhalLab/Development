RTstep = .025; % seconds
startRTs = [0:RTstep:1-RTstep];

if false
    graded_unitEventsRT = {};
    grader_all_zscoresRT = {};
    for iStartRT = 1:numel(startRTs)
        startRT = startRTs(iStartRT);
        endRT = startRTs(iStartRT) + RTstep;
        [unitEventsRT,all_zscoresRT] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,startRT,endRT);
        graded_unitEventsRT{iStartRT} = unitEventsRT;
        grader_all_zscoresRT{iStartRT} = all_zscoresRT;
    end
end

MTstep = RTstep;
startMTs = startRTs;

if false
    graded_unitEventsMT = {};
    grader_all_zscoresMT = {};
    for iStartMT = 1:numel(startMTs)
        startMT = startMTs(iStartMT);
        endMT = startMTs(iStartMT) + MTstep;
        [unitEventsMT,all_zscoresMT] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,startMT,endMT);
        graded_unitEventsMT{iStartMT} = unitEventsMT;
        grader_all_zscoresMT{iStartMT} = all_zscoresMT;
    end
end

pretonestep = RTstep;
startpretones = [.5:RTstep:1-RTstep];

if false
    graded_unitEventspretone = {};
    grader_all_zscorespretone = {};
    for iStartpretone = 1:numel(startpretones)
        startpretone = startpretones(iStartpretone);
        endpretone = startpretones(iStartpretone) + pretonestep;
        [unitEventspretone,all_zscorespretone] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,startpretone,endpretone);
        graded_unitEventspretone{iStartpretone} = unitEventspretone;
        grader_all_zscorespretone{iStartpretone} = all_zscorespretone;
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
    colors = parula(numel(grader_all_zscoresRT));
    curColor = 1;
    lns = [];
    lnsCount = 1;
    legendLabels = {};
    figuree(1200,400);
    centerOutMaxZRT = [];
    for iStartRT = 1:numel(grader_all_zscoresRT)
        all_zscoresRT = grader_all_zscoresRT{iStartRT};
        if isempty(all_zscoresRT)
            centerOutMaxZRT(iStartRT) = NaN;
            continue;
        end
        centerOutMaxZRT(iStartRT) = max(nanmean(squeeze(all_zscoresRT(:,4,:)))) - min(nanmean(squeeze(all_zscoresRT(:,4,:))));
        for iEvent = 1:numel(eventFieldnames)
            subplot(1,7,iEvent);
            lns(lnsCount) = plot(smooth(nanmean(squeeze(all_zscoresRT(:,iEvent,:))),3),'LineWidth',1,'Color',colors(lnsCount,:));
            xlim([1 40]);
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            ylim([-3 10]);
            grid on;
            title(['RT ',eventFieldnames{iEvent}]);
            hold on;
        end
        legendLabels{lnsCount} = [num2str(startRTs(iStartRT)),'-',num2str(startRTs(iStartRT)+RTstep),' ms'];
        if iStartRT == numel(grader_all_zscoresRT)
            legendLabels{lnsCount} = [num2str(startRTs(iStartRT)),'-2000 ms'];
        end
        curColor = curColor + 1;
        lnsCount = lnsCount + 1;
    end
    legend(lns,legendLabels);
end

if true
    colors = parula(numel(grader_all_zscoresMT));
    curColor = 1;
    lns = [];
    lnsCount = 1;
    legendLabels = {};
    figuree(1200,400);
    centerOutMaxZMT = [];
    for iStartMT = 1:numel(grader_all_zscoresMT)
        all_zscoresMT = grader_all_zscoresMT{iStartMT};
        if isempty(all_zscoresMT)
            centerOutMaxZMT(iStartMT) = NaN;
            continue;
        end
        centerOutMaxZMT(iStartMT) = max(nanmean(squeeze(all_zscoresMT(:,4,:)))) - min(nanmean(squeeze(all_zscoresMT(:,4,:))));
        for iEvent = 1:numel(eventFieldnames)
            subplot(1,7,iEvent);
            lns(lnsCount) = plot(smooth(nanmean(squeeze(all_zscoresMT(:,iEvent,:))),3),'LineWidth',1,'Color',colors(lnsCount,:));
            xlim([1 40]);
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            ylim([-3 10]);
            grid on;
            title(['MT ',eventFieldnames{iEvent}]);
            hold on;
        end
        legendLabels{lnsCount} = [num2str(startMTs(iStartMT)),'-',num2str(startMTs(iStartMT)+MTstep),' ms'];
        if iStartMT == numel(grader_all_zscoresMT)
            legendLabels{lnsCount} = [num2str(startMTs(iStartMT)),'-2000 ms'];
        end
        curColor = curColor + 1;
        lnsCount = lnsCount + 1;
    end
    legend(lns,legendLabels);
end

if true
    colors = parula(numel(grader_all_zscorespretone));
    curColor = 1;
    lns = [];
    lnsCount = 1;
    legendLabels = {};
    figuree(1200,400);
    centerOutMaxZpretone = [];
    for iStartpretone = 1:numel(grader_all_zscorespretone)
        all_zscorespretone = grader_all_zscorespretone{iStartpretone};
        if isempty(all_zscorespretone)
            centerOutMaxZpretone(iStartpretone) = NaN;
            continue;
        end
        centerOutMaxZpretone(iStartpretone) = max(nanmean(squeeze(all_zscorespretone(:,4,:)))) - min(nanmean(squeeze(all_zscorespretone(:,4,:))));
        for iEvent = 1:numel(eventFieldnames)
            subplot(1,7,iEvent);
            lns(lnsCount) = plot(smooth(nanmean(squeeze(all_zscorespretone(:,iEvent,:))),3),'LineWidth',1,'Color',colors(lnsCount,:));
            xlim([1 40]);
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            ylim([-3 10]);
            grid on;
            title(['pretone ',eventFieldnames{iEvent}]);
            hold on;
        end
        legendLabels{lnsCount} = [num2str(startpretones(iStartpretone)),'-',num2str(startpretones(iStartpretone)+pretonestep),' ms'];
        if iStartpretone == numel(grader_all_zscorespretone)
            legendLabels{lnsCount} = [num2str(startpretones(iStartpretone)),'-2000 ms'];
        end
        curColor = curColor + 1;
        lnsCount = lnsCount + 1;
    end
    legend(lns,legendLabels);
end

lns = [];
figure;
lineColors = lines(3);
lns(1) = plot(startRTs,centerOutMaxZRT,'color',lineColors(1,:),'LineWidth',3);
hold on;
lns(2) = plot(startRTs,centerOutMaxZMT,'color',lineColors(2,:),'LineWidth',3);
lns(3) = plot(startpretones,centerOutMaxZpretone,'color',lineColors(3,:),'LineWidth',3);
xlabel(['start RT/MT - start RT/MT + ',num2str(MTstep)]);
ylabel('z score');
ylim([0 15]);
title('centerOut maxZ-minZ');
grid on;
legend(lns,'RT','MT','pretone');