function startTime = behaviorStartTime(nexStruct)
videoOn = 47;
% finds first instance of video trigger
startIdx = find(round(diff(nexStruct.events{videoOn,1}.timestamps),2) == 0.05,1);
startTime = nexStruct.events{videoOn,1}.timestamps(startIdx);