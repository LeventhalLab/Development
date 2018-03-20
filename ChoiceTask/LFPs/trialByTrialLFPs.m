vis_tWindow = 1;
t1Idx = closest(t,-vis_tWindow);
t2Idx = closest(t,vis_tWindow);
t_vis = linspace(-vis_tWindow,vis_tWindow,numel(t1Idx:t2Idx));
fontSize = 10;
    
caxisVals = [4 6];
if false
    [eventScalograms,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList,{eventFieldnames{useEvents}});
    rows = 1;
    cols = size(eventScalograms,1);
    figuree(120*cols,200);
    iSubplot = 1;
    for iEvent = 1:size(eventScalograms,1)
        ax = subplot(rows,cols,iSubplot);
        scaloData = squeeze(eventScalograms(iEvent,:,t1Idx:t2Idx));
        imagesc(t_vis,freqList,scaloData);
        title(eventFieldnames{iEvent});

        if iEvent == 1
            ylabel('Freq (Hz)');
            yticks(1:numel(freqList));
            yticklabels(freqList);
        else
            set(ax,'yTickLabel',[]);
        end

        set(ax,'YDir','normal');
        xlim([-vis_tWindow vis_tWindow]);
        xticks([-vis_tWindow 0 vis_tWindow]);

        set(ax,'TickDir','out');
        set(ax,'FontSize',fontSize);
        colormap(jet);
%         caxis(caxisVals);

        iSubplot = iSubplot + 1;
    end
end

cols = numel(useEvents);
rows = 8;%numel(allTimes);
h = figuree(120*cols,900);
caxisVals = [0 400];
iSubplot = 1;
noseOutVals = [];

for iTrial = 1:numel(trialIds)
    curTrialId = trialIds(iTrial);
    curTrial = trials(curTrialId);
    [eventScalograms,allLfpData] = eventsScalo(curTrial,sevFilt,tWindow,Fs,freqList,{eventFieldnames{useEvents}});
    
    if mod(iTrial,rows*cols+1) == 0
        h = figuree(120*cols,700);
        iSubplot = 1;
    end

    for iEvent = 4
        ax = subplot(rows,cols,iSubplot);
        scaloData = squeeze(eventScalograms(iEvent,:,t1Idx:t2Idx));
        imagesc(t_vis,freqList,scaloData);
        title([num2str(iTrial),', ',eventFieldnames{iEvent}]);
            
% %         if iEvent == 1
% %             ylabel({'Freq (Hz)',num2str(allTimes(iTrial),3)});
% %             yticks(1:numel(freqList));
% %             yticklabels(freqList);
% %         else
            set(ax,'yTickLabel',[]);
% %         end
        
% %         qtrSec = round((size(scaloData,2) / 2) / 4);
% %         noseOutVals(iEvent,iTrial) = mean(mean(scaloData(:,(size(scaloData,2)/2)-qtrSec:(size(scaloData,2)/2)+qtrSec)));
        
        set(ax,'YDir','normal');
        xlim([-vis_tWindow vis_tWindow]);
        xticks([-vis_tWindow 0 vis_tWindow]);

        set(ax,'TickDir','out');
        set(ax,'FontSize',fontSize);
        colormap(jet);
        caxis(caxisVals);

        iSubplot = iSubplot + 1;
    end
    drawnow;
end
% tightfig;

% % if false
% %     figuree(800,300);
% %     for iEvent = 1:numel(eventFieldnames)
% %         subplot(1,7,iEvent);
% %         plot(allTimes,noseOutVals(iEvent,:),'k.','markerSize',20);
% %         [rho,pval] = corr(allTimes',noseOutVals(iEvent,:)');
% %         title({['rho: ',num2str(rho,3)],['pval: ',num2str(pval)]});
% %     end
% % end