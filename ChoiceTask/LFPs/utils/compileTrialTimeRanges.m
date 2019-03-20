function [intrialTimeRanges,intertrialTimeRanges] = compileTrialTimeRanges(trials,maxTrialTime)
% intrial will start with first trial
% intertrial will start from 0 to first trial and end at the start of the last trial
% trials must be given in trial-order

intrialTimeRanges = NaN(numel(trials),2);
intertrialTimeRanges = intrialTimeRanges;
for iTrial = 1:numel(trials)
    fields = fieldnames(trials(iTrial).timestamps);
    trialTimes = [];
    for ii = 1:numel(fields)
        ts = trials(iTrial).timestamps.(fields{ii});
        if ~isempty(ts)
            trialTimes = [trialTimes ts];
        end
    end
    
    intrialTimeRanges(iTrial,:) = [min(trialTimes),max(trialTimes)];
    if iTrial == 1
        intertrialTimeRanges(iTrial,:) = [0 intrialTimeRanges(iTrial,1)];
    else
        intertrialTimeRanges(iTrial,:) = [intrialTimeRanges(iTrial-1,2),intrialTimeRanges(iTrial,1)];
        if sign(diff(intertrialTimeRanges(iTrial,:))) == -1
            disp('stop');
        end
        if max(trialTimes) < max(intrialTimeRanges(:,2))
            error('trials need to be in trial-order');
        end
    end
end

longTrials = find(diff(intrialTimeRanges,1,2) > maxTrialTime);
intrialTimeRanges(longTrials,:) = repmat([NaN NaN],size(longTrials));