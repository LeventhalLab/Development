function trialIdInfo = organizeTrialsById_pretone(trials,minpretone,maxpretone)

trialIdInfo = {};
correctContra = [];
correctIpsi = [];
for iTrial = 1:numel(trials)
    if trials(iTrial).movementDirection == 1 && trials(iTrial).correct == 1 && trials(iTrial).timing.pretone >= minpretone && trials(iTrial).timing.pretone < maxpretone
        correctContra = [correctContra iTrial];
    end
    if trials(iTrial).movementDirection == 2 && trials(iTrial).correct == 1 && trials(iTrial).timing.pretone >= minpretone && trials(iTrial).timing.pretone < maxpretone
        correctIpsi = [correctIpsi iTrial];
    end
end

trialIdInfo.correctContra = correctContra;
trialIdInfo.correctIpsi = correctIpsi;
trialIdInfo.incorrectContra = find([trials.movementDirection] == 1 & [trials.tone] == 2);
trialIdInfo.incorrectIpsi = find([trials.movementDirection] == 2 & [trials.tone] == 1);