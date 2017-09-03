function trialIdInfo = organizeTrialsById(trials)

trialIdInfo = {};
trialIdInfo.correctContra = find([trials.movementDirection] == 1 & [trials.correct] == 1);
trialIdInfo.incorrectContra = find([trials.movementDirection] == 1 & [trials.tone] == 2);
trialIdInfo.correctIpsi = find([trials.movementDirection] == 2 & [trials.correct] == 1);
trialIdInfo.incorrectIpsi = find([trials.movementDirection] == 2 & [trials.tone] == 1);

trialIdInfo.falseStart = [];
for trialId = find([trials.falseStart] == 1)
    if ~isempty(trials(trialId).timestamps.centerIn) && ~isempty(trials(trialId).timestamps.centerOut)
        trialIdInfo.falseStart = [trialIdInfo.falseStart trialId];
    end
end

trialIdInfo.correct = find([trials.correct] == 1);
trialIdInfo.incorrect = find([trials.correct] == 0);

trialIdInfo.movementTooLong = find([trials.movementTooLong] == 1);
trialIdInfo.holdTooLong = find([trials.holdTooLong] == 1);