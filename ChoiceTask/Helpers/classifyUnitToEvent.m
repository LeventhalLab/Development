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


[maxHistValues,maxHistTimes] = max(abs(neuronPeth),[],3);
% [maxHistValues,maxHistTimes] = max((neuronPeth),[],3);
[~,eventIds] = max(maxHistValues,[],2);
maxHistTimes_of_eventIds = diag(maxHistTimes(:,eventIds));
[~,k] = sort(maxHistTimes_of_eventIds,'ascend');
eventIds = eventIds(k);
[v3,k3] = sort(eventIds);
k3 = k(k3);



% [v3,k3] = sort(all_meanTiming);
neuronPethSortedByEvent = neuronPeth(k3,:,:);

figure('position',[100 100 1100 800]);
iSubplot = 1;
for iEvent = plotEventIds
    subplot(1,numel(plotEventIds)+2,iSubplot);
    imagesc(squeeze(neuronPethSortedByEvent(:,iEvent,:)));
    hold on;
    xZero = round(size(neuronPeth,3) / 2);
    plot([xZero xZero],[1 size(neuronPeth,1)],'k');
    colormap(jet);
    caxis([-1.5 1.5]);
    xtickVals = linspace(0,size(neuronPeth,3),3);
    xticks(xtickVals);
    xticklabels([-tWindow 0 tWindow]);
    xlim([xtickVals(1) xtickVals(end)]);
    ytickVals = [1:size(neuronPeth,1)];
    yticks(ytickVals);
    yticklabels(repmat('',1,numel(ytickVals)));
    
    titleStr = [eventFieldnames{iEvent},' (',num2str(iEvent),')'];
    if iEvent == 1
        yticklabels(v3);
        ylabel('max z-event');
        title({analysisConf.subjects__name,titleStr});
    else
        title(titleStr);
    end
    xlabel('time (s)');
    set(gca,'fontSize',smallFontSize);
    
    iSubplot = iSubplot + 1;
end
subplot(1,numel(plotEventIds)+2,iSubplot);
plot(all_meanTiming(k3),flip([1:size(neuronPeth,1)]),'r.','markerSize',25);
ytickVals = [1:size(neuronPeth,1)];
yticks(ytickVals);
yticklabels(flip(ytickVals));
ylim([0.5 size(neuronPeth,1)+0.5]);
ylabel('unit #');
xlabel(timingField);
set(gca,'fontSize',smallFontSize);
grid on;

iSubplot = iSubplot + 1;

subplot(1,numel(plotEventIds)+2,iSubplot);
plot(v3,flip([1:size(neuronPeth,1)]),'b.','markerSize',25);
xtickVals = [1:8];
xticks(xtickVals);
xticklabels([1 2 4 3 5 6 7 8]);
xlabel('event #');
ytickVals = [1:size(neuronPeth,1)];
yticks(ytickVals);
yticklabels(flip(ytickVals));
ylim([0.5 size(neuronPeth,1)+0.5]);
set(gca,'fontSize',smallFontSize);
grid on;

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