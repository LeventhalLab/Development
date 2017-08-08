trialTypes = {'correctContra','correctIpsi'};
zscore = unitZScore(trials,ts,tWindow,eventFieldnames,trialTypes);
t = linspace(-tWindow,tWindow,size(zscore,2));

rows = 2; % LFP, tsAll, tsBurst, tsLTS, tsPoisson, raster, high pass data
cols = numel(eventFieldnames);
fontSize = 7;
iSubplot = 1;
caxisScaleIdx = 4; % centerOut
h = figuree(1200,300);

yvals = [];
adjSubplots = [];
for iEvent = 1:numel(eventFieldnames)
    ax = subplot(rows,cols,iSubplot);
    scaloData = log(squeeze(eventScalograms(iEvent,:,:)));
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

    set(ax,'TickDir','out');
    set(ax,'FontSize',fontSize);
    colormap(jet);
%     set(ax,'XTickLabel',[]);
    if iEvent == caxisScaleIdx
        yvals = caxis;
    end
    nTicks = 5;
    ytickVals = round(linspace(freqList(1),freqList(end),nTicks));
    ytickLabelVals = round(logFreqList(fpass,nTicks));
    yticks(ytickVals);
    yticklabels(ytickLabelVals);

    adjSubplots = [adjSubplots iSubplot];
    iSubplot = iSubplot + 1;
end
% set caxis
for ii = 1:length(adjSubplots)
    ax = subplot(rows,numel(eventFieldnames),adjSubplots(ii));
    caxis(yvals);
% %     if ii == length(adjSubplots)
% %         subplotPos = get(gca,'Position');
% % %         colorbar('eastoutside'); % need to fix formatting before using
% %         set(ax,'Position',subplotPos);
% %     end
    set(ax,'FontSize',fontSize);
end


for iEvent = 1:numel(eventFieldnames)
    ax = subplot(rows,cols,iSubplot);
    plot(t,zscore(iEvent,:),'LineWidth',1,'color','k');
    ylim([-3 8]);
    xlim([-1 1]);
    grid on;
    iSubplot = iSubplot + 1;
end