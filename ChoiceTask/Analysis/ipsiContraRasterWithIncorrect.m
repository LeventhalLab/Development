saveDir = '/Users/mattgaidica/Documents/Data/ChoiceTask/all_ipsiContraRasters';
for iNeuron = 1:numel(all_trials)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);
    trialIds = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
    tsPeths = eventsPeth(curTrials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
    h = figuree(1400,400);
    for iEvent = 1:numel(eventFieldnames)
        ax = subplot(1,numel(eventFieldnames),iEvent);
        rasterData = tsPeths(:,iEvent);
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
        plot([-tWindow tWindow],[n_correctContra n_correctContra],'r--');
        plot([-tWindow tWindow],[n_correctIpsi n_correctIpsi],'r--');
        plot([-tWindow tWindow],[n_incorrectContra n_incorrectContra],'r--');
        plot([-tWindow tWindow],[n_incorrectIpsi n_incorrectIpsi],'r--');
        ytickVals = [n_correctContra,n_correctIpsi,n_incorrectContra,n_incorrectIpsi];
        ytickReplaceIdx = find(diff(ytickVals) == 0);
        while ~isempty(ytickReplaceIdx)
            ytickVals(ytickReplaceIdx(end)+1) = ytickVals(ytickReplaceIdx(end)+1) + 1;
            ytickReplaceIdx = find(diff(ytickVals) == 0);
        end
        yticks(ytickVals);
        yticklabels({'Contra-move Contra-tone','Ipsi-move Ipsi-tone','Contra-move Ipsi-tone','Ipsi-move Contra-tone'});
        ytickangle(60);
        xlabel('time (s)');
        set(gca,'fontSize',6);
        if iEvent == 1
            title(['unit',num2str(iNeuron),' - ',neuronName],'interpreter','none');
        else
            title(eventFieldnames{iEvent});
        end
    end
    saveas(h,fullfile(saveDir,['ipsiContraRaster_',neuronName,'.jpg']));
    close(h);
end