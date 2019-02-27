% function med_pets = calc_pets(all_trials,eventFieldnames)
% average peri-event time intervals

nTrials = [];
trialCount = 0;
trialTimes = [];
for iNeuron = 1:numel(all_trials)
    trials = all_trials{iNeuron};
    if ~isempty(nTrials) && numel(trials) == nTrials
        continue;
    else
        nTrials = numel(trials);
    end
    for iTrial = 1:numel(trials)
        if trials(iTrial).correct
            trialCount = trialCount + 1;
            for iEvent = 1:7
                trialTimes(trialCount,iEvent) = getfield(trials(iTrial).timestamps,eventFieldnames{iEvent});
            end
        end
    end
end
med_pets = median(diff(trialTimes,1,2));
% I'm not sure this is even helpful: centerOut times will be small, and cueOn times long, but we actually don't want to
% highlight the cue event and do want to highlight the RT period