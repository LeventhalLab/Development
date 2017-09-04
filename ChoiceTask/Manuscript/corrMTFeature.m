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
    all_useTimes = [];
    all_earlySpikes_z = [];
    all_allSpikes_z = [];

    for iNeuron = 1:numel(analysisConf.neurons)
        if ~dirSelNeurons(iNeuron) % only use
            continue;
        end
        neuronName = analysisConf.neurons{iNeuron}
        curTrials = all_trials{iNeuron};
        trialIdInfo = organizeTrialsById(curTrials);
        
        timingField = 'RT';
        [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
        tsPeths = {};
    
    
        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
        if isempty(tsPeths)
            continue;
        end

        earlySpikes = [];
        allSpikes = [];
        useTimes = [];
        corrCount = 1;
        for iTrial = 1:numel(useTrials)
            ts_eventX = tsPeths{iTrial,4}; % centerOut
            counts = histcounts(ts_eventX,binEdges);
            
%             if mean(counts) < 2
%                 continue;
%             end

            curMT = allTimes(iTrial);
            MTbins = round(20:min(ceil(curMT*1000 / binMs),numel(counts)) + round(numel(counts)/2)); % either duration of MT or tWindow
           
            earlySpikes(corrCount) = sum(counts);
            allSpikes(corrCount) = sum(counts(15:25));
            useTimes(corrCount) = allTimes(iTrial);
            corrCount = corrCount + 1;
        end
        
%         if numel(useTimes) < 4
%             continue;
%         end

        all_useTimes = [all_useTimes useTimes];
        earlySpikes_z = (earlySpikes - mean(earlySpikes)) / std(earlySpikes); % for all trials
        allSpikes_z = (allSpikes - mean(allSpikes)) / std(allSpikes); % for all trials
        all_earlySpikes_z = [all_earlySpikes_z earlySpikes_z];
        all_allSpikes_z = [all_allSpikes_z allSpikes_z];


%         [~,gof] = fit(useTimes',sumSpikesZ','poly1');
%         y(yc) = corr(useTimes',);
%         yR2(yc) = gof.rsquare;
%         groups{yc} = '';
%         yc = yc + 1;
        
        neuronCount = neuronCount + 1;
    end
end

[v,k] = sort(all_useTimes);
figure;
plot(all_useTimes(k),all_earlySpikes_z(k),'color',[1 0 0 0.05]);
hold on;
plot(all_useTimes(k),smooth(all_earlySpikes_z(k),100),'color',[1 0 0]);
plot(all_useTimes(k),all_allSpikes_z(k),'color',[0 0 1 0.05]);
plot(all_useTimes(k),smooth(all_allSpikes_z(k),100),'color',[0 0 1]);
grid on;

% anova1(y,groups)
% anova1(yR2,groups)