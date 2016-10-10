totalRows = 6; % LFP, tsAll, tsBurst, tsLTS, tsPoisson, raster
fontSize = 6; 
histBins = 40;
t = linspace(-tWindow,tWindow,size(allScalograms,3));
iSubplot = 1;
neuronName = analysisConf.neurons{iNeuron};
h = figure;

allCaxis = [];
adjSubplots = [];
for iEvent=plotEventIds
    subplot(totalRows,length(plotEventIds),iSubplot);
    imagesc(t,freqList,log(squeeze(allScalograms(iEvent,:,:))));
    if iEvent == 1
        ylabel('Freq (Hz)');
    end
    set(gca,'YDir','normal');
    xlim([-1 1]);
    if iSubplot == 1
        title({neuronName,eventFieldnames{iEvent}},'interpreter','none');
    else
        title({'',eventFieldnames{iEvent}});
    end
    set(gca,'YScale','log');
    set(gca,'Ytick',round(logFreqList(fpass,5)));
    colormap(jet);
    allCaxis(iEvent,:) = caxis;
    adjSubplots = [adjSubplots iSubplot];
    iSubplot = iSubplot + 1;
end
% set all caxis to 25% full range
caxisValues = upperLowerPrctile(allCaxis(plotEventIds,:),25);
for ii=1:length(adjSubplots)
    subplot(totalRows,length(plotEventIds),adjSubplots(ii));
    caxis(caxisValues);
end
adjSubplots = [];

for iEvent=plotEventIds
    subplot(totalRows,length(plotEventIds),iSubplot);
    rasterData = tsPeths(:,iEvent);
    rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
    rasterData = makeRasterReadable(rasterData,50); % limit to 100 data points
    plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
    if iEvent == 1
        title('tsAll');
        ylabel('Trials');
    end
    xlim([-1 1]);
    iSubplot = iSubplot + 1;
end

% all histograms
allPeths = {tsPeths,tsISIPeths,tsLTSPeths,tsPoissonPeths};
rowLabels = {'tsAll','tsISI','tsLTS','tsPoisson'};
for iRowData = 1:length(allPeths)
    allRates = [];
    for iEvent=plotEventIds
        subplot(totalRows,length(plotEventIds),iSubplot);
        curData = allPeths{1,iRowData}(:,iEvent); % extract all trials for iEvent column
        curData = cat(2,curData{:}); % concatenate all values into one vector
        if ~isempty(curData)
            [counts,centers] = hist(curData,histBins);
            ratePerSecond = (counts*histBins)/(length(trialIds)*tWindow*2);
            bar(centers,ratePerSecond,'k','EdgeColor','k');
            if iEvent == 1
                title(rowLabels(iRowData));
                ylabel('spike/sec');
            end
            xlim([-1 1]);
            allRates = [allRates ratePerSecond];
        end
        adjSubplots = [adjSubplots iSubplot];
        iSubplot = iSubplot + 1;
    end
    for ii=1:length(adjSubplots)
        subplot(totalRows,length(plotEventIds),adjSubplots(ii));
        ylim([min(allRates) max(allRates)]);
        if iRowData == length(allPeths)
            xlabel('Time (s)');
        end
    end
    adjSubplots = [];
end

set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','normalized');
set(h,'PaperPosition', [0 0 1 1]);

subFolder = 'eventTriggeredAnalysis';
mkdir(sessionConf.leventhalPaths.analysis,subFolder);
% print(h, '-dpdf', 'test3.pdf');
docName = [subFolder,'_',neuronName,'.pdf'];
saveas(h,fullfile(leventhalPaths.analysis,subFolder,docName));
close(h);