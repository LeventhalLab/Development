close all

figure('position',[100 100 1200 900]);
colorOrder = get(gca, 'ColorOrder');
totalRows = 4;
iSubplot = 1;
fontSize = 10;

for iRasters = 1:2
    if iRasters == 1
        tsPeths_x = tsPeths_ipsi;
    else
        tsPeths_x = tsPeths_contra;
    end
    for iEvent=plotEventIds
        ax = subplot(totalRows,length(plotEventIds),iSubplot);
        rasterData = [];
        if ~isempty(tsPeths_x)
            rasterData = tsPeths_x(:,iEvent);
            rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
            rasterData = makeRasterReadable(rasterData,100); % limit to 100 data points
            plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        end
        if iEvent == 1
            ylabel({'tsAll','Trials'});
        else
            set(ax,'yTickLabel',[]);
        end
        title(['by ',timingField]);
        xlim([-1 1]);
        set(ax,'FontSize',fontSize);
        hold on;
        plot([0 0],[0 size(rasterData,1)],'r'); % center line
    %     set(ax,'XTickLabel',[]);
        iSubplot = iSubplot + 1;
    end
end

start_iSubplot = iSubplot;
nSmooth = 1;
ylimVals = [-2 2];
for iZPeths = 1:2
    if iZPeths == 1
        zCounts_x = zCounts_ipsi;
    else
        zCounts_x = zCounts_contra;
        iSubplot = start_iSubplot;
    end
    for iEvent=plotEventIds
        ax = subplot(totalRows,length(plotEventIds),iSubplot);
        if ~isempty(zCounts_x)
            x = linspace(-tWindow,tWindow,size(zCounts_x,3));
%             hs(iZPeths) = shadedErrorBar(x,smooth(mean(squeeze(zCounts_ipsi(iEvent,:,:))),nSmooth),...
%                 smooth(std(squeeze(zCounts_ipsi(iEvent,:,:))),nSmooth),{},1);
            zlines(iZPeths) = plot(x,mean(squeeze(zCounts_x(iEvent,:,:))),'lineWidth',2,'color',colorOrder(iZPeths,:));
            hold on;
            plot([0 0],ylimVals,'r'); % center line
            iSubplot = iSubplot + 1;
        end
        title('zHist');
        ylim(ylimVals);
%         legend(zlines,'Ipsi','Contra');
        grid on;
    end
end