for iNeuron = 1:numel(analysisConf.neurons)
    if ~dirSelNeurons(iNeuron) % only use
        continue;
    end

    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
%     trialIdInfo = organizeTrialsById(curTrials);
    timingFields = {'RT','pretone','RT','MT'};
    h1 = figuree(1200,600);
    for iRow = 1:4
        timingField = timingFields{iRow};
        [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
        if iRow == 1 % reorganize into trial-order but still have access to RT
            [v,k] = sort(useTrials);
            useTrials = useTrials(k);
            allTimes = allTimes(k);
        end
        tsPeths = {};

        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
        if isempty(tsPeths)
            continue;
        end

        for iEvent = 1:numel(eventFieldnames)
            ax = subplot(4,8,iEvent+(iRow*8-8));
            rasterData = tsPeths(:,iEvent);
            rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
            rasterData = makeRasterReadable(rasterData,75); % limit to 100 data points
            plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
            if iEvent == 1
                ylabel({'tsAll','Trials'});
            else
                set(ax,'yTickLabel',[]);
            end
            xlim([-1 1]);
            set(ax,'FontSize',fontSize);
            hold on;
            plot([0 0],[0 size(rasterData,1)],':','color','red'); % center line
            if iEvent == iRow
                titleColor = 'r';
            else
                titleColor = 'k';
            end
            if iEvent == 1 && iRow == 1
                title({neuronName,eventFieldnames{iEvent}},'HorizontalAlignment','center','color',titleColor,'interpreter','none');
            else
                 title({'',eventFieldnames{iEvent}},'HorizontalAlignment','center','color',titleColor,'interpreter','none');
            end
        %     set(ax,'XTickLabel',[]);
        end
        ax = subplot(4,8,iEvent+(iRow*8-8)+1);
        barh(allTimes,'k','EdgeColor','none');
        set(ax,'ydir','reverse');
        set(ax,'yTickLabel',[]);
        ylim(size(allTimes));
        title(timingFields{iRow});
        xlim([0 1]);
    end
    saveas(h1,fullfile('/Users/mattgaidica/Documents/Data/ChoiceTask/plotSpikeRastersSORTED',[neuronName,'.jpg']));
    close(h1);
end