function trialTimeRanges = compileTrialTimeRanges(trials)

trialTimeRanges = [];
for iTrial = 1:numel(trials)
    fields = fieldnames(trials(iTrial).timestamps);
    trialTimes = [];
    for ii = 1:numel(fields)
        ts = trials(iTrial).timestamps.(fields{ii});
        if ~isempty(ts)
            trialTimes = [trialTimes ts];
        end
    end
    trialTimeRanges(iTrial,:) = [min(trialTimes),max(trialTimes)];
end