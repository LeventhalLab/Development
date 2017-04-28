figure('position',[0 0 1000 800]);
useEvents = [1:7];
colors = jet(4);
lgdMarkers = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    subjects__name = neuronName(1:5);
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(sum(rows,2)),:);
    event_id = eventIds_by_maxHistValues(iNeuron);
    if ~ismember(event_id,useEvents)
        continue;
    end
    if isempty(channelData)
        continue;
    end
    wiggle = (rand(1) - 0.5) * 0.1;
    AP = channelData{1,'ap'} + wiggle;
    ML = channelData{1,'ml'} + wiggle;
    DV = channelData{1,'dv'} + wiggle;
    
    [~,colorIdx] = ismember(subjects__name,analysisConf.subjects);
    for iSubplot = 1:2
        subplot(1,2,iSubplot);
        useData = AP;
        if iSubplot == 2
            useData = DV;
        end
        lgdMarkers(colorIdx) = plot(event_id+(colorIdx*.1)-.1,useData,'o','markerSize',6,'MarkerFaceColor',colors(colorIdx,:),'lineWidth',0.2,'MarkerEdgeColor','k');
        hold on;
    end
end
% formatting
for iSubplot = 1:2
    ax = subplot(1,2,iSubplot);
    ylabel('AP');
    if iSubplot == 2
        ylabel('DV');
        set(gca,'ydir','reverse');
    end
    legend(ax,lgdMarkers,analysisConf.subjects,'location','northoutside');
    xticklabels(eventFieldnames);
    xtickangle(90);
    grid on;
end