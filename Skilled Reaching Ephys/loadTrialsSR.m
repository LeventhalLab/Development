function [greenTrigTS,irTS,ap3TS,frameTrigger] = loadTrialsSR(sessionConf)
%Inputs
%   sessionConf
%Outputs
%greenTrigger(1xN array) where N is number of trials. Contains time stamps
%   of every video's 300th frame(aka when green trigger happens)
%IRts(1xN array) is time stamps of when IR sensor is triggered prior to
%   green trigger in each trial
%AP4ts(1xN) is time stamps of when actuator position 3 is turned on, i.e.
%   when pellet is lifted


nexPath = sessionConf.nexPath;
[n,frameTrigger] = nex_ts(nexPath,'TTL5on');
[n,greenTrigTS] = nex_ts(nexPath,'TTL6on');
[n,actuatorPos3] = nex_ts(nexPath,'TTL3off');
[n,IRback] = nex_ts(nexPath,'TTL4on');

idx = find(greenTrigTS<frameTrigger(1));
greenTrigTS(idx) = [];
temp = greenTrigTS(2:end);
while find((temp-greenTrigTS(1:end-1))<5);
   idx = find((temp-greenTrigTS(1:end-1))<5); %remove artifacts
   greenTrigTS(idx+1) = [];
   temp = greenTrigTS(2:end);
end

for i=1:length(greenTrigTS)
   idx = find(actuatorPos3<greenTrigTS(i),1,'last');
   ap3TS(i) = actuatorPos3(idx);
   idx = find(IRback<ap3TS(i),1,'last');
   irTS(i) = IRback(idx);

end

end
