function trialTimeRanges = compileTrialTimeRanges(trials,maxTrialTime)
% maxTrialTime = 5;
trialTimeRanges = [];
trialCount = 0;
for iTrial = 1:numel(trials)
    fields = fieldnames(trials(iTrial).timestamps);
    trialTimes = [];
    for ii = 1:numel(fields)
        ts = trials(iTrial).timestamps.(fields{ii});
        if ~isempty(ts)
            trialTimes = [trialTimes ts];
        end
    end
    if max(trialTimes) - min(trialTimes) < maxTrialTime
        trialCount = trialCount + 1;
        trialTimeRanges(trialCount,:) = [min(trialTimes),max(trialTimes)];
    end
end