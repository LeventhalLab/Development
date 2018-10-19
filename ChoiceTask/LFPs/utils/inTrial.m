function isInTrial = inTrial(randTs,takeTime,trialTimeRanges)
    isInTrial = false;
    for iTrial = 1:size(trialTimeRanges,1)
        % does it start in-trial?
        if randTs > trialTimeRanges(iTrial,1) && randTs < trialTimeRanges(iTrial,2)
            isInTrial = true;
            return;
        end
        % does it end in-trial?
        if randTs + takeTime > trialTimeRanges(iTrial,1) && randTs + takeTime < trialTimeRanges(iTrial,2)
            isInTrial = true;
            return;
        end
    end
end