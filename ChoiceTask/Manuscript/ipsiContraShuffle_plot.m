pVal = 0.95;
figuree(1200,400);
for iEvent = 1:numel(useEvents)
    subplot(1,numel(useEvents),iEvent)
    eventBins = zeros(1,size(pNeuronDiff,3));
    for iNeuron = 1:size(pNeuronDiff,1)
        curBins = squeeze(pNeuronDiff(iNeuron,iEvent,:)); % 40 bins per-event
        eventBins = eventBins + (curBins > pVal);
    end
    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor','k','EdgeColor','none');
    ylim([0 1]);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    xlabel(eventFieldnames{iEvent});
    if iEvent == 1
        ylabel('Fraction of units < 0.05');
    end
end