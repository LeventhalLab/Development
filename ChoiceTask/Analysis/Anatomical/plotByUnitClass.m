% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
colors = jet(7);
atlas_ims = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(rows,:);
    event_id = eventIds_by_maxHistValues(iNeuron);
    if isempty(channelData)
        continue;
    end
    wiggle = (rand(1) - 0.5) * 0.2;
    AP = channelData{1,'ap'} + wiggle;
    ML = channelData{1,'ml'} + wiggle;
    DV = channelData{1,'dv'} + wiggle;
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,colors(event_id,:));
end

figure('position',[0 0 1400 600]);
subplot(131);
imshow(atlas_ims{1});
title('FR');
subplot(132);
imshow(atlas_ims{2});
subplot(133);
imshow(atlas_ims{3});
hold on;
ax = [];
xlims = xlim;
ylims = ylim;
for ii = 1:size(colors,1)
    ax(ii) = plot(xlims(1),ylims(1),'.','markerSize',20,'color',colors(ii,:));
    hold on;
end

legend(ax,eventFieldnames);