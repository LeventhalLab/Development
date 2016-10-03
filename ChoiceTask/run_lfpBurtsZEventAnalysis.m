plotEventIdx = [1 2 4 3 5 6 8];
saveRows = 2; % top:LFP, bottom:Z-score
fontSize = 6; 
histBinSec = 0.05; % seconds
scalogramWindow = 2; % seconds (this needs to be passed back I think)
histBin = scalogramWindow / histBinSec;
smoothZ = 5;

for iNeuron=1:size(analysisConf.neurons,1)
    iSubplot = 1;
    neuronName = strrep(analysisConf.neurons{iNeuron},'_','-');
    fig = formatSheet();
    set(fig,'PaperPosition', [1 8 28 10]);
    eventData = lfpEventData{iNeuron};
    
    v = [];
    for iEvent=plotEventIdx
        subplot(saveRows,length(plotEventIdx),iSubplot);
        imagesc(t,freqList,log(squeeze(eventData(iEvent,:,:)))); 
        ylabel('Frequency (Hz)');
        xlabel('Time (s)');
        set(gca, 'YDir', 'normal');
        xlim([-1 1]);
%         ylim([1 80]);
        if iSubplot == 1
            title({neuronName,eventFieldnames{iEvent}});
        else
            title({'',eventFieldnames{iEvent}});
        end
        colormap(jet);
        v(iEvent,:) = caxis;
        iSubplot = iSubplot + 1;
    end
    
    % set all caxis to 25% full range
    caxisValues = upperLowerPrctile(v(:),25);
    for ii=1:iSubplot-1
        subplot(saveRows,length(plotEventIdx),ii);
        caxis(caxisValues);
    end
    
    eventData = burstEventData{iNeuron};
    for iEvent=plotEventIdx
        subplot(saveRows,length(plotEventIdx),iSubplot);
        hold on;
        
        if ~isempty(eventData.ts)
            [zMean,zStd] = helpZscore(eventData.ts,scalogramWindow,histBin);
            [counts,centers] = hist(eventData.tsEvents{iEvent},histBin);
            counts = counts / correctTrialCount(iNeuron);
            zCounts = (counts - zMean)/zStd;
            plot(centers,smooth(zCounts,smoothZ));
        end
        if ~isempty(eventData.tsBurst)
            [zMean,zStd] = helpZscore(eventData.tsBurst,scalogramWindow,histBin);
            [counts,centers] = hist(eventData.tsBurstEvents{iEvent},histBin);
            counts = counts / correctTrialCount(iNeuron);
            zCounts = (counts - zMean)/zStd;
            plot(centers,smooth(zCounts,smoothZ));
        end
        if ~isempty(eventData.tsLTS)
            [zMean,zStd] = helpZscore(eventData.tsLTS,scalogramWindow,histBin);
            [counts,centers] = hist(eventData.tsLTSEvents{iEvent},histBin);
            counts = counts / correctTrialCount(iNeuron);
            zCounts = (counts - zMean)/zStd;
            plot(centers,smooth(zCounts,smoothZ));
        end
        if ~isempty(eventData.tsPoisson)
            [zMean,zStd] = helpZscore(eventData.tsPoisson,scalogramWindow,histBin);
            [counts,centers] = hist(eventData.tsPoissonEvents{iEvent},histBin);
            counts = counts / correctTrialCount(iNeuron);
            zCounts = (counts - zMean)/zStd;
            plot(centers,smooth(zCounts,smoothZ));
        end
        if iEvent == 1
            legend({'All','Burst','LTS','Poisson'},'Position',[0 .25 .1 .1]);
        end
        ylabel('Z');
        xlabel('t');
        xlim([-1 1]);
        ylim([-10 10]);
%         title({analysisConf.neurons{iNeuron},eventFieldnames{iEvent}});
        
        iSubplot = iSubplot + 1;
    end
    saveas(fig,fullfile('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp',...
        ['lfpBurstZEventAnalysis_',neuronName,'.pdf']));
    close(fig);
end