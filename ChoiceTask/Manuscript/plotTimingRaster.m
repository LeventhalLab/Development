function iSubplot = plotTimingRaster(analysisConf,all_trials,all_ts,tWindow,eventFieldnames,iNeuron,iSubplot,rows,cols,subplotMargins)

neuronName = analysisConf.neurons{iNeuron};
curTrials = all_trials{iNeuron};
%     trialIdInfo = organizeTrialsById(curTrials);
analysisTitles = {'by Trial','by pretone','by RT','by MT'};
timingFields = {'RT','pretone','RT','MT'};

for iRow = 1:4
    timingField = timingFields{iRow};
    [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
    if iRow == 1 % reorganize into trial-order but still have access to RT
        [v,k] = sort(useTrials);
        useTrials = useTrials(k);
        allTimes = allTimes(k);
    end

% %         if use_dirSel
    trialIdInfo = organizeTrialsById(curTrials);

    t_useTrials = [];
    t_allTimes = [];
    trialCount = 0;
    groups = []; % for raster colors
    for iTrial = 1:numel(useTrials)
        if ismember(useTrials(iTrial),trialIdInfo.correctContra)
            trialCount = trialCount + 1;
            t_useTrials(trialCount) = useTrials(iTrial);
            t_allTimes(trialCount) = allTimes(iTrial);
            groups(trialCount) = 1;
        end
    end
    markContraTrials = trialCount;
    for iTrial = 1:numel(useTrials)
        if ismember(useTrials(iTrial),trialIdInfo.correctIpsi)
            trialCount = trialCount + 1;
            t_useTrials(trialCount) = useTrials(iTrial);
            t_allTimes(trialCount) = allTimes(iTrial);
            groups(trialCount) = 2;
        end
    end
    useTrials = t_useTrials;
    allTimes = t_allTimes;
% %         end

    tsPeths = {};

    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
    if isempty(tsPeths)
        continue;
    end

    for iEvent = 1:numel(eventFieldnames)
        ax = subplot_tight(rows,cols,iSubplot,subplotMargins);
        rasterData = tsPeths(:,iEvent);
%         rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        rasterData = makeRasterReadable(rasterData,75);
        th = figure;
        [xPoints,yPoints] = plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        close(th);
        plotSpikeRaster_color(xPoints,yPoints,groups,lines(2),[],4);
        plot([0 0],[0 size(rasterData,1)],'k-'); % center line
% %         ln = plot([-1 1],[markContraTrials markContraTrials],'r--');

        xlim([-1 1]);

        if iEvent == iRow
            titleColor = 'r';
        else
            titleColor = 'k';
        end

         if iEvent == 1
            ylabel({'tsAll','Trials'});
        else
            set(ax,'yTickLabel',[]);
        end
        if iEvent == 1 && iRow == 1
            title({neuronName,eventFieldnames{iEvent}},'HorizontalAlignment','center','color',titleColor,'interpreter','none');
        else
             title({'',eventFieldnames{iEvent}},'HorizontalAlignment','center','color',titleColor,'interpreter','none');
        end
        iSubplot = iSubplot + 1;
    end
    ax = subplot_tight(rows,cols,iSubplot,subplotMargins);
    barh(allTimes,'k','EdgeColor','none');
    set(ax,'ydir','reverse');
    set(ax,'yTickLabel',[]);
    ylim(size(allTimes));
    title(analysisTitles{iRow});
    xlim([0 1]);
    iSubplot = iSubplot + 1;
end