trialTypes = {'correctContra','correctIpsi','incorrectContra','incorrectIpsi'};
myColorMap = lines(4);
figuree(1200,400);
lns = [];
for iTrialType = 1:4
    [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,nBins_tWindow,{trialTypes{iTrialType}});
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,numel(eventFieldnames),iEvent);
        lns(iTrialType) = plot(smooth(nanmean(squeeze(all_zscores(sorted_neuronIds,iEvent,:))),3),'LineWidth',3,'Color',myColorMap(iTrialType,:));
        xlim([1 40]);
        xticks([1 20 40]);
        xticklabels({'-1','0','1'});
        ylim([-1 3]);
        colormap jet;
        title(eventFieldnames{iEvent});
        hold on;
    end
end
legend(lns,trialTypes);