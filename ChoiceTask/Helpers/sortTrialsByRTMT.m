function [trialIds,allRT,allMT] = sortTrialsByRTMT(trials,trialIdsBy)

allRT = [];
trialIds = [];
trialCount = 1;
for iTrial = 1:length(trials)
    % might not want to force correct in the future
    if trials(iTrial).correct
        tRT = getfield(trials(iTrial).timing,'RT');
        tMT = getfield(trials(iTrial).timing,'MT');
        % not sure why there are some negative times, set to 0?
        allRT(trialCount) = tRT;
        if tRT < 0
            allRT(trialCount) = 0;
        end
        allMT(trialCount) = tMT;
        
        trialIds(trialCount) = iTrial;
        trialCount = trialCount + 1;
    end
end

if strcmp(trialIdsBy,'RT')
    [allRT,k] = sort(allRT);
    trialIds = trialIds(k);
    allMT = allMT(k);
else % MT
    [allMT,k] = sort(allMT);
    trialIds = trialIds(k);
    allRT = allRT(k);
end
    
disp(['sortTrialsBy.m: ',trialIdsBy,' asc (low -> high)']);
