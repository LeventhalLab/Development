close all

figure('position',[100 100 1200 700]);
colorOrder = get(gca,'ColorOrder');
totalRows = 2;
iSubplot = 1;
fontSize = 10;
ipsiContraIdx = find(allTimes == 2,1,'first');

for iEvent=plotEventIds
    ax = subplot(totalRows,length(plotEventIds)+1,iSubplot);
    rasterData = [];
    if ~isempty(tsPeths)
        rasterData = tsPeths(:,iEvent);
%         rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        rasterData = makeRasterReadable(rasterData,100); % limit to 100 data points
        plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
    end
    if iEvent == 1
        ylabel({'tsAll','Trials'});
    else
        set(ax,'yTickLabel',[]);
    end
%     title(['by ',timingField]);
    xlim([-tWindow tWindow]);
    set(ax,'FontSize',fontSize);
    hold on;
    plot([0 0],[0 size(rasterData,1)],'r'); % center line
    ipsiContraLine = plot([-tWindow tWindow],[ipsiContraIdx ipsiContraIdx],'k--','lineWidth',1);
    legend(ipsiContraLine,'ipsi/contra','location','northoutside');
%     set(ax,'XTickLabel',[]);
    iSubplot = iSubplot + 1;
end

ax = subplot(totalRows,length(plotEventIds)+1,iSubplot);


start_iSubplot = iSubplot;
nSmooth = 1;
ylimVals = [-2 2];
legendEntries = [];
zlines = [];
for iZPeths = 1:2
    if iZPeths == 1
        if ~isempty(ipsiContraIdx) && ipsiContraIdx == 1
            continue;
        else
            zCounts_x = zCounts(:,1:ipsiContraIdx-1,:);
            legendEntries = [legendEntries {'z-ipsi'}];
        end
    else
        if isempty(ipsiContraIdx)
            continue;
        else
            zCounts_x = zCounts(:,ipsiContraIdx:end,:);
            legendEntries = [legendEntries {'z-contra'}];
            iSubplot = start_iSubplot;
        end
    end
    for iEvent=plotEventIds
        ax = subplot(totalRows,length(plotEventIds),iSubplot);
        if ~isempty(zCounts_x)
            x = linspace(-tWindow,tWindow,size(zCounts_x,3));
            y = squeeze(sum(zCounts_x(iEvent,:,:),2)) / size(zCounts_x,2);
            zlines(iEvent,iZPeths) = plot(x,y,'lineWidth',2,'color',colorOrder(iZPeths,:));
            hold on;
            plot([0 0],ylimVals,'r'); % center line
            iSubplot = iSubplot + 1;
        end
%         title('zHist');
        ylim(ylimVals);
        curLines = zlines(iEvent,:);
        legend(curLines(curLines~=0),legendEntries,'location','northoutside');
        grid on;
    end
end