colors = jet(7);
all_shapeIds = [];
traceAnatomyShowShapes();
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    channelData = get_channelData(sessionConf,electrodeChannels);
    
    sortedNeuronIdx = find(sorted_eventKeys == iNeuron);
    neuronEvent = sorted_eventIds(sortedNeuronIdx);

    wiggle = (rand(1) - 0.5) * 0.1;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    ML = channelData{1,'ml'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    DV = channelData{1,'dv'} * -1  + wiggle;
    shapeId = testAnatomyShapes(shapes,ML,AP,DV);
    hold on;
    plot3(AP,ML,DV,'k.','MarkerSize',30,'color',colors(neuronEvent,:));
    all_shapeIds(iNeuron) = shapeId;
    if shapeId == 4
        disp('hold');
    end
end

ax = [];
xlims = xlim;
ylims = ylim;
for ii = 1:numel(useEvents)
    ax(ii) = plot(xlims(1),ylims(1),'.','markerSize',20,'color',colors(useEvents(ii),:));
    hold on;
end
legend(ax,eventFieldnames(useEvents));
drawnow;
delete(ax);

figure;
hist(all_shapeIds,[-1 0 1 2 3 4 5]);
xticklabels({'','None','VM','VA','VL','Rt',''});