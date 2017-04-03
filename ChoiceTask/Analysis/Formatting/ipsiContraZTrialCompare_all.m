figure('position',[0 0 1600 700]);
iSubplot = 1;
x = linspace(-tWindow,tWindow,size(zCounts,3));
% neurons = [1,3,9,5,18,19,10,16,22,25,26,38,30,39,41,51,58,63,65,70,71,80,87,74,75];
eventClassifier = 7;
neurons = find(eventIds_by_maxHistValues == eventClassifier);
onlyPlotEvents = [1:7];
nSmooth = 3;
rows = 5;
cols = numel(onlyPlotEvents);
legendLabels = {['Contra Correct'],...
            ['Ipsi Correct'],...
            ['Contra Incorrect'],...
            ['Ipsi Incorrect']};
for iEvent = onlyPlotEvents
    cur_all_tidx_contra_correct = (squeeze(all_tidx_contra_correct(neurons,iEvent,:,:)));
    cur_all_tidx_contra_incorrect = (squeeze(all_tidx_contra_incorrect(neurons,iEvent,:,:)));
    cur_all_tidx_ipsi_correct = (squeeze(all_tidx_ipsi_correct(neurons,iEvent,:,:)));
    cur_all_tidx_ipsi_incorrect = (squeeze(all_tidx_ipsi_incorrect(neurons,iEvent,:,:)));
    
    subplot(rows,cols,iSubplot);
    hold on; grid on;
    plot(x,smooth(nanmean(cur_all_tidx_contra_correct,1),nSmooth),'linewidth',2);
    plot(x,smooth(nanmean(cur_all_tidx_ipsi_correct,1),nSmooth),'linewidth',2);
    plot(x,smooth(nanmean(cur_all_tidx_contra_incorrect,1),nSmooth),'linewidth',0.75);
    plot(x,smooth(nanmean(cur_all_tidx_ipsi_incorrect,1),nSmooth),'linewidth',0.75);
    ylim([-0.5 1]);
    xlim([-1 1]);
    if iEvent == eventClassifier
        title(['***',eventFieldnames{iEvent},'***']);
    else
        title(eventFieldnames{iEvent});
    end
    if iSubplot == 1
        lgd = legend(legendLabels,'location','south');
        lgd.FontSize = 10;
        set(lgd,'position',[0 0.85 .1 .1]);
    end
    
    subplot(rows,cols,iSubplot + cols*1);
    hold on; grid on;
    plot(x,cur_all_tidx_contra_correct','linewidth',0.5,'color',[.5 .5 .5 .5]);
    ylim([-2 4]);
    xlim([-1 1]);
    title(legendLabels{1},'fontsize',6);
    
    subplot(rows,cols,iSubplot + cols*2);
    hold on; grid on;
    plot(x,cur_all_tidx_ipsi_correct','linewidth',0.5,'color',[.5 .5 .5 .5]);
    ylim([-2 4]);
    xlim([-1 1]);
    title(legendLabels{2},'fontsize',6);
    
    subplot(rows,cols,iSubplot + cols*3);
    hold on; grid on;
    plot(x,cur_all_tidx_contra_incorrect','linewidth',0.5,'color',[.5 .5 .5 .5]);
    ylim([-2 4]);
    xlim([-1 1]);
    title(legendLabels{3},'fontsize',6);
    
    subplot(rows,cols,iSubplot + cols*4);
    hold on; grid on;
    plot(x,cur_all_tidx_ipsi_incorrect','linewidth',0.5,'color',[.5 .5 .5 .5]);
    ylim([-2 4]);
    xlim([-1 1]);
    title(legendLabels{4},'fontsize',6);
    
    iSubplot = iSubplot + 1;
end