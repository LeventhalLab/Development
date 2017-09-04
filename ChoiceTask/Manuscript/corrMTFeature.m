if true
    tWindow = 1;
    binMs = 50;
    nBins = round((2*tWindow / .001) / binMs);
    nBinHalfWidth = ((tWindow*2) / nBins) / 2;
    binEdges = linspace(-tWindow+nBinHalfWidth,tWindow-nBinHalfWidth,nBins+1);
    
    neuronCount = 1;
    y = [];
    yR2 = [];
    yc = 1;
    groups = {};
    all_earlyRatio = [];
    all_useTimes = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        if ~dirSelNeurons(iNeuron) % only use
            continue;
        end
        neuronName = analysisConf.neurons{iNeuron}
        curTrials = all_trials{iNeuron};
        trialIdInfo = organizeTrialsById(curTrials);
        
        timingField = 'MT';
        [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
        tsPeths = {};
    
    
        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
        if isempty(tsPeths)
            continue;
        end

        earlySpikes = [];
        lateSpikes = [];
        allSpikes = [];
        earlyRatio = [];
        useTimes = [];
        corrCount = 1;
        for iTrial = 1:numel(useTrials)
            ts_eventX = tsPeths{iTrial,4}; % centerOut
            counts = histcounts(ts_eventX,binEdges);
            
%             if mean(counts) < 2
%                 continue;
%             end

            curMT = allTimes(iTrial);
            MTbins = round(numel(counts)/2) - 3: min(ceil(curMT*1000 / binMs),numel(counts)) + round(numel(counts)/2); % either duration of MT or tWindow
            MTbins_early = MTbins(1:floor(numel(MTbins)/2));
            MTbins_late = MTbins(end-numel(MTbins_early)+1:end);
            
            allSpikes(corrCount) = sum(counts(MTbins));
            earlySpikes(corrCount) = sum(counts(MTbins_early));
            lateSpikes(corrCount) = sum(counts(MTbins_late));
            earlyRatio(corrCount) = earlySpikes(corrCount) / allSpikes(corrCount);
            useTimes(corrCount) = allTimes(iTrial);
            corrCount = corrCount + 1;
        end
        
%         if numel(useTimes) < 4
%             continue;
%         end
        
        all_earlyRatio = [all_earlyRatio earlyRatio];
        all_useTimes = [all_useTimes useTimes];

        [~,gof] = fit(useTimes',earlySpikes','poly1');
        y(yc) = corr(useTimes',earlySpikes');
        yR2(yc) = gof.rsquare;
        groups{yc} = 'early';
        yc = yc + 1;
        
        [~,gof] = fit(useTimes',lateSpikes','poly1');
        y(yc) = corr(useTimes',lateSpikes');
        yR2(yc) = gof.rsquare;
        groups{yc} = 'late';
        yc = yc + 1;
        
%         figure;
%         scatter(allTimes,earlySpikes)
%         hold on
%         scatter(allTimes,lateSpikes)
        
        neuronCount = neuronCount + 1;
    end
end
figure;scatter(all_useTimes,all_earlyRatio);
anova1(y,groups)
% anova1(yR2,groups)