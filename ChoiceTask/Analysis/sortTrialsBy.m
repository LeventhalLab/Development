function [trialIds,allTimes] = sortTrialsBy(trials,timingField)

allTimes = [];
trialIds = [];
trialCount = 1;
for iTrial = 1:length(trials)
    % might not want to force correct in the future
    if trials(iTrial).correct
        if ~isempty(timingField) % otherwise just filter correct trials
            if strcmp(timingField,'movementDirection')
                allTimes(trialCount) = trials(iTrial).movementDirection;
            else
                t = getfield(trials(iTrial).timing,timingField);
                % not sure why there are some negative times, set to 0?
                if t < 0
                    allTimes(trialCount) = 0;
                else
                    allTimes(trialCount) = t;
                end
            end
        end
        trialIds(trialCount) = iTrial;
        trialCount = trialCount + 1;
    end
end

if ~isempty(timingField)
    [allTimes,k] = sort(allTimes);
    trialIds = trialIds(k);
    disp(['sortTrialsBy.m: ',timingField,' asc (low -> high)']);
end