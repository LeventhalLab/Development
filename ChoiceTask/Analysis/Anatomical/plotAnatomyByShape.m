all_shapeIds = [];
traceAnatomyShowShapes();
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    channelData = get_channelData(sessionConf,electrodeChannels);

    wiggle = (rand(1) - 0.5) * 0.1;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    ML = channelData{1,'ml'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    DV = channelData{1,'dv'} * -1  + wiggle;
    shapeId = testAnatomyShapes(shapes,ML,AP,DV);
    hold on;
    plot3(AP,ML,DV,'k.','MarkerSize',20);
    all_shapeIds(iNeuron) = shapeId;
end

figure;
hist(all_shapeIds,[-1 0 1 2 3 4 5]);