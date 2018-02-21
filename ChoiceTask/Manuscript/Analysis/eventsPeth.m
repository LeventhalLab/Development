function peths = eventsPeth(trials,ts,tWindow,eventFieldnames)
peths = {};

for iTrial = 1:numel(trials)
    curFieldnames = fieldnames(trials(iTrial).timestamps);
    for iField = 1:numel(eventFieldnames)
        if ismember(eventFieldnames{iField},curFieldnames)
            centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
            if numel(centerTs) > 1 % handle weird case of two entries
                centerTs = centerTs(1);
            end
            peths{iTrial,iField} = tsPeth(ts,centerTs,tWindow);
        else
            peths{iTrial,iField} = [];
        end
    end
end