% function [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,RTmin,RTmax)
% function [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,MTmin,MTmax)
% function [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,pretonemin,pretonemax)
function [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents)
% just like classifyUnitToEvent but done in a loop with sub classes
% [ ] classify correct and failed?
binS = binMs / 1000;
nBins_tWindow = [-tWindow:binS:tWindow];

unitEvents = {};
all_zscores = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['classifyUnitsToEvents: ',neuronName]);
    curTrials = all_trials{iNeuron};
%     trialIdInfo = organizeTrialsById_pretone(curTrials,pretonemin,pretonemax);
%     trialIdInfo = organizeTrialsById_MT(curTrials,MTmin,MTmax);
%     trialIdInfo = organizeTrialsById_RT(curTrials,RTmin,RTmax);
    trialIdInfo = organizeTrialsById(curTrials);

    unitEvents{iNeuron} = {};
    unitEvents{iNeuron}.class = [];
    unitEvents{iNeuron}.maxz = [];
    unitEvents{iNeuron}.maxbin = [];

    % --- find MEAN & STD from random trials
    tsPeths = {};
    a = tWindow;
    b = max(all_ts{iNeuron}) - tWindow;
    nSamples = 500; % converges pretty well (1800x 2s bins in 3600s session, more is oversampling)
    r = (b-a).*rand(nSamples,1) + a;
    for iir = 1:numel(r)
        tsPeths{iir,1} = tsPeth(all_ts{iNeuron},r(iir),tWindow);
    end
    all_hValues = [];
    for iTrial = 1:size(tsPeths,1)
        ts_event1 = tsPeths{iTrial,1};
        hCounts = histcounts(ts_event1,nBins_tWindow);
        all_hValues(iTrial,:) = hCounts;
    end
    zStd = std(mean(all_hValues));
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
        curEvent = useEvents(iEvent);
        ts_eventX = [tsPeths{:,iEvent}];
        hCounts = histcounts(ts_eventX,nBins_tWindow);
        % just set z=0 if not using events; works for now
        zscore(iEvent,:) = ((hCounts / size(tsPeths,1)) - zMean) / zStd;
        if ismember(curEvent,useEvents)
            zscore_filt(iEvent,:) = zscore(iEvent,:);
        else
            zscore_filt(iEvent,:) = zeros(size(hCounts));
        end
    end
    all_zscores(iNeuron,:,:) = zscore;
    [max_z,max_bins] = max(zscore_filt');
    % leave these values in event order (e.g. 1-7)
    unitEvents{iNeuron}.maxz = max_z;
    unitEvents{iNeuron}.maxbin = max_bins;
    % this is where the event class is actually ranked/ordered using key
    [~,neuronClasses] = sort(max_z,'descend');
    while ismember(-1,diff(neuronClasses))
        [~,k] = ismember(-1,diff(neuronClasses));
        neuronClasses(k+1) = [];
    end
        
    unitEvents{iNeuron}.class = neuronClasses;
end