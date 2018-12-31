function trialRanges = periEventTrialTs(trials,tWindow,eventFieldnames)

trialRanges = NaN(numel(eventFieldnames),numel(trials),2);
for iField = 1:numel(eventFieldnames)
    for iTrial = 1:numel(trials)
        try
            centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
            trialRanges(iField,iTrial,1) = centerTs - tWindow;
            trialRanges(iField,iTrial,2) = centerTs + tWindow;
        catch
            % do nothing, filled with NaN
        end
    end
end