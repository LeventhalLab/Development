plotEventIdx = [1 2 4 3 5 6 8];
saveRows = 4;
fontSize = 6; 
iSubplot = 1;
histBinSec = 0.05; % seconds
scalogramWindow = 2; % seconds (this needs to be passed back I think)
histBin = scalogramWindow / histBinSec;
smoothZ = 5;

for iNeuron=1:size(analysisConf.neurons,1)
    if (iSubplot - 1) / length(plotEventIdx) == saveRows
        if exist('fig','var')
            clear fig;
        end
        fig = formatSheet();
        iSubplot = 1;
    end
        
    eventData = lfpEventData{iNeuron};
    for iEvent=plotEventIdx
        subplot(saveRows,length(plotEventIdx),iSubplot);
        imagesc(t,freqList,log(squeeze(eventData(iEvent,:,:)))); 
        ylabel('Frequency (Hz)');
        xlabel('Time (s)');
        set(gca, 'YDir', 'normal');
        xlim([-1 1]);
        ylim([0 80]);
        title({analysisConf.neurons{iNeuron},eventFieldnames{iEvent}});
        colormap(jet);
        
        iSubplot = iSubplot + 1;
    end
    
    eventData = burstEventData{iNeuron};
    for iEvent=plotEventIdx
        subplot(saveRows,length(plotEventIdx),iSubplot);
        hold on;
        
        [zMean,zStd] = helpZscore(eventData.ts,scalogramWindow,histBin);
        [counts,centers] = hist(eventData.tsEvents{iEvent},histBin);
        counts = counts / correctTrialCount(iNeuron);
        zCounts = (counts - zMean)/zStd;
        plot(centers,smooth(zCounts,smoothZ));
        
        [zMean,zStd] = helpZscore(eventData.tsBurst,scalogramWindow,histBin);
        [counts,centers] = hist(eventData.tsBurstEvents{iEvent},histBin);
        counts = counts / correctTrialCount(iNeuron);
        zCounts = (counts - zMean)/zStd;
        plot(centers,smooth(zCounts,smoothZ));
        
        [zMean,zStd] = helpZscore(eventData.tsLTS,scalogramWindow,histBin);
        [counts,centers] = hist(eventData.tsLTSEvents{iEvent},histBin);
        counts = counts / correctTrialCount(iNeuron);
        zCounts = (counts - zMean)/zStd;
        plot(centers,smooth(zCounts,smoothZ));
        
        [zMean,zStd] = helpZscore(eventData.tsPoisson,scalogramWindow,histBin);
        [counts,centers] = hist(eventData.tsPoissonEvents{iEvent},histBin);
        counts = counts / correctTrialCount(iNeuron);
        zCounts = (counts - zMean)/zStd;
        plot(centers,smooth(zCounts,smoothZ));
        
        if iEvent == 1
            legend('All','Burst','LTS','Poisson');
        end
        ylabel('Z');
        xlabel('t');
        xlim([-1 1]);
        ylim([-10 10]);
        title({analysisConf.neurons{iNeuron},eventFieldnames{iEvent}});
        
        iSubplot = iSubplot + 1;
    end
    
    % figure handling
    if exist('fig','var')
        clear fig;
    end
end