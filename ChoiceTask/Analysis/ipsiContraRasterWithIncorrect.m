saveDir = '/Users/mattgaidica/Documents/Data/ChoiceTask/spikeRasterWithIncorrect';
useEvents = [1:7];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);
    trialIds = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
    tsPeths = eventsPeth(curTrials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
    h = figuree(150*numel(useEvents)+300,400);
    for iEvent = 1:numel(useEvents)
        ax = subplot(1,numel(useEvents),iEvent);
        rasterData = tsPeths(:,useEvents(iEvent));
%         rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        for iTrial = 1:numel(rasterData)
            if isempty(rasterData{iTrial})
                rasterData{iTrial} = [-tWindow];
            end
        end
        rasterData = makeRasterReadable(rasterData,50); % limit to 100 data points
        plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        hold on;
        
        n_correctContra = 1;
        n_correctIpsi = n_correctContra + numel(trialIdInfo.correctContra);
        n_incorrectContra = n_correctIpsi + numel(trialIdInfo.correctIpsi);
        n_incorrectIpsi = n_incorrectContra + numel(trialIdInfo.incorrectContra);
        plot([-tWindow tWindow],[n_correctContra n_correctContra],'r:');
        plot([-tWindow tWindow],[n_correctIpsi n_correctIpsi],'r:');
        plot([-tWindow tWindow],[n_incorrectContra n_incorrectContra],'r:');
        plot([-tWindow tWindow],[n_incorrectIpsi n_incorrectIpsi],'r:');
        ytickVals = [n_correctContra,n_correctIpsi,n_incorrectContra,n_incorrectIpsi];
        ytickReplaceIdx = find(diff(ytickVals) == 0);
        xlim([-1 1]);
        while ~isempty(ytickReplaceIdx)
            ytickVals(ytickReplaceIdx(end)+1) = ytickVals(ytickReplaceIdx(end)+1) + 1;
            ytickReplaceIdx = find(diff(ytickVals) == 0);
        end
        yticks(ytickVals);
        xlabel('time (s)');
        title(eventFieldnames{useEvents(iEvent)});
        if iEvent == 1
%             title(['unit',num2str(iNeuron),' - ',neuronName],'interpreter','none');
            yticklabels({'Tone Contra, Move Contra','Tone Ipsi, Move Ipsi','Tone Ipsi, Move Contra','Tone Contra, Move Ipsi'});
            ytickangle(0);
        else
            yticklabels({'','','',''});
        end
        set(gca,'fontSize',16);
    end
    set(gcf,'color','w');
    saveas(h,fullfile(saveDir,['ipsiContraRaster_allEvents_',neuronName,'.fig']));
    close(h);
end