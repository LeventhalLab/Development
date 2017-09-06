function [unitEvents,all_zscores,unitClasses] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming)
binS = binMs / 1000;
nBins_tWindow = [-tWindow:binS:tWindow];

unitEvents = {};
all_zscores = [];
unitClasses = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['classifyUnitsToEvents: ',neuronName]);
    curTrials = all_trials{iNeuron};
    if isempty(useTiming)
        trialIdInfo = organizeTrialsById(curTrials);
    else
        t_minmax = useTiming{2};
        switch useTiming{1}
            case 'RT'
                trialIdInfo = organizeTrialsById_RT(curTrials,t_minmax(1),t_minmax(2));
            case 'MT'
                trialIdInfo = organizeTrialsById_MT(curTrials,t_minmax(1),t_minmax(2));
            case 'pretone'
                trialIdInfo = organizeTrialsById_pretone(curTrials,t_minmax(1),t_minmax(2));
        end
                
    end 

    unitEvents{iNeuron} = {};
    unitEvents{iNeuron}.class = [];
    unitEvents{iNeuron}.maxz = [];
    unitEvents{iNeuron}.maxbin = [];

    ts = all_ts{iNeuron};
    [zMean,zStd] = zParams(ts,binMs);
    
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
    while any(ismember([-1 1],diff(neuronClasses)))
        [v,k] = ismember([-1 1],diff(neuronClasses));
        neuronClasses(min(k(v))+1) = [];
    end
        
    unitEvents{iNeuron}.class = neuronClasses;
    unitClasses(iNeuron) = neuronClasses(1);
end