function [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,nBins_tWindow,trialTypes)
% just like classifyUnitToEvent but done in a loop with sub classes
% [ ] classify correct and failed?

unitEvents = {};
all_zscores = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);
%     trialIds = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];

% %     [allCounts,allCenters] = hist(all_ts{iNeuron},nBins_all_tWindow);
    
    unitEvents{iNeuron} = {};
    useTrials = [];
    for iTrialTypes = 1:numel(trialTypes)
        useTrials = [useTrials getfield(trialIdInfo,trialTypes{iTrialTypes})];
    end
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
    unitEvents{iNeuron}.class = [];
    unitEvents{iNeuron}.maxz = [];
    unitEvents{iNeuron}.maxbin = [];
    
    % skip if empty (incorrect)
    if ~any(size(tsPeths))
        continue;
    end
    ts_event1 = [tsPeths{:,1}];
    [counts_events1,centers_event1] = hist(ts_event1,nBins_tWindow);
    
    % skip if no counts, can't determine mean/std
    if counts_events1 == 0
        continue;
    else
        zMean = mean(counts_events1 / size(tsPeths,1));
        zStd = std(counts_events1 / size(tsPeths,1));
    end
    zscores = [];
    for iEvent = 1:numel(eventFieldnames)
        ts_eventX = [tsPeths{:,iEvent}];
        [counts_eventsX,centers_eventX] = hist(ts_eventX,nBins_tWindow);
%         zscore(iEvent,:) = ((counts_eventsX / size(tsPeths,1)) - mean(allCounts)) / std(allCounts); % old method
        zscore(iEvent,:) = ((counts_eventsX / size(tsPeths,1)) - zMean) / zStd;
    end
    all_zscores(iNeuron,:,:) = zscore;
    [max_z,max_bins] = max(zscore');
    % leave these values in event order (1-7)
    unitEvents{iNeuron}.maxz = max_z;
    unitEvents{iNeuron}.maxbin = max_bins;
    % this is where the event class is actually ranked/ordered using key
    [~,unitEvents{iNeuron}.class] = sort(max_z,'descend');
end