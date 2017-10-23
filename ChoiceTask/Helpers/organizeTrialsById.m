function trialIdInfo = organizeTrialsById(trials)
% movementDirection = 1 --> contra move
% tone = 1 --> contra cue
trialIdInfo = {};
trialIdInfo.correctContra = find([trials.movementDirection] == 1 & [trials.correct] == 1); % moved contra on contra tone
trialIdInfo.incorrectContra = find([trials.movementDirection] == 1 & [trials.tone] == 2); % moved contra on ipsi tone
trialIdInfo.correctIpsi = find([trials.movementDirection] == 2 & [trials.correct] == 1); % moved ipsi on ipsi tone
trialIdInfo.incorrectIpsi = find([trials.movementDirection] == 2 & [trials.tone] == 1); % moved ipsi on contra tone

trialIdInfo.toneContra = find([trials.tone] == 1);
trialIdInfo.toneIpsi = find([trials.tone] == 2);
trialIdInfo.moveContra = find([trials.movementDirection] == 1);
trialIdInfo.moveIpsi = find([trials.movementDirection] == 2);

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