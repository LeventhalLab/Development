rows = 8; % LFP, tsAll, tsBurst, tsLTS, tsPoisson, raster, high pass data
cols = numel(eventFieldnames);
fontSize = 7;
histBins = 40;
iSubplot = 1;
caxisScaleIdx = 3; % centerOut
h = figure;

yvals = [];
adjSubplots = [];
for iEvent = 1:numel(eventFieldnames)
    ax = subplot(rows,cols,iSubplot);
    scaloData = squeeze(eventScalograms(iEvent,:,:));
% %     tIdxs = find(t >= -1 & t <= 1);
% %     tIdxs = [min(tIdxs)-1 tIdxs max(tIdxs)+1];
    imagesc(t,freqList,scaloData);
    if iEvent == 1
        ylabel('Freq (Hz)');
    else
        set(ax,'yTickLabel',[]);
    end
    set(ax,'YDir','normal');
    xlim([-1 1]);
    if iSubplot == 1
        title({neuronName,eventFieldnames{iEvent}},'interpreter','none');
    else
        title({'',eventFieldnames{iEvent}});
    end
%     set(ax,'YScale','log');
%     set(ax,'Ytick',round(logFreqList(fpass,5)));

    set(ax,'TickDir','out');
    set(ax,'FontSize',fontSize);
    colormap(jet);
%     set(ax,'XTickLabel',[]);
% %     if iEvent == caxisScaleIdx
% %         yvals = caxis;
        % use a middling window, 50% of +/-1s
        scaloMidRange = [round(size(scaloData,1) / 2) - round(size(scaloData,1) / 4):round(size(scaloData,1) / 2) + round(size(scaloData,1) / 4)];
        yvals(iEvent,:) = [mean(min(scaloData(scaloMidRange,:))) mean(max(scaloData(scaloMidRange,:)))];
% %     end
    adjSubplots = [adjSubplots iSubplot];
    iSubplot = iSubplot + 1;
end
% set caxis
for ii=1:length(adjSubplots)
    ax = subplot(rows,numel(eventFieldnames),adjSubplots(ii));
    caxis([min(min(yvals)) max(max(yvals))]);
    if ii == length(adjSubplots)
        subplotPos = get(gca,'Position');
%         colorbar('eastoutside'); % need to fix formatting before using
        set(ax,'Position',subplotPos);
    end
    set(ax,'FontSize',fontSize);
end

% high pass filter butterfly overlay trace
adjSubplots = [];
for iEvent = 1:numel(eventFieldnames)
    ax = subplot(rows,cols,iSubplot);
    for iTrial = 1:size(allLfpData,3)
        lfpData = squeeze(allLfpData(iEvent,:,iTrial));
        % inline baseline adjustment (weird DC offset in some data)
        patchline(linspace(-tWindow,tWindow,size(allLfpData,2)),lfpData - mean(lfpData),'edgealpha',0.05);
    end
    if iEvent == 1
        ylabel({'High Pass','uV'});
    else
        set(ax,'yTickLabel',[]);
    end
    xlim([-1 1]);
    if iEvent == caxisScaleIdx
        yvals =  max(abs(ylim));
    end
    set(ax,'FontSize',fontSize);
    adjSubplots = [adjSubplots iSubplot];
    iSubplot = iSubplot + 1;
end
% set y-axis
for ii=1:length(adjSubplots)
    ax = subplot(rows,numel(eventFieldnames),adjSubplots(ii));
% %     ylim([-yvals yvals]);
    ylim([-500 500]);
end

% spike rasters
adjSubplots = [];
for iEvent = 1:numel(eventFieldnames)
    ax = subplot(rows,cols,iSubplot);
    rasterData = tsPeths(:,iEvent);
    rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
    rasterData = makeRasterReadable(rasterData,100); % limit to 100 data points
    plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
    if iEvent == 1
        ylabel({'tsAll','Trials'});
    else
        set(ax,'yTickLabel',[]);
    end
%     title(['sorted asc by ',timingField]); % sort by?
    xlim([-1 1]);
    set(ax,'FontSize',fontSize);
    hold on;
    plot([0 0],[0 size(rasterData,1)],':','color','red'); % center line
%     set(ax,'XTickLabel',[]);
    iSubplot = iSubplot + 1;
end

% all histograms
allPeths = {tsPeths,tsISIInvPeths,tsISIPeths,tsLTSPeths,tsPoissonPeths};
rowLabels = {'tsAll','tsAll - tsISI','tsISI','tsLTS','tsPoisson'};
for iRowData = 1:length(allPeths)
    allys = [];
    for iEvent = 1:numel(eventFieldnames)
        ax = subplot(rows,cols,iSubplot);
        curData = allPeths{1,iRowData}(:,iEvent); % extract all trials for iEvent column
        curData = cat(2,curData{:}); % concatenate all values into one vector
        if ~isempty(curData)
            [counts,centers] = hist(curData,histBins);
            ratePerSecond = (counts*histBins)/(length(trialIds)*tWindow*2);
            bar(centers,ratePerSecond,'k','EdgeColor','k');
            if iEvent == 1
                ylabel({rowLabels{iRowData},'spike/sec'});
            end
            xlim([-1 1]);
            allys = [allys ratePerSecond];
        end
        set(ax,'FontSize',fontSize);
        adjSubplots = [adjSubplots iSubplot];
        iSubplot = iSubplot + 1;
    end
    for ii=1:length(adjSubplots)
        ax = subplot(rows,numel(eventFieldnames),adjSubplots(ii));
        if ~isempty(allys)
            ylim([0 max(allys)]); % make FR start at 0
        end
        if iRowData ~= length(allPeths) % redundant?
            set(ax,'XTickLabel',[]);
        end
        hold on; plot([0 0],[0 max(allys)],':','color','red'); % center line
    end
    adjSubplots = [];
end

subFolder = 'eventAnalysis';
docName = [subFolder,'_',neuronName];
savePDF(h,sessionConf.leventhalPaths,subFolder,docName,true);