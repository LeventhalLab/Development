% see ipsiContraShuffle.m
useEvents = [1:7];

pVal = 0.95;
figuree(1200,400);
for iEvent = 1:numel(useEvents)
    subplot(1,numel(useEvents),iEvent)
    eventBins = zeros(1,size(pNeuronDiff,3));
    for iNeuron = 1:size(pNeuronDiff,1)
        if ~isempty(unitEvents{iNeuron}.class)%% && unitEvents{iNeuron}.class(1) == 3 % tone
            curBins = squeeze(pNeuronDiff(iNeuron,iEvent,:)); % 40 bins per-event
            eventBins = eventBins + (curBins > pVal);
        end
    end

%     bar(1:size(pNeuronDiff,3),eventBins/numel(toneNeurons),'FaceColor','k','EdgeColor','none'); % POSITIVE
    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor','k','EdgeColor','none'); % POSITIVE
    hold on;
% %     ylim([0 0.4]);
% %     yticks([0:0.2:0.4]);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
    xlabel(eventFieldnames{iEvent});
    if iEvent == 1
        ylabel('Fraction of units < 0.05');
    end
end

if false
    for iEvent = 1:numel(useEvents)
        subplot(1,numel(useEvents),iEvent)
        eventBins = zeros(1,size(pNeuronDiff,3));
        for iNeuron = 1:size(pNeuronDiff,1)
            if ~isempty(unitEvents{iNeuron}.class) && unitEvents{iNeuron}.class(1) == 4 % centerOut
                curBins = squeeze(pNeuronDiff(iNeuron,iEvent,:)); % 40 bins per-event
                eventBins = eventBins + (curBins > pVal);
            end
        end

    % %     bar(1:size(pNeuronDiff,3),-eventBins/size(pNeuronDiff,1),'FaceColor','k','EdgeColor','none'); % NEGATIVE
        bar(1:size(pNeuronDiff,3),-eventBins/numel(centerOutNeurons),'FaceColor','k','EdgeColor','none'); % NEGATIVE
        ylim([-1 1]);
    %     yticks([0:0.2:0.4]);
        xlim([1 40]);
        xticks([1 20 40]);
        xticklabels({'-1','0','1'});
        grid on;
        title(eventFieldnames{iEvent});
        if iEvent == 1
            ylabel('Fraction of units < 0.05');
        end
    end
end