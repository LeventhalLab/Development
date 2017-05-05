% timingField = 'RT';
% eventFieldnames = fieldnames(trials(2).timestamps);
% tWindow = 2;
smallFontSize = 8;

% close all;

% % for iNeuron = 1:size(all_trials,2)
% %     timingField = 'RT';
% %     [trialIds,allTimes] = sortTrialsBy(all_trials{1,iNeuron},timingField);
% %     all_meanTiming(iNeuron) = mean(allTimes(trialIds));
% % end
colors = jet(7);
colors_subject = jet(4);
useEvents = [1:7];
range_R0088 = 1:40;
range_R0117 = 41:62;
range_R0142 = 63:300;
range_R0154 = 301:343;
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

figure('position',[0 0 1400 800]);
set(gcf,'color','w');
iSubplot = 1;
extraPlots = 0;
for iEvent = 1:numel(eventFieldnames)
    subplot(1,numel(eventFieldnames)+extraPlots,iSubplot);
    
    imagesc(squeeze(neuronPethSortedByEvent(:,iEvent,:)));
%     imagesc(squeeze(neuronPethSortedByEvent(randperm(size(neuronPethSortedByEvent,1)),iEvent,:)));
    hold on;
    
    xZero = round(size(neuronPeth,3) / 2);
    plot([xZero xZero],[1 size(neuronPeth,1)],'--','color',[.5 .5 .5]);
    
    markerIds = find(sorted_eventIds == iEvent);
    plot(zeros(1,numel(markerIds)),markerIds,'.','markerSize',10,'color','k');
    
    colormap(jet);
    caxis([-1 1.2]);
    xtickVals = linspace(0,size(neuronPeth,3),3);
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
%     title(titleStr,'color',colors(iEvent,:));
    xlabel('time (s)');
    set(gca,'fontSize',smallFontSize);
    
    iSubplot = iSubplot + 1;
end

% % neuronNames_sub = analysisConf.neurons(useRange);
% % sessionConfs_sub = analysisConf.sessionConfs(useRange);
% % for iNeuron = 1:numel(sorted_eventKeys)
% %     neuronName = neuronNames_sub{sorted_eventKeys(iNeuron)};
% %     subjects__name = neuronName(1:5);
% %     switch subjects__name
% %         case 'R0088'
% %             colorsIdx = 1;
% %         case 'R0117'
% %             colorsIdx = 2;
% %         case 'R0142'
% %             colorsIdx = 3;
% %         case 'R0154'
% %             colorsIdx = 4;
% %     end
% %     sessionConf = sessionConfs_sub{sorted_eventKeys(iNeuron)};
% %     [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
% %     rows = sessionConf.session_electrodes.channel == electrodeChannels;
% %     channelData = sessionConf.session_electrodes(any(sum(rows,2)),:);
% %     AP = channelData{1,'ap'};
% %     ML = channelData{1,'ml'};
% %     DV = channelData{1,'dv'};
% %     
% %     subplot(1,numel(eventFieldnames)+extraPlots,numel(eventFieldnames)+1);
% %     plot(AP,iNeuron,'.','markerSize',10,'color',colors(sorted_eventIds(iNeuron),:));
% %     hold on;grid on;
% %     xlabel('AP');
% %     set(gca,'ydir','reverse');
% %     xlim([-3.5 -2.8]);
% %     yticks(ytickVals);
% %     yticklabels(sorted_eventIds);
% %     set(gca,'fontSize',smallFontSize);
% %     
% %     subplot(1,numel(eventFieldnames)+extraPlots,numel(eventFieldnames)+2);
% %     plot(DV,iNeuron,'.','markerSize',10,'color',colors_subject(colorsIdx,:));
% % %     plot(DV,iNeuron,'.','markerSize',10,'color',colors(sorted_eventIds(iNeuron),:));
% %     hold on;grid on;
% %     xlabel('DV');
% %     set(gca,'ydir','reverse');
% %     xlim([5.8 7.8]);
% %     yticks(ytickVals);
% %     yticklabels(sorted_eventIds);
% %     set(gca,'fontSize',smallFontSize);
% % end

% subplot(1,numel(plotEventIds)+2,iSubplot);
% plot(all_meanTiming(k3),flip([1:size(neuronPeth,1)]),'r.','markerSize',25);
% ytickVals = [1:size(neuronPeth,1)];
% yticks(ytickVals);
% yticklabels(flip(ytickVals));
% ylim([0.5 size(neuronPeth,1)+0.5]);
% ylabel('unit #');
% xlabel(timingField);
% set(gca,'fontSize',smallFontSize);
% grid on;
% 
% iSubplot = iSubplot + 1;
% 
% subplot(1,numel(plotEventIds)+2,iSubplot);
% plot(v3,flip([1:size(neuronPeth,1)]),'b.','markerSize',25);
% xtickVals = [1:8];
% xticks(xtickVals);
% xticklabels([1 2 4 3 5 6 7 8]);
% xlabel('event #');
% ytickVals = [1:size(neuronPeth,1)];
% yticks(ytickVals);
% yticklabels(flip(ytickVals));
% ylim([0.5 size(neuronPeth,1)+0.5]);
% set(gca,'fontSize',smallFontSize);
% grid on;

% hcb = colorbar;
% title(hcb,'Z');
% % 
% % maxNeuronZ = [];
% % for iNeuron = 1:size(all_eventPetz,2)
% %     neuronPetz = all_eventPetz{iNeuron};
% %     figure('position',[500 0 1300 400]);
% %     for iEvent = 1:size(neuronPetz,1)
% %         neuronEventPetz = cell2mat(neuronPetz(iEvent,:)');
% %         meanPetz = mean(neuronEventPetz);
% %         maxNeuronZ(iEvent,iNeuron) = max(meanPetz);
% %         subplot(1,8,iEvent);
% % %         plot(neuronEventPetz','color',[.5 .5 .5 .5]);
% % %         hold on;
% %         plot(diff(meanPetz),'r','linewidth',3);
% % %         ylim([-1 6]);
% %     end
% % end
% % % close all;
% % [~,k] = max(maxNeuronZ);
% % [v,k2] = sort(k);
% % figure('position',[0 0 1000 700]);
% % for ii=1:2
% %     subplot(1,3,ii);
% %     if ii==1
% %         imagesc(maxNeuronZ');
% %         title({analysisConf.subjects__name,'sorted by RT'});
% %         ylabel('unit');
% %     else
% %         imagesc(maxNeuronZ(:,k2)');
% %         title('sorted by event');
% %     end
% %     colormap(jet);
% %     hcb = colorbar;
% %     title(hcb,'Z');
% %     caxis([-2 2]);
% %     xticks(1:8);
% %     xticklabels(eventFieldnames);
% %     xtickangle(90);
% % end
% % subplot(133);
% % [counts,centers] = hist(k,[1:8]);
% % bar(centers,counts);
% % xticks(centers);
% % xticklabels([1:8]);
% % xlim([0 9]);
% % xticklabels(eventFieldnames);
% % xtickangle(90);
% % title('event distribution');
% % grid on;