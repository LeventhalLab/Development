function [trials,rShift] = shiftTimestamps(trials,shiftSec)

rShift = (rand * 2 * shiftSec) - shiftSec;
for iTrial = 1:numel(trials)
    useFields = fieldnames(trials(iTrial).timestamps);
    for iField = 1:numel(useFields)
        rTime = getfield(trials(iTrial).timestamps,useFields{iField}) + rShift;
        trials(iTrial).timestamps = setfield(trials(iTrial).timestamps,useFields{iField},rTime);
    end
end