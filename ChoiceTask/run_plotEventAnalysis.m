% [burstEventData,lfpEventData,t,freqList,eventFieldnames] = lfpEventAnalysis(analysisConf);

plotEventIdx = [1 2 4 3 5 6 8];
saveRows = 4;
fontSize = 6;
iSubplot = 1;

for iNeuron=1:size(analysisConf.neurons,1)
    if (iSubplot - 1) / length(plotEventIdx) == saveRows
        if exist('fig','var')
            clear fig;
        end
        fig = formatSheet();
        iSubplot = 1;
    end
        
    eventScalogramData = lfpEventData{iNeuron};
    for iEvent=plotEventIdx
        subplot(saveRows,length(plotEventIdx),iSubplot);
        imagesc(t,freqList,log(squeeze(eventScalogramData(iEvent,:,:)))); 
        ylabel('Frequency (Hz)');
        xlabel('Time (s)');
        set(gca, 'YDir', 'normal');
        xlim([-1 1]);
        ylim([0 80]);
        title({analysisConf.neurons{iNeuron},eventFieldnames{iEvent}});
        colormap(jet);
        
        iSubplot = iSubplot + 1;
    end
    
    eventBurstData = burstEventData{iNeuron};
    for iEvent=plotEventIdx
        subplot(saveRows,length(plotEventIdx),iSubplot);
        [counts,centers] = hist(eventBurstData.all{iEvent},50);
        plot(centers,counts);
        hold on;
        [counts,centers] = hist(eventBurstData.burst{iEvent},50);
        plot(centers,counts);
        xlim([-1 1]);
        title({analysisConf.neurons{iNeuron},eventFieldnames{iEvent}});
        
        iSubplot = iSubplot + 1;
    end
    
    % figure handling
    if exist('fig','var')
        clear fig;
    end
end