useEvents = 4;
snipTs = 0.2; % *2 tail
xsRT = [];
xsMT = [];
ys = [];
doplot = true;
eventNeuronIds = 1:size(all_tsPeths,2);
eventNeuronIds = find(eventIds_by_maxHistValues == useEvents);

for iNeuron = 1:numel(eventNeuronIds)
    neuronTrials = all_trials{1,(iNeuron)};
    correct_trials = neuronTrials([neuronTrials(:).correct] == 1);
    cur_tsPeths = all_tsPeths{1,iNeuron};
    sortArr = [];
    ISIs = [];
    for iTrial = 1:size(cur_tsPeths,1)
        cur_tsPeth = cur_tsPeths{iTrial,useEvents};
%         cur_tsPeth_snippet = cur_tsPeth(cur_tsPeth > -snipTs & cur_tsPeth < snipTs);
%         sortArr(iTrial) = var(diff(cur_tsPeth_snippet));
        ISI = diff(cur_tsPeth);
        ISIs(iTrial) = median(ISI);
    end
    ISIsmean = median(ISIs);
    ISIsstd = std(ISIs);
    
    allRTs = [];
    allMTs = [];
    if doplot
        figure('position',[100 400 1200 400]);
        subplot(131);
        hold on;
    end
    for iTrial = 1:size(cur_tsPeths,1)
        cur_tsPeth = cur_tsPeths{iTrial,useEvents};
        cur_tsPeth_snippet = cur_tsPeth(cur_tsPeth > -snipTs & cur_tsPeth < snipTs*2);
        ISI = diff(cur_tsPeth_snippet);
        lowISI = numel(find(ISI <= (ISIsmean - ISIsstd))) / numel(ISI);
        medISI = numel(find(ISI > (ISIsmean - ISIsstd) & ISI < (ISIsmean + ISIsstd))) / numel(ISI);
        highISI = numel(find(ISI >= (ISIsmean + ISIsstd))) / numel(ISI);
        if doplot
            plot([1,2,3],[(lowISI),(medISI),(highISI)]);
        end
        CV = ((lowISI) + (highISI)) - (medISI);
        sortArr(iTrial) = CV;
        allRTs(iTrial) = correct_trials(iTrial).timing.RT;
        allMTs(iTrial) = correct_trials(iTrial).timing.MT;
        
        if numel(ISI) > 10
            xsRT = [xsRT correct_trials(iTrial).timing.RT];
            xsMT = [xsMT correct_trials(iTrial).timing.MT];
            ys = [ys CV];
        end
    end
    
    if doplot
        [v,kRT] = sort(allRTs);
        subplot(132);
        plotSpikeRaster(cur_tsPeths(kRT,useEvents),'PlotType','scatter');
        hold on;
        allRTs = allRTs(kRT);
        plot(allRTs-1,[1:numel(allRTs)],'r*');
        title('RT')
        [v,kMT] = sort(allMTs);
        subplot(133);
        plotSpikeRaster(cur_tsPeths(kMT,useEvents),'PlotType','scatter');
        hold on;
        allMTs = allMTs(kMT);
        plot(allMTs-1,[1:numel(allMTs)],'b*');
        title('MT')
    end
end

close 