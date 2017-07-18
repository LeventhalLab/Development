% function classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow)
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
    
    tsPeths = eventsPeth(curTrials([trialIdInfo.correctContra trialIdInfo.correctIpsi]),all_ts{iNeuron},tWindow,eventFieldnames);
    unitEvents{iNeuron}.correct = {};
    unitEvents{iNeuron}.correct.class = [];
    unitEvents{iNeuron}.correct.maxz = [];
    unitEvents{iNeuron}.correct.maxbin = [];
    
    if ~any(size(tsPeths))
        continue;
    end
    ts_event1 = [tsPeths{:,1}];
    [counts_events1,centers_event1] = hist(ts_event1,nBins_tWindow);
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
    unitEvents{iNeuron}.correct.maxz = max_z;
    unitEvents{iNeuron}.correct.maxbin = max_bins;
    % this is where the event class is actually ranked/ordered using key
    [~,unitEvents{iNeuron}.correct.class] = sort(max_z,'descend');
% %     figuree(1200,400);
% %     for iEvent = 1:numel(eventFieldnames)
% %         subplot(1,numel(eventFieldnames),iEvent);
% %         plot(centers_eventX,smooth(zscore(iEvent,:),3),'LineWidth',2);
% %         ylim([-2 8]);
% %     end
%     disp('hold on');
end