trialTypes = {'correctContra','correctIpsi','incorrectContra','incorrectIpsi'};
myColorMap = lines(4);
figuree(1200,800);
lns = [];
for iTrialType = 1:4
    [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,nBins_tWindow,{trialTypes{iTrialType}});
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
% legend(lns,trialTypes);