function peths = eventsPeth(trials,ts,tWindow)
peths = {};

for iTrial=1:numel(trials)
    eventFieldnames = fieldnames(trials(iTrial).timestamps);
    for iField=1:numel(eventFieldnames)
        centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        if numel(centerTs) > 1 % handle weird case of two entries
            centerTs = centerTs(1);
        end
        peths{iTrial,iField} = tsPeth(ts,centerTs,tWindow);
    end
end