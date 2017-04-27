% fix missing gotrial and tone events
% get first cueOn port from logData.Center(1)
% ... 2=P2, 4=P3, 8=P4
% get [startTime,startIdx] = getBehaviorStartTime(nexStruct);
% ... find cueOn from PX within .1s of startTime
% ... subtract .01 and this is gotrialOn
% ... gotrialOff = gotrialOn + .005;
% get next cueOn port from logData.Center(ii)
% 

all_cues = [];
for iEvent = [3 5 7]
    all_cues = [all_cues; nexStruct.events{iEvent}.timestamps];
end

all_nose = [];
for iEvent = [19 21 23]
    all_nose = [all_nose; nexStruct.events{iEvent}.timestamps];
end