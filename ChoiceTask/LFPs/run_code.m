all_pretones = {};
for iNeuron = ic'
    curTrials = all_trials{iNeuron};
    [pretone_trialIds,allTimes_pretone] = sortTrialsBy(curTrials,'pretone');
    [RT_trialIds,~] = sortTrialsBy(curTrials,'RT');
    
    resort_allTimes_pretone = [];
    for iTrial = 1:numel(RT_trialIds)
        resort_allTimes_pretone(iTrial) = allTimes_pretone(RT_trialIds(iTrial) == pretone_trialIds);
    end
    
    all_pretones{iNeuron} = resort_allTimes_pretone;
end

% % all_times = {};
% % for iNeuron = ic'
% %     curTrials = all_trials{iNeuron};
% %     [RT_trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
% %     all_times{iNeuron} = allTimes;
% % end