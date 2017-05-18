timingField = 'RT';
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
useEvent = 4;
if true
    all_AP = [];
    all_ML = [];
    all_DV = [];
    
    all_mi = [];
    all_si = [];
    
    all_eventIds = [];
    nCorr = 1;

    for iNeuron = 1:size(all_tsPeths,2)
        neuronName = analysisConf.neurons{iNeuron};
        sessionConf = analysisConf.sessionConfs{iNeuron};
        [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
        rows = sessionConf.session_electrodes.channel == electrodeChannels;
        channelData = sessionConf.session_electrodes(any(rows)',:);
        event_id = eventIds_by_maxHistValues(iNeuron);
%         if ~ismember(event_id,useEvent)
%             continue;
%         end
        if isempty(channelData)
            continue;
        end
        AP = channelData{1,'ap'};
        ML = channelData{1,'ml'};
        DV = channelData{1,'dv'};
    
        trials = all_trials{iNeuron};
        [trialIds,allTimesRT] = sortTrialsBy(trials,timingField);
        ts = all_ts{iNeuron};
        tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
        for iTrial = 1:size(tsPeths,1)
            if allTimesRT(iTrial) <= 0
                continue;
            end
            z_tsPeth = tsPeths{iTrial,1};
            [z_counts,z_centers] = hist(z_tsPeth,nBins_tWindow);
            z_idxs = find(nBins_tWindow <= 0);
            z_counts = z_counts(z_idxs);
            z_centers = z_centers(z_idxs);

            if mean(z_counts) < 0.25
                continue;
            end

            tsPeth = tsPeths{iTrial,eventId};
            [counts,centers] = hist(tsPeth,nBins_tWindow);
            zscore = (counts - mean(z_counts)) / std(z_counts);
            [mi,si] = msIndex(zscore);
            
            all_mi = [all_mi mi];
            all_si = [all_si si];
            all_AP = [all_AP AP];
            all_ML = [all_ML ML];
            all_DV = [all_DV DV];
            all_eventIds = [all_eventIds event_id];

            nCorr = nCorr + 1;
        end
    end
end
