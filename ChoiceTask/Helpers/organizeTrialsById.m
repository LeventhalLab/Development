function trialIdInfo = organizeTrialsById(trials)

trialIdInfo = {};
trialIdInfo.correctContra = find([trials.movementDirection] == 1 & [trials.correct] == 1);
trialIdInfo.incorrectContra = find([trials.movementDirection] == 1 & [trials.tone] == 2);
trialIdInfo.correctIpsi = find([trials.movementDirection] == 2 & [trials.correct] == 1);
trialIdInfo.incorrectIpsi = find([trials.movementDirection] == 2 & [trials.tone] == 1);
