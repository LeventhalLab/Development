% function [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,RTmin,RTmax)
function [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents)
% just like classifyUnitToEvent but done in a loop with sub classes
% [ ] classify correct and failed?
binS = binMs / 1000;
nBins_tWindow = [-tWindow:binS:tWindow];

unitEvents = {};
all_zscores = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
%     trialIdInfo = organizeTrialsById_RT(curTrials,RTmin,RTmax);
    trialIdInfo = organizeTrialsById(curTrials);

% %     [allCounts,allCenters] = hist(all_ts{iNeuron},nBins_all_tWindow);
    unitEvents{iNeuron} = {};
    unitEvents{iNeuron}.class = [];
    unitEvents{iNeuron}.maxz = [];
    unitEvents{iNeuron}.maxbin = [];
    
    % get tsPeths for all trials to generate zMean and zStd
    useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
    tWindow_zbaseline = 2;
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow_zbaseline,eventFieldnames);
    
    % skip if empty (incorrect)
    if ~any(size(tsPeths))
        continue;
    end
%     ts_event1 = [tsPeths{:,1}];
    all_hValues = [];
    nBins_tWindow_zbaseline = [-tWindow_zbaseline:binS:0];
    for iTrial = 1:size(tsPeths,1)
        ts_event1 = tsPeths{iTrial,1};
        h = histogram(ts_event1,nBins_tWindow_zbaseline);
        all_hValues(iTrial,:) = smooth(h.Values,3);
    end
    zStd = mean(std(all_hValues));
    zMean = mean(mean(all_hValues));
    
    % skip if no counts, can't determine mean/std
    if zStd == 0 || zMean == 0
        continue;
    end
    
    % now get tsPeths for only trialTypes
    useTrials = [];
    for iTrialTypes = 1:numel(trialTypes)
        useTrials = [useTrials getfield(trialIdInfo,trialTypes{iTrialTypes})];
    end
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
    if isempty(tsPeths)
        continue;
    end
    zscore = [];
    zscore_filt = [];
    for iEvent = 1:numel(eventFieldnames)
        ts_eventX = [tsPeths{:,iEvent}];
        h = histogram(ts_eventX,nBins_tWindow);
%         zscore(iEvent,:) = ((counts_eventsX / size(tsPeths,1)) - mean(allCounts)) / std(allCounts); % old method
        % just set z=0 if not using events; works for now
        zscore(iEvent,:) = ((h.Values / size(tsPeths,1)) - zMean) / zStd;
        if ismember(iEvent,useEvents)
            zscore_filt(iEvent,:) = zscore(iEvent,:);
        else
            zscore_filt(iEvent,:) = zeros(size(h.Values));
        end
    end
    all_zscores(iNeuron,:,:) = zscore;
    [max_z,max_bins] = max(zscore_filt');
    % leave these values in event order (e.g. 1-7)
    unitEvents{iNeuron}.maxz = max_z;
    unitEvents{iNeuron}.maxbin = max_bins;
    % this is where the event class is actually ranked/ordered using key
    [~,unitEvents{iNeuron}.class] = sort(max_z,'descend');
end