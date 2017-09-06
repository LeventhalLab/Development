use_dirSel = true;

for iNeuron = 1:numel(analysisConf.neurons)
%     if ~dirSelNeurons(iNeuron) % only use
%         continue;
%     end
    if isempty(unitEvents{iNeuron}.class) || unitEvents{iNeuron}.class(1) ~= 4
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
        
        if use_dirSel
            trialIdInfo = organizeTrialsById(curTrials);
            
            t_useTrials = [];
            t_allTimes = [];
            trialCount = 1;
            for iTrial = 1:numel(useTrials)
                if ismember(useTrials(iTrial),trialIdInfo.correctContra)
                    t_useTrials(trialCount) = useTrials(iTrial);
                    t_allTimes(trialCount) = allTimes(iTrial);
                    trialCount = trialCount + 1;
                end
            end
            markContraTrials = trialCount - 1;
            for iTrial = 1:numel(useTrials)
                if ismember(useTrials(iTrial),trialIdInfo.correctIpsi)
                    t_useTrials(trialCount) = useTrials(iTrial);
                    t_allTimes(trialCount) = allTimes(iTrial);
                    trialCount = trialCount + 1;
                end
            end
            useTrials = t_useTrials;
            allTimes = t_allTimes;
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
%             rasterData = makeRasterReadable(rasterData,75); % limit to 100 data points
            plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false); hold on;
            plot([0 0],[0 size(rasterData,1)],':','color','red'); % center line
            ln = plot([-1 1],[markContraTrials markContraTrials],'g--');
            
            xlim([-.05 .05]);
            set(ax,'FontSize',fontSize);
            
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
                legend(ln,'contra/ipsi');
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
    saveas(h1,fullfile('/Users/mattgaidica/Documents/Data/ChoiceTask/plotSpikeRastersSORTED',[neuronName,'_centerOut50ms.jpg']));
    close(h1);
end