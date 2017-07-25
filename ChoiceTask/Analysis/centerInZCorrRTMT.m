all_trialTypes = {'correctContra','correctIpsi','incorrectContra','incorrectIpsi'};
figure;
for ii=1:4
trialTypes = {all_trialTypes{ii}};
[unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,nBins_tWindow,trialTypes);

iUnitTrials = 1;
all_MT = [];
all_RT = [];
all_pretone = [];
all_noseInMinZ = [];

all_mean_zscores = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);

% %     [allCounts,allCenters] = hist(all_ts{iNeuron},nBins_all_tWindow);
    
    useTrials = [];
    for iTrialTypes = 1:numel(trialTypes)
        useTrials = [useTrials getfield(trialIdInfo,trialTypes{iTrialTypes})];
    end
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
    if isempty(tsPeths)
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
        all_noseInMinZ(iUnitTrials) = mean(zscore(20:30));
        if all_noseInMinZ(iUnitTrials) == 0 || all_MT(iUnitTrials) == 0 || all_RT(iUnitTrials) == 0
            continue;
        end
        iUnitTrials = iUnitTrials + 1;
    end
%     plot(interp(all_mean_zscores(iNeuron,:),10),'color',[.2 .2 .2 .2]);
%     hold on;
end
e = errorbar(ii,mean(all_noseInMinZ),std(all_noseInMinZ),'Marker','*','LineWidth',3);
hold on;
end
xticks([1:4]);
xticklabels(all_trialTypes);
xtickangle(60);
xlim([0 5]);

% plot(interp(nanmean(all_mean_zscores),10),'r','LineWidth',3);
% ylim([0 1]);
if false
    markerSize = 5;
%     figuree(1200,400);
    subplot(131);
    plot(all_MT,all_noseInMinZ,'r.','MarkerSize',markerSize);hold on;
    xlabel('MT');
    ylabel('Z');
    xlim([0 1]);
    ylim([-15 15]);

    subplot(132);
    plot(all_RT,all_noseInMinZ,'r.','MarkerSize',markerSize);hold on;
    xlabel('RT');
    ylabel('Z');
    xlim([0 1]);
    ylim([-15 15]);

    subplot(133);
    plot(all_pretone,all_noseInMinZ,'r.','MarkerSize',markerSize);hold on;
    xlabel('pretone');
    ylabel('Z');
    xlim([.5 1]);
    ylim([-15 15]);
end