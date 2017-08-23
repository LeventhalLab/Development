trialTypes = {'correctContra','correctIpsi','incorrectContra','incorrectIpsi'};
myColorMap = lines(4);
lns = [];
useEvents = 1:7;
if false % 4 rows
    figuree(1200,800);
    for iTrialType = 1:2
        [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,{trialTypes{iTrialType}},useEvents);
        for iEvent = 1:numel(eventFieldnames)
            sorted_neuronIds = [];
            for iNeuron = 1:numel(unitEvents)
                if isempty(unitEvents{iNeuron}.class)
                    continue;
                end
                if unitEvents{iNeuron}.class(1) == iEvent && max(abs(squeeze(all_zscores(iNeuron,iEvent,:)))) > 2
                    sorted_neuronIds = [sorted_neuronIds iNeuron];
                end
            end
            subplot(4,numel(eventFieldnames),iEvent+(numel(eventFieldnames)*(iTrialType-1)));
            lns(iTrialType) = plot(smooth(nanmean(squeeze(all_zscores(sorted_neuronIds,iEvent,:))),3),'LineWidth',3,'Color',myColorMap(iTrialType,:));
    % %         shadedErrorBar([],smooth(nanmean(squeeze(all_zscores(sorted_neuronIds,iEvent,:))),3),...
    % %             smooth(nanstd(squeeze(all_zscores(sorted_neuronIds,iEvent,:))),3),...
    % %             {'LineWidth',3,'Color',myColorMap(iTrialType,:)});
            xlim([1 40]);
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            ylim([-3 8]);
            colormap jet;
            title([eventFieldnames{iEvent},' (',num2str(numel(sorted_neuronIds)),')']);
            hold on;
        end
    end
    legend(lns,trialTypes);
end

if false % 1 row
    figuree(1200,400);
    for iTrialType = 1:4
        [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,{trialTypes{iTrialType}},useEvents);
        for iEvent = 1:numel(eventFieldnames)
            subplot(1,7,iEvent);
            lns(iTrialType) = plot(smooth(nanmean(squeeze(all_zscores(:,iEvent,:))),3),'LineWidth',3,'Color',myColorMap(iTrialType,:));
            xlim([1 40]);
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            ylim([-1 3]);
            grid on;
            title([eventFieldnames{iEvent}]);
            hold on;
        end
    end
    legend(lns,trialTypes);
end

if true % 1 row
    useSubjects = [88,117,142,154];
    figuree(1200,800);
    for iSubject = 1:numel(useSubjects)
        for iTrialType = 1:4
            [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,{trialTypes{iTrialType}},useEvents);
            for iEvent = 1:numel(eventFieldnames)
                useNeurons = [];
                for iNeuron = 1:numel(unitEvents)
                    sessionConf = analysisConf.sessionConfs{iNeuron};
                    if sessionConf.subjects__id == useSubjects(iSubject)
                        useNeurons = [useNeurons iNeuron];
                    end
                end
                subplot(numel(useSubjects),7,((7*iSubject)-7) + iEvent);
                lns(iTrialType) = plot(smooth(nanmean(squeeze(all_zscores(useNeurons,iEvent,:))),3),'LineWidth',3,'Color',myColorMap(iTrialType,:));
                hold on;
                xlim([1 40]);
                xticks([1 20 40]);
                xticklabels({'-1','0','1'});
                ylim([-1 3]);
                grid on;
                title([num2str(useSubjects(iSubject)),' - ',eventFieldnames{iEvent}]);
                hold on;
            end
        end
    end
    legend(lns,trialTypes);
end