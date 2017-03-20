function [sorted_petz,sorted_values] = sortEventPetz(all_eventPetz,allTrials,timingField,zParams)
% all_eventPetz{iNeuron} = allZs{iEvent,iTrial}
% => petz{iEvent} = {iNeuron,meanPetzAllTrials}
% sortBy = 'MT';
% sortBy = [event,zThresh,startSortMs];    

petz = {};
all_allTimes = [];
for iNeuron = 1:size(all_eventPetz,2)
    neuronPetz = all_eventPetz{iNeuron};
    trials = allTrials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(trials,timingField);
    all_allTimes = [all_allTimes allTimes];
%     trials = trials(trialIds);
    for iEvent = 1:size(neuronPetz,1)
        eventPetz = cell2mat(neuronPetz(iEvent,trialIds)');
        if size(petz,2) < iEvent
            petz{iEvent} = eventPetz;
        else
            petz{iEvent} = [petz{iEvent};eventPetz];
        end
    end
end

sorted_petz = {};
if ~isempty(timingField)
    [sorted_values,k] = sort(all_allTimes);
    for iEvent = 1:size(petz,2)
        eventPetz = petz{1,iEvent};
        sorted_petz{iEvent} = eventPetz(k,:);
    end
end

if ~isempty(zParams)
    eventPetz = petz{1,zParams(1)};
    firstOccurs = [];
    for iTrial = 1:size(eventPetz,1)
        k = find(eventPetz(iTrial,zParams(3):end) > zParams(2));
        if isempty(k)
            firstOccurs(iTrial) = size(eventPetz,2);
        else
            firstOccurs(iTrial) = k(1)+zParams(3);
        end
    end
    [~,k] = sort(firstOccurs);
    sorted_values = sorted_values(k);
    for iEvent = 1:size(petz,2)
        eventPetz = petz{1,iEvent};
        sorted_petz{iEvent} = eventPetz(k,:);
    end
end

