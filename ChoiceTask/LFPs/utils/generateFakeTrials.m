function fakeTrials = generateFakeTrials(nTrials,realTrials,eventFieldnames)
% !! currently applies any random time, doesn't not check for in/out trial
% constrain between the first and last real trial using Cue event
allCues = [];
for iTrial = 1:numel(realTrials)
    allCues(iTrial) = realTrials(iTrial).timestamps.cueOn;
end
minTime = min(allCues);
maxTime = max(allCues);
fakeTrials = struct;
for iTrial = 1:nTrials
    timestamps = struct;
    for iEvent = 1:numel(eventFieldnames)
        randTs = (maxTime-minTime) .* rand + minTime;
        timestamps = setfield(timestamps,eventFieldnames{iEvent},randTs);
    end
    fakeTrials(iTrial).timestamps = timestamps;
end