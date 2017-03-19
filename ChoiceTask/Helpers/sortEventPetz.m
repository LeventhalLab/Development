function sorted_petz = sortEventPetz(all_eventPetz,allTrials,timingField)
% all_eventPetz{iNeuron} = allZs{iEvent,iTrial}
% => petz{iEvent} = {iNeuron,meanPetzAllTrials}
petz = {};
all_allTimes = [];
for iNeuron = 1:size(all_eventPetz,2)
    neuronPetz = all_eventPetz{iNeuron};
    trials = allTrials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(trials,timingField);
    all_allTimes = [all_allTimes allTimes];
%     trials = trials(trialIds);
    for iEvent = 1:size(neuronPetz,1)
        eventPetz = cell2mat(neuronPetz(1,trialIds)');
        if size(petz,2) < iEvent
            petz{iEvent} = eventPetz;
        else
            petz{iEvent} = [petz{iEvent};eventPetz];
        end
    end
end

[~,k] = sort(all_allTimes);
sorted_petz = {};
for iEvent = 1:size(petz,2)
    eventPetz = petz{1,iEvent};
    sorted_petz{iEvent} = eventPetz(k,:);
end