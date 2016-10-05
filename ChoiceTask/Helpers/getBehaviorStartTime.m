function startTime = getBehaviorStartTime(nexStruct)
% note: this is not the start of the first trial, which seems to have a
% timestamp 30ms different, this might not be the best measure, and I would
% rather trust something like:
% logData = readLogData(logFile);
% trials = createTrialsStruct_simpleChoice(logData,nexStruct);
videoOn = 47;
% finds first instance of video trigger
startIdx = find(round(diff(nexStruct.events{videoOn,1}.timestamps),2) == 0.05,1);
startTime = nexStruct.events{videoOn,1}.timestamps(startIdx);