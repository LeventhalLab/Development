% according to the trialsStruct code, movementDirection = 2 => moved right

h = figure('position',[100 100 1200 700]);
colorOrder = get(gca,'ColorOrder');
totalRows = 2;
plusCols = 1;
iSubplot = 1;
fontSize = 10;
ipsiContraIdx = find(allTimes == 2,1,'first');

all_RT = [];
all_MT = [];
for iTrial = 1:numel(trials_correct)
    all_RT(iTrial) = trials_correct(iTrial).timing.RT;
    all_MT(iTrial) = trials_correct(iTrial).timing.MT;
end

for iEvent=plotEventIds
    ax = subplot(totalRows,length(plotEventIds)+plusCols,iSubplot);
    rasterData = [];
    if ~isempty(tsPeths)
        rasterData = tsPeths(:,iEvent);
%         rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        rasterData = makeRasterReadable(rasterData,100); % limit to 100 data points
        plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
    end
    if iEvent == 1
        ylabel({'trials'});
    end
%     title(['by ',timingField]);
    xlim([-tWindow tWindow]);
    ylim([1 numel(trials_correct)]);
    set(ax,'FontSize',fontSize);
    hold on;
    plot([0 0],[0 size(rasterData,1)],'r'); % center line
    ipsiContraLine = plot([-tWindow tWindow],[ipsiContraIdx ipsiContraIdx],'k--','lineWidth',1);
    legend(ipsiContraLine,'contra/ipsi','location','northoutside');
    title(eventFieldnames(iEvent));
    iSubplot = iSubplot + 1;
    ytickVals = yticks;
end

ax = subplot(totalRows,length(plotEventIds)+1,iSubplot);
plot(all_RT,[1:numel(trials_correct)],'b.','markerSize',10);
hold on;
plot(all_MT,[1:numel(trials_correct)],'r.','markerSize',10);
plot([-tWindow tWindow],[ipsiContraIdx ipsiContraIdx],'k--','lineWidth',1);
xlim([0 .5]);
yticks(ytickVals);
ylim([1 numel(trials_correct)]);
title('timing');
legend('rt','mt','location','northoutside','orientation','horizontal');
set(gca,'ydir','reverse');
iSubplot = iSubplot + 1;

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
            legendEntries = [legendEntries {'z-contra'}];
        end
    else
        if isempty(ipsiContraIdx)
            continue;
        else
            zCounts_x = zCounts(:,ipsiContraIdx:end,:);
            legendEntries = [legendEntries {'z-ipsi'}];
            iSubplot = start_iSubplot;
        end
    end
    for iEvent=plotEventIds
        ax = subplot(totalRows,length(plotEventIds)+plusCols,iSubplot);
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
        title(eventFieldnames(iEvent));
        legend(curLines(curLines~=0),legendEntries,'location','northoutside');
        grid on;
    end
end

savePath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp';
saveas(h,fullfile(savePath,['ipsicontr_',neuronName,'.jpg']));
close(h);