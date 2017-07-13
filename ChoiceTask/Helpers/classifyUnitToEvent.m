% timingField = 'RT';
% tWindow = 2;
smallFontSize = 10;

useRange = [];

for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    channelData = get_channelData(sessionConf,electrodeChannels);

    AP = channelData{1,'ap'};
    ML = channelData{1,'ml'};
    DV = channelData{1,'dv'};
%     shapeId = testAnatomyShapes(shapes,ML,AP,DV);
end

% close all;

% % for iNeuron = 1:size(all_trials,2)
% %     timingField = 'RT';
% %     [trialIds,allTimes] = sortTrialsBy(all_trials{1,iNeuron},timingField);
% %     all_meanTiming(iNeuron) = mean(allTimes(trialIds));
% % end
colors = jet(7);
colors_subject = jet(4);
useEvents = [1:7];
onlyPlotEvents = [1:7];
% % range_R0088 = 1:40;
% % range_R0117 = 41:62;
% % range_R0142 = 63:300;
% % range_R0154 = 301:343;
useRange = 1:343;%range_R0142;
neuronPeth_sub = neuronPeth(useRange,useEvents,:);
all_tidx_contra_correct_sub = all_tidx_contra_correct(useRange,:,:,:);
all_tidx_ipsi_correct_sub = all_tidx_ipsi_correct(useRange,:,:,:);

[maxHistValues,maxHistTimes] = max(abs(neuronPeth_sub),[],3);
% [maxHistValues,maxHistTimes] = max((neuronPeth),[],3);
[maxHistValues_max,eventIds] = max(maxHistValues,[],2);

eventIds_by_maxHistValues = eventIds; % used by other script

maxHistTimes_of_eventIds = diag(maxHistTimes(:,eventIds));
[~,sorted_maxHistTimes] = sort(maxHistTimes_of_eventIds,'ascend');
eventIds = eventIds(sorted_maxHistTimes);
[sorted_eventIds,sorted_eventKeys] = sort(eventIds);
sorted_eventKeys = sorted_maxHistTimes(sorted_eventKeys);

% [v3,k3] = sort(all_meanTiming);
neuronPethSortedByEvent = neuronPeth_sub(sorted_eventKeys,:,:);

figure('position',[0 0 900 400]);
set(gcf,'color','w');
iSubplot = 1;
extraPlots = 0;
all_markerIds = [];
for iEvent = 1:size(neuronPeth_sub,2)
    if ~ismember(iEvent,onlyPlotEvents)
        continue;
    end
    subplot(1,size(onlyPlotEvents,2)+extraPlots,iSubplot);
    
    imagesc(squeeze(neuronPethSortedByEvent(:,iEvent,:)));
%     imagesc(squeeze(neuronPethSortedByEvent(randperm(size(neuronPethSortedByEvent,1)),iEvent,:)));
    hold on;
    
    xZero = round(size(neuronPeth,3) / 2);
    plot([xZero xZero],[1 size(neuronPeth,1)],'--','color',[.5 .5 .5]);
    
    markerIds = find(sorted_eventIds == iEvent);
    all_markerIds = [all_markerIds;markerIds];
    plot(ones(1,numel(markerIds)),markerIds,'S','markerSize',10,'color','k','MarkerFaceColor','k');
    
    colormap(jet);
    caxis([-1 1.5]);
    xtickVals = linspace(1,size(neuronPeth,3),3);
    xticks(xtickVals);
    xticklabels([-tWindow 0 tWindow]);
    xlim([xtickVals(1) xtickVals(end)]);
%     ytickVals = [1 size(neuronPeth,1)];
    ytickVals = [];
    yticks(ytickVals);
%     yticklabels(repmat('',1,numel(ytickVals)));
    
    titleStr = eventFieldnames{iEvent};
    if iEvent == 1
        yticklabels(sorted_eventIds);
%         ylabel('max z-event');
%         title({analysisConf.subjects__name,titleStr});
    end
    title([titleStr,', ',num2str(numel(markerIds)),' units']);%,'color',colors(iEvent,:));
    xlabel('Time (s)');
    set(gca,'fontSize',smallFontSize,'FontName','Arial');
    
    iSubplot = iSubplot + 1;
end
iSubplot = 1;
for iEvent = 1:size(neuronPeth_sub,2)
    if ~ismember(iEvent,onlyPlotEvents)
        continue;
    end
    subplot(1,size(onlyPlotEvents,2)+extraPlots,iSubplot);
    ylim([min(all_markerIds) max(all_markerIds)]);
    iSubplot = iSubplot + 1;
end