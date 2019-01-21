function trials = addEventToTrials(trials,eventName)

trialTimeRanges = compileTrialTimeRanges(trials);
minTime = min(trialTimeRanges(:,2));
maxTime = max(trialTimeRanges(:,1));

for iTrial = 1:numel(trials)
    randTs = (maxTime-minTime) .* rand + minTime;
    trials(iTrial).timestamps = setfield(trials(iTrial).timestamps,eventName,randTs);
end