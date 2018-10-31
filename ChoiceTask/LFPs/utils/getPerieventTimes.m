function trialTimes = getPerieventTimes(trials,eventFieldnames,refEvent)

trialTimes = [];
for iTrial = 1:size(trials,2)
    timestamps = trials(iTrial).timestamps;
    refTime = getfield(timestamps,eventFieldnames{refEvent});
    for iEvent = 1:7
        trialTimes(iTrial,iEvent) = getfield(timestamps,eventFieldnames{iEvent}) - refTime;
    end
end