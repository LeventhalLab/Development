figure('position',[0 0 1100 500]);
fontSize = 14;
fontname = 'Arial';
iSubplot = 1;
adjSubplots = [];
totalRows = 2;
histBins = 40;
for iEvent = 1:numel(eventFieldnames)
    ax = subplot(totalRows,numel(eventFieldnames),iSubplot);
    rasterData = tsPeths(:,iEvent);
    rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
    rasterData = makeRasterReadable(rasterData,100); % limit to 100 data points
    plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
    if iEvent == 1
        ylabel('trials');
    else
        set(ax,'yTickLabel',[]);
    end
    title(eventFieldnames{iEvent});
    xlim([-1 1]);
    set(ax,'FontSize',fontSize);
    set(ax,'FontName',fontname);
    hold on;
    plot([0 0],[0 size(rasterData,1)],':','color','red','LineWidth',2); % center line
%     set(ax,'XTickLabel',[]);
    iSubplot = iSubplot + 1;
end

% all histograms
allPeths = {tsPeths};
rowLabels = {'tsAll'};
for iRowData = 1:length(allPeths)
    allys = [];
    for iEvent = 1:numel(eventFieldnames)
        ax = subplot(totalRows,numel(eventFieldnames),iSubplot);
        curData = allPeths{1,iRowData}(:,iEvent); % extract all trials for iEvent column
        curData = cat(2,curData{:}); % concatenate all values into one vector
        if ~isempty(curData)
            [counts,centers] = hist(curData,histBins);
            ratePerSecond = (counts*histBins)/(length(trialIds)*tWindow*2);
            bar(centers,ratePerSecond,'k','EdgeColor','k');
            if iEvent == 1
                ylabel('spike/sec');
            end
            xlim([-1 1]);
            allys = [allys ratePerSecond];
        end
        xlabel('Time (s)');
        set(ax,'FontSize',fontSize);
        set(ax,'FontName',fontname);
        adjSubplots = [adjSubplots iSubplot];
        iSubplot = iSubplot + 1;
    end
    for ii=1:length(adjSubplots)
        ax = subplot(totalRows,numel(eventFieldnames),adjSubplots(ii));
        if ~isempty(allys)
            ylim([0 max(allys)]); % make FR start at 0
        end
        if iRowData ~= length(allPeths) % redundant?
            set(ax,'XTickLabel',[]);
        end
        hold on; plot([0 0],[0 max(allys)],':','color','red','LineWidth',2); % center line
    end
    adjSubplots = [];
end

set(gcf,'color','w');