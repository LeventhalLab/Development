function [startTime,startIdx] = getBehaviorStartTime(nexStruct)
% !!! these times still seem to be behind the first gotrialOn event by 30 ms?
% note: this is not the start of the first trial, which seems to have a
% timestamp 30ms different, this might not be the best measure, and I would
% rather trust something like:
% logData = readLogData(logFile);
% trials = createTrialsStruct_simpleChoice(logData,nexStruct);
videoOn = 47;
videoOff = 48;
% finds first instance of video trigger
startIdxOn = find(round(diff(nexStruct.events{videoOn,1}.timestamps),2) == 0.05,1);
startIdxOff = find(round(diff(nexStruct.events{videoOff,1}.timestamps),2) == 0.05,1);

% find minimum idx and start time between videoOn/Off
if startIdxOn < startIdxOff
    startIdx = startIdxOn;
    startTime = nexStruct.events{videoOn,1}.timestamps(startIdx);
elseif startIdxOn > startIdxOff
    startIdx = startIdxOff;
    startTime = nexStruct.events{videoOff,1}.timestamps(startIdx);
else % equal
    startIdx = startIdxOn;
    startTimeOn = nexStruct.events{videoOn,1}.timestamps(startIdx);
    startTimeOff = nexStruct.events{videoOff,1}.timestamps(startIdx);
    startTime = min([startTimeOn,startTimeOff]);
end