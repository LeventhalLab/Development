% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
colors = jet(7);
atlas_ims = [];
useEvents = [3,4];
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows)',:);
    event_id = eventIds_by_maxHistValues(iNeuron);
    if ~ismember(event_id,useEvents)
        continue;
    end
    if isempty(channelData)
        continue;
    end
    wiggle = (rand(1) - 0.5) * 0.1;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    ML = channelData{1,'ml'};
    wiggle = (rand(1) - 0.5) * 0.1;
    DV = channelData{1,'dv'} + wiggle;
    
    if ismember(iNeuron,neuronIds(curatedIds))
        useColor = colors(7,:);
    else
       useColor = colors(event_id,:);
    end
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,useColor);
end

figure('position',[0 0 1400 600]);
set(gcf,'color','w');
subplot(131);
imshow(atlas_ims{1});
title('Event Class');
subplot(132);
imshow(atlas_ims{2});
subplot(133);
imshow(atlas_ims{3});
hold on;

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