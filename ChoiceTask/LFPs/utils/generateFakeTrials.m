function fakeTrials = generateFakeTrials(nTrials,realTrials,eventFieldnames)

allCues = [];
for iTrial = 1:numel(realTrials)
    allCues(iTrial) = realTrials(iTrial).timestamps.cueOn;
end
a = min(allCues);
b = max(allCues);
fakeTrials = struct;
for iTrial = 1:nTrials
    timestamps = struct;
    for iEvent = 1:numel(eventFieldnames)
        randTs = (b-a) .* rand + a;
        timestamps = setfield(timestamps,eventFieldnames{iEvent},randTs);
    end
    fakeTrials(iTrial).timestamps = timestamps;
end