function nexStruct = fixMissingEvents(logData,nexStruct)

% fix missing gotrial and tone events
% get first cueOn port from logData.Center(1)
% ... 2=P2, 4=P3, 8=P4
% get [startTime,startIdx] = getBehaviorStartTime(nexStruct);
% ... find cueOn from PX within .1s of startTime
% ... subtract .01 and this is gotrialOn
% ... gotrialOff = gotrialOn + .005;
% get next cueOn port from logData.Center(ii)
% 292 allcues (184 accounted, 108 rem)
% 221 centers (129 accounted, 112 rem)
% 108 trials
% 66 [0]* correct
% 14 [1] false start
% N/A [2]
% 2 [3] wrong start port?
% 0 [4]* exceeded limit hold
% 9 [5]* wrong way
% 17 [6]* failed side port entry
% 35 [hl]
% 184 2x cues
% 92 zero-time cues
% add all doubled cues, add single cues, subtract zero entries!

curTime = 0;
gotrialOn = [];
tone1On = [];
tone2On = [];
alltone1 = [];
alltone2 = [];
for iTrial = 1:numel(logData.outcome)
    centerCueEvent = ((log2(logData.Center(iTrial)) + 1) * 2) - 1;
    centerCueTimes = nexStruct.events{centerCueEvent,1}.timestamps;
    centerCueTimes = centerCueTimes(centerCueTimes > curTime);
    curTime = centerCueTimes(1);
    
    gotrialOn(iTrial) = curTime - .01;
    outcome = logData.outcome(iTrial);
    if ismember(outcome,[0,4,5,6])
        % there should be a centerIn event
        centerInEvent = centerCueEvent + 16;
        centerInTimes = nexStruct.events{centerInEvent,1}.timestamps;
        centerInTimes = centerInTimes(centerInTimes > curTime);
        toneTime = centerInTimes(1) + logData.pretone(iTrial);
        if logData.Tone(iTrial) == 1000
            tone1On = [tone1On toneTime];
            alltone1 = [alltone1 trials(iTrial).timestamps.tone];
        else
            tone2On = [tone2On toneTime];
            alltone2 = [alltone2 trials(iTrial).timestamps.tone];
        end
        
        % find target port time
        targetEvent = ((log2(logData.Target(iTrial)) + 1) * 2) - 1;
        targetTimes = nexStruct.events{targetEvent,1}.timestamps;
        targetTimes = targetTimes(targetTimes > curTime);
        curTime = targetTimes(1);
    else
        % no second port light
    end
end
gotrialOff = gotrialOn + .005;
tone1Off = tone1On + .25;
tone2Off = tone2On + .25;
close all;
figure;plot(tone1On - alltone1);

if isempty(nexStruct.events{39}.timestamps)
    nexStruct.events{39}.timestamps = gotrialOn;
    nexStruct.events{40}.timestamps = gotrialOff;
end
% the nexStruct will have extra enries between tone1 & tone2 at the
% beginning which are equal to the startIdx (i.e. junk)... I don't think it
% matters if I return them unpadded or that the amount of tone events I
% have reflects the original amount that would have been recorded
if numel(nexStruct.events{33}.timestamps) == 0 && numel(find(logData.tone == 1000)) > 0
    nexStruct.events{33}.timestamps = tone1On;
    nexStruct.events{34}.timestamps = tone1Off;
end
if numel(nexStruct.events{35}.timestamps) == 0 && numel(find(logData.tone == 4000)) > 0
    nexStruct.events{35}.timestamps = tone2On;
    nexStruct.events{36}.timestamps = tone2Off;
end