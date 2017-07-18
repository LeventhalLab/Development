% compile all z-scores

imsc = [];

% compile event classes
neuronClasses = {};
for iEvent = 1:numel(eventFieldnames)
    neuronClasses{iEvent} = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        if isempty(unitEvents{iNeuron}.correct.class)
            continue;
        end
        if unitEvents{iNeuron}.correct.class(1) == iEvent
            neuronClasses{iEvent} = [neuronClasses{iEvent} iNeuron];
        end
    end
end

% sort those event classes
sorted_neuronClasses = {};
for iEvent = 1:numel(eventFieldnames)
    curEvent_maxbins = [];
    cur_neuronClasses = neuronClasses{iEvent};
    for iNeuron = 1:numel(cur_neuronClasses)
        neuronId = cur_neuronClasses(iNeuron);
        curEvent_maxbins(iNeuron) = unitEvents{neuronId}.correct.maxbin(iEvent);
    end
    [v,k] = sort(curEvent_maxbins);
    sorted_neuronClasses{iEvent} = cur_neuronClasses(k);
end

% remap neuronIds
sorted_neuronIds = [];
markerLocs = [0];
for iEvent = 1:numel(eventFieldnames)
    sorted_neuronIds = [sorted_neuronIds sorted_neuronClasses{iEvent}];
    markerLocs = [markerLocs numel(sorted_neuronIds)];
end

figuree(1200,800);
for iEvent = 1:numel(eventFieldnames)
    subplot(1,numel(eventFieldnames),iEvent);
    imagesc(squeeze(all_zscores(corr_sorted_neuronIds,iEvent,:)));
    caxis([-3 8]);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    yticks([1 numel(analysisConf.neurons)]);
    colormap jet;
    title(eventFieldnames{iEvent});
    hold on;
    plot([20 20],[1 numel(analysisConf.neurons)],'k--');
    markerRange = corr_markerLocs(iEvent)+1:corr_markerLocs(iEvent+1);
    plot(ones(numel(markerRange),1),markerRange,'k.','MarkerSize',20);
%     markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
%     plot(ones(numel(markerRange),1),markerRange,'r.','MarkerSize',10);
end

figuree(1200,400);
for iEvent = 1:numel(eventFieldnames)
    subplot(1,numel(eventFieldnames),iEvent);
    plot(nanmean(squeeze(all_zscores(sorted_neuronIds,iEvent,:)))); % insert corr_
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    ylim([-2 5]);
    colormap jet;
    title(eventFieldnames{iEvent});
    hold on;
end