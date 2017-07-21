trialTypes = {'correctContra','correctIpsi','incorrectContra','incorrectIpsi'};
% % [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,nBins_tWindow,trialTypes);

iUnitTrials = 1;
all_MT = [];
all_RT = [];
all_pretone = [];
all_noseInMinZ = [];

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
    testEvent = 2;
    for iTrial = 1:numel(useTrials)
        ts_eventX = tsPeths{iTrial,testEvent};
        if isempty(ts_eventX)
            continue;
        end
        [counts_eventsX,centers_eventX] = hist(ts_eventX,nBins_tWindow);
        zscore = (counts_eventsX - zMean) / zStd;
        try 
            all_MT(iUnitTrials) = curTrials(useTrials(iTrial)).timing.MT;
            all_RT(iUnitTrials) = curTrials(useTrials(iTrial)).timing.RT;
        catch
            all_MT(iUnitTrials) = curTrials(useTrials(iTrial)).timing.movementTime;
            all_RT(iUnitTrials) = curTrials(useTrials(iTrial)).timing.reactionTime;
        end
        all_pretone(iUnitTrials) = curTrials(useTrials(iTrial)).timing.pretone;
        all_noseInMinZ(iUnitTrials) = min(interp(zscore,10));
        if all_noseInMinZ(iUnitTrials) == 0 || all_MT(iUnitTrials) == 0 || all_RT(iUnitTrials) == 0
            continue;
        end
        iUnitTrials = iUnitTrials + 1;
    end
end

markerSize = 5;
figuree(1200,400);
subplot(131);
plot(all_MT,all_noseInMinZ,'k.','MarkerSize',markerSize);
xlabel('MT');
ylabel('Z');

subplot(132);
plot(all_RT,all_noseInMinZ,'k.','MarkerSize',markerSize);
xlabel('RT');
ylabel('Z');

subplot(133);
plot(all_pretone,all_noseInMinZ,'k.','MarkerSize',markerSize);
xlabel('pretone');
ylabel('Z');