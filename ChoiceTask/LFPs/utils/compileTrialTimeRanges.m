function trialTimeRanges = compileTrialTimeRanges(trials,maxTrialTime)
break; % see curateTrials
% maxTrialTime = 5;
trialTimeRanges = [];
trialCount = 0;
for iTrial = 1:numel(trials)
    fields = fieldnames(trials(iTrial).timestamps);
    trialTimes = [];
    noseIn = [];
    foodRetrieval = [];
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