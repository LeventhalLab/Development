function [peth] = eventsPeth(trials,trialIds,ts,pethWindow)
peth = struct;
for iField=plotEventIdx
    trialCount = 1;
    for iTrial=trialIds
        eventFieldnames = fieldnames(trials(iTrial).timestamps);
        centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        peth{trialCount,iField} = tsPeth(ts,centerTs,pethWindow);
            trialCount = trialCount + 1;
        end
    end
end