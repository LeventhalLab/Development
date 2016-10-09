[burstEventData,lfpEventData,t,freqList,eventFieldnames,correctTrialCount,scalogramWindow] = ...
    eventTriggeredAnalysis(analysisConf);

plotEventIdx = [1 2 4 3 5 6 8];
totalRows = 6; % LFP, tsAll, tsBurst, tsLTS, tsPoisson, raster
fontSize = 6; 
histBins = 40;
smoothZ = 5;

for iNeuron=1:size(analysisConf.neurons,1)
    sessionConf = exportSessionConf(analysisConf.sessionNames{iNeuron},analysisConf.nasPath);
    
    iSubplot = 1;
    neuronName = analysisConf.neurons{iNeuron};
    h = figure;
    eventData = lfpEventData{iNeuron};
    
    allCaxis = [];
    adjSubplots = [];
    for iEvent=plotEventIdx
        subplot(totalRows,length(plotEventIdx),iSubplot);
        imagesc(t,freqList,log(squeeze(eventData(iEvent,:,:))));
        if iEvent == 1
            ylabel('Freq (Hz)');
        end
        set(gca, 'YDir', 'normal');
        xlim([-1 1]);
        if iSubplot == 1
            title({neuronName,eventFieldnames{iEvent}},'interpreter',none);
        else
            title({'',eventFieldnames{iEvent}});
        end
        set(gca,'YScale','log');
        set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
        colormap(jet);
        allCaxis(iEvent,:) = caxis;
        adjSubplots = [adjSubplots iSubplot];
        iSubplot = iSubplot + 1;
    end
    % set all caxis to 25% full range
    caxisValues = upperLowerPrctile(allCaxis(:),25);
    for ii=1:length(adjSubplots)
        subplot(totalRows,length(plotEventIdx),adjSubplots(ii));
        caxis(caxisValues);
    end
    adjSubplots = [];
    
    eventData = burstEventData{iNeuron};
    
    for iEvent=plotEventIdx
        subplot(totalRows,length(plotEventIdx),iSubplot);
        rasterData = eventData.tsEvents(:,iEvent);
        rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        rasterData = makeRasterReadable(rasterData,50); % limit to 100 data points
        plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        if iEvent == 1
            ylabel('Trials');
        end
        xlim([-1 1]);
        iSubplot = iSubplot + 1;
    end
    
    % all histograms
    rowData = {eventData.tsEvents,eventData.tsBurstEvents,eventData.tsLTSEvents,eventData.tsPoissonEvents};
    rowLabels = {'tsAll','tsBursts','tsLTS','tsPoisson'};
    for iRowData = 1:length(rowData)
        allRates = [];
        for iEvent=plotEventIdx
            subplot(totalRows,length(plotEventIdx),iSubplot);
            curData = rowData{1,iRowData}(:,iEvent); % extract all trials for iEvent column
            curData = cat(2,curData{:}); % concatenate all values into one vector
            if ~isempty(curData)
                [counts,centers] = hist(curData,histBins);
                ratePerSecond = counts*(scalogramWindow*2)/histBins;
                bar(centers,ratePerSecond,'k','EdgeColor','k');
                title(rowLabels(iRowData));
                if iEvent == 1
                    ylabel('per second');
                end
                xlim([-1 1]);
                allRates = [allRates ratePerSecond];
            end
            adjSubplots = [adjSubplots iSubplot];
            iSubplot = iSubplot + 1;
        end
        for ii=1:length(adjSubplots)
            subplot(totalRows,length(plotEventIdx),adjSubplots(ii));
            ylim([min(allRates) max(allRates)]);
        end
        adjSubplots = [];
        
        if iRowData == length(rowData)
            xlabel('Time (s)');
        end
    end
    
    set(h,'PaperOrientation','landscape');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 1 1]);
    print(gcf, '-dpdf', 'test3.pdf');
    
    subFolder = 'eventTriggeredAnalysis';
    leventhalPaths = buildLeventhalPaths(sessionConf,{'analysis'});
    if ~exist(fullfile(leventhalPaths.analysis,subFolder),'dir')
        mkdir(fullfile(leventhalPaths.analysis,subFolder));
    end
    saveas(fig,fullfile(leventhalPaths.analysis,subFolder,...
        [subFolder,'_',neuronName,'.pdf']));
    close(h);
end