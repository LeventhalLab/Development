if false
    tWindow = 1;
    nBins = round((2*tWindow / .001) / binMs);
    nBinHalfWidth = ((tWindow*2) / nBins) / 2;
    binEdges = linspace(-tWindow+nBinHalfWidth,tWindow-nBinHalfWidth,nBins+1);
    neuronRTCorr = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron};
        disp(['classifyUnitsToEvents: ',neuronName]);
        curTrials = all_trials{iNeuron};
        trialIdInfo = organizeTrialsById(curTrials);
    %     useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi];
        timingField = 'RT';
        [useTrials,allTimes] = sortTrialsBy(trials,timingField);

        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
        if isempty(tsPeths)
            continue;
        end


        tmp = figure;
        eventRTCorr = [];
        for iEvent = 1:numel(eventFieldnames)
            trial_hCounts = [];
            for iTrial = 1:numel(useTrials)
                ts_eventX = tsPeths{iTrial,iEvent};
                h = histogram(ts_eventX,binEdges);
                trial_hCounts(iTrial,:) = h.Values;
            end
            binRTCorr = [];
            for iBin = 1:size(trial_hCounts,2)
                R = corr([trial_hCounts(:,iBin)';allTimes]');
                binRTCorr(iBin) = R(2);
            end
            eventRTCorr(iEvent,:) = binRTCorr;
        end
        close(tmp);
        neuronRTCorr(iNeuron,:,:) = eventRTCorr;
        hold on;
    end
end

figuree(1300,400);
colors = lines(2);
for iEvent = 1:7
    subplot(1,7,iEvent);
    plot(mean(squeeze(neuronRTCorr(dirSelNeurons,iEvent,:))),'color',colors(1,:),'lineWidth',2);
    hold on;
    plot(mean(squeeze(neuronRTCorr(~dirSelNeurons,iEvent,:))),'color',colors(2,:),'lineWidth',2);
    ylim([-1 1]);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
end