function trials = createTrialsStruct_simpleChoice( logData, nexData )
%
% usage:
%
% INPUTS:
%   logData - behavioral log data as read in by the readLogData function.
%       See readLogData comments for structure details
%   nexData - nex data structure created by box2nex_useHeader
%
% OUTPUTS:
%   trials - trials structure, similar to what was originally generated by
%       Greg Gage. It includes the fields:
%           .countsAsTrial - boolean indicating whether it counts as a
%               trial by Colin's definition (it's only a trial if the rat 
%               poked a lit port before the time out)
%           .valid - not sure how this differs from countsAsTrial
%           .trialType - all GO trials in this version of the task, the
%               indicator is "1"
%           .holdTooLong - didn't pull out of the center port before time
%               expired
%           .movementTooLong - didn't poke the second port before time
%               expired
%           .timestamps 
%           .falseStart
%           .correct
%           .invalidNP
%           .tone
%           .centerNP
%           .movementDirection
%           .sideNP
%           .timing
%               .
%           .logConflict.isConflict

%    outcome - 0 = successful
%              1 = false start, started before GO tone
%              2 = false start, failed to hold for PSSHT (for
%                  stop-signal/go-nogo; not relevant for simple choice task)
%              3 = rat started in the wrong port
%              4 = rat exceeded the limited hold
%              5 = rat went the wrong way after the tone
%              6 = rat failed to go back into a side port in time
%              7 = Outcome wasn't recorded in the data file

timingTolerance = 1e-4;
trials_to_search_for_startMark = 10;
%**************************************************************************
% some preliminaries to set up the trials structure
trials(1).countsAsTrial = [];
trials(1).valid = [];
trials(1).trialType = [];
trials(1).holdTooLong = [];
trials(1).movementTooLong = [];
trials(1).timestamps.cueOn = [];
trials(1).falseStart = [];
trials(1).correct = [];
trials(1).invalidNP = [];
trials(1).tone = [];
trials(1).centerNP = [];
trials(1).movementDirection = [];
trials(1).sideNP = [];
trials(1).timing.pretone = [];
trials(1).logConflict.isConflict = 0;

boxLogConflicts.outcome = 0;
boxLogConflicts.RT = 0;
boxLogConflicts.MT = 0;
boxLogConflicts.pretone = 0;
boxLogConflicts.centerNP = 0;
boxLogConflicts.sideNP = 0;

trials(1).logConflict.boxLogConflicts = boxLogConflicts;
%**************************************************************************

% make sure all nexData timestamps are row vectors
for iEvent = 1 : length(nexData.events)
    if numel(nexData.events{iEvent}.timestamps) > size(nexData.events{iEvent}.timestamps, 2)
        nexData.events{iEvent}.timestamps = nexData.events{iEvent}.timestamps';
    end
end
events = nexData.events;

% first, find all the trial starts.
% off is actually the trial start, because we are using an active low
% duration for trial number
GO_markStartIdx = getEventIdx( events, 'gotrialoff');   % index of GO trial marker on events
GO_markEndIdx   = getEventIdx( events, 'gotrialon');  % index of GO trial marker off events

% GO_markStart_ts = events{GO_markStartIdx}.timestamps(1:end-1);
GO_markEnd_ts   = events{GO_markEndIdx}.timestamps(2:end);
GO_markStart_ts = events{GO_markStartIdx}.timestamps(1:length(GO_markEnd_ts));

%old
% GO_markStart_ts = events{GO_markStartIdx}.timestamps;
% GO_markEnd_ts   = events{GO_markEndIdx}.timestamps;

% if length(GO_markStart_ts) ~= length(GO_markEnd_ts)
%     % figure out why there isn't an "end" for each "start"
%     if GO_markEnd_ts(1) - GO_markStart_ts(1) > 0    % the recording didn't start between the first GO marker on and off events
%         numTrials = min(length(GO_markEnd_ts), length(GO_markStart_ts));
%     else
%         GO_markEnd_ts = GO_markEnd_ts(2:end);
%         numTrials = min(length(GO_markEnd_ts), length(GO_markStart_ts));
%     end
% end

% find the first index where GO_markEnd_ts - GO_markStart_ts = 0.005
% exitLoop = false;
% for iStartMark = 2 : min(length(GO_markStart_ts), trials_to_search_for_startMark)
%     for iEndMark = 1 : min(length(GO_markEnd_ts), trials_to_search_for_startMark)
%     
%         if GO_markEnd_ts(iEndMark) - GO_markStart_ts(iStartMark) < 0; continue; end
%         if round((GO_markEnd_ts(iEndMark) - GO_markStart_ts(iStartMark)) / 0.005) == 0; continue; end
%         trialCount = round((GO_markEnd_ts(iEndMark) - GO_markStart_ts(iStartMark)) / 0.005);
%         if trialCount > trials_to_search_for_startMark; continue; end      % guard against accidentally having two widely separated trials accidentally dividing evenly by 0.005
%         if abs(trialCount * 0.005 - (GO_markEnd_ts(iEndMark) - GO_markStart_ts(iStartMark))) < timingTolerance
% %         if rem(GO_markEnd_ts(iEndMark) - GO_markStart_ts(iStartMark), 0.005) < timingTolerance
%             GO_startIdx = iStartMark; 
%             GO_endIdx = iEndMark;
%             exitLoop = true;
%             break;
%         end
%     end
%     if exitLoop; break; end
% end

%look for a sequeunce of trials, use the first as the starting index
GO_startIdx = strfind(round((GO_markEnd_ts-GO_markStart_ts)/.005),[1 2 3 4]);
%why are there two Idxs? is this legacy for some system that had these
%times on different rows or something?
if isempty(GO_startIdx)
    error('Could not find trial start sequence.');
else
    GO_endIdx = GO_startIdx;
end


% sometimes, there is a pulse on the GO trial marker when the behavior vi
% is turned on. Keep this from being counted as a trial.
% GO_markDuration = GO_markEnd_ts(1:numTrials) - ...
%                   GO_markStart_ts(1:numTrials);
% if round(GO_markDuration(1) / 0.005) == 0
%     GO_markEnd_ts = GO_markEnd_ts(2:end);
%     GO_markStart_ts = GO_markStart_ts(2:end);
%     GO_markDuration = GO_markDuration(2:end);
% end

% GO_markDuration = GO_markEnd_ts(1:numTrials) - ...
%                   GO_markStart_ts(1:numTrials);

% now, loop through the trials and make sure that the .log data match with
% the .box data

% find the first .log trial that matches with the first .box trial (in case
% the recording was started after the rat already ran a few trials). The
% recording was set up so that the duration of the trial marker pulse is
% 5 ms times the trial number.
firstMarkDuration = GO_markEnd_ts(GO_endIdx) - GO_markStart_ts(GO_startIdx);
first_logTrialIdx = round(firstMarkDuration / 0.005);

numTrials = min([length(GO_markEnd_ts) - GO_endIdx + 1, ...
                 length(GO_markStart_ts) - GO_startIdx + 1, ...
                 length(logData.RT) - first_logTrialIdx + 1]);
lastEndIdx = GO_endIdx + numTrials - 1;
lastStartIdx = GO_startIdx + numTrials - 1;
GO_markDuration = GO_markEnd_ts(GO_endIdx:lastEndIdx) - GO_markStart_ts(GO_startIdx:lastStartIdx);
trialInterval = zeros(1, 2);
for iTrial = 1 : numTrials
%     disp(num2str(iTrial));
    
    logTrialIdx = iTrial + first_logTrialIdx - 1;
    
    % first, find all behavioral events that occur after the GO trial
    % marker for this trial, but before the GO trial marker for the next
    % trial
    trialInterval(1) = GO_markStart_ts(GO_startIdx + iTrial - 1);
    if iTrial == numTrials
%     if iTrial == length(GO_markStart_ts)
        trialInterval(2) = 0;
    else
        trialInterval(2) = GO_markStart_ts(GO_startIdx + iTrial);
    end
    logTrial = getSingleLogTrial(logData, logTrialIdx);
%     logTrial.responseDurationLimit = logTrial.responseDurationLimit / 1000;   % take this out after debugging
    trials(iTrial) = extractSingleTrial(events, ...
                                        logTrial, ...
                                        trialInterval, ...
                                        timingTolerance);
    
end

end   % function trials = createTrialsStruct_simpleChoice( logData, nexData )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logTrial = getSingleLogTrial(logData, logTrialIdx)
%
% usage: 
%
% INPUTS:
%
% OUTPUTS:
%

logTrial.fileVersion = logData.fileVersion;
logTrial.taskID = logData.taskID;
logTrial.taskVersion = logData.taskVersion;
logTrial.subject = logData.subject;
logTrial.date = logData.date;
logTrial.startTime = logData.startTime;
logTrial.comment = logData.comment;
logTrial.maxTrials = logData.maxTrials;
logTrial.maxRewards = logData.maxRewards;
logTrial.maxTime = logData.maxTime;
logTrial.toneDuration = logData.toneDuration;
logTrial.minInterTrial = logData.minInterTrial;
logTrial.maxInterTrial = logData.maxInterTrial;
logTrial.minPreTone = logData.minPreTone;
logTrial.maxPreTone = logData.maxPreTone;
logTrial.taskLevel = logData.taskLevel;
% logTrial.responseDurationLimit = logData.responseDurationLimit;
logTrial.Time = logData.Time(logTrialIdx);
logTrial.Attempt = logData.Attempt(logTrialIdx);
logTrial.Center = log2(logData.Center(logTrialIdx)) + 1;    % convert 2^n notation to 1-5 notation
logTrial.Target = log2(logData.Target(logTrialIdx)) + 1;
logTrial.Tone = logData.Tone(logTrialIdx);
logTrial.RT = logData.RT(logTrialIdx);
logTrial.MT = logData.MT(logTrialIdx);
logTrial.pretone = logData.pretone(logTrialIdx);
logTrial.outcome = logData.outcome(logTrialIdx);
logTrial.SideNP = log2(logData.SideNP(logTrialIdx)) + 1;

end    % function logTrial = getSingleLogTrial(logData, logTrialIdx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function eventIdx = getEventIdx( events, eventName )
%
% usage: eventIdx = getEventIdx( events, eventName )
%
% function to find the index of a nex event given the event name. Matching
% is case-insensitive.
%
% INPUTS:
%   events - events structure from a nex data structure, with fields:
%       .name - name of the event
%       .timestamps - list of timestamps (in seconds) of the events
%
% OUTPUT:
%   eventIdx - index of eventName in the list of events. Returns zero if
%       the event cannot be found

numEvents = length(events);
eventIdx  = 0;

for iEvent = 1 : numEvents
    
    if strcmpi(events{iEvent}.name, eventName)
        
        eventIdx = iEvent;
        break;
        
    end
    
end

end    % function eventIdx = getEventIdx( events, eventName )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function trialData = extractSingleTrial(events, logTrial, trialInterval, timingTolerance)
%
% usage:
%
% INPUTS:
%   trialEvents - 
%   logTrial - single trial from a logData structure
%   trialInterval - 2 element vector containing the start and end times for
%       the trial. If it's the last trial, trialInterval(2) = 0
%
% OUTPUT:
%   trialData - single element of a trials structure, as described at the
%       top of the main function

trialEvents = extractTrialEvents(events, trialInterval);

trialData.countsAsTrial = [];
trialData.valid = [];
trialData.trialType = 1;
trialData.holdTooLong = 0;
trialData.movementTooLong = 0;
trialData.timestamps.cueOn = 0;
trialData.falseStart = 0;
trialData.correct = 0;
trialData.invalidNP = 0;    % only for the initial nose-poke
trialData.tone = 0;
trialData.centerNP = 0;
trialData.movementDirection = 0;
trialData.sideNP = 0;
trialData.timing.pretone = 0;
trialData.logConflict.isConflict = 0;

boxLogConflicts.outcome = 0;
boxLogConflicts.RT = 0;
boxLogConflicts.MT = 0;
boxLogConflicts.pretone = 0;
boxLogConflicts.centerNP = 0;
boxLogConflicts.sideNP = 0;

trialData.logConflict.boxLogConflicts = boxLogConflicts;

% extract variable name indexes in the trialEvents structure
FHidx = getEventIdx(trialEvents, 'foodon');        % food hopper on
HLidx = getEventIdx(trialEvents, 'houselighton');  % houselight on
Tone1idx = getEventIdx(trialEvents, 'tone1On');    % tone 1
Tone2idx = getEventIdx(trialEvents, 'tone2On');    % tone 2
Cueidx(1) = getEventIdx(trialEvents, 'cue1On');    % Cue 1
Cueidx(2) = getEventIdx(trialEvents, 'cue2On');    % Cue 2
Cueidx(3) = getEventIdx(trialEvents, 'cue3On');    % Cue 3
Cueidx(4) = getEventIdx(trialEvents, 'cue4On');    % Cue 4
Cueidx(5) = getEventIdx(trialEvents, 'cue5On');    % Cue 5

NoseInidx(1) = getEventIdx(trialEvents, 'nose1In');      % NoseIn 1
NoseInidx(2) = getEventIdx(trialEvents, 'nose2In');      % NoseIn 2
NoseInidx(3) = getEventIdx(trialEvents, 'nose3In');      % NoseIn 3
NoseInidx(4) = getEventIdx(trialEvents, 'nose4In');      % NoseIn 4
NoseInidx(5) = getEventIdx(trialEvents, 'nose5In');      % NoseIn 5

NoseOutidx(1) = getEventIdx(trialEvents, 'nose1Out');      % NoseOut 1
NoseOutidx(2) = getEventIdx(trialEvents, 'nose2Out');      % NoseOut 2
NoseOutidx(3) = getEventIdx(trialEvents, 'nose3Out');      % NoseOut 3
NoseOutidx(4) = getEventIdx(trialEvents, 'nose4Out');      % NoseOut 4
NoseOutidx(5) = getEventIdx(trialEvents, 'nose5Out');      % NoseOut 5

FoodSensidx = getEventIdx(trialEvents, 'foodporton');     % the sensor on the food port

% figure out which cues were lit when, and which nose pokes were poked when
CueTS = [];
NoseInTS = [];
CueID = [];
NoseInID = [];
NoseOutTS = [];
NoseOutID = [];
for iCue = 1 : 5
    if Cueidx(iCue) > 0
        CueTS = [CueTS, trialEvents{Cueidx(iCue)}.timestamps];
        if ~isempty(trialEvents{Cueidx(iCue)}.timestamps)
            CueID = [CueID, ones(1, size(trialEvents{Cueidx(iCue)}.timestamps, 2)) * iCue];
        end    % end if ~isempty...
    end   % end if Cueidx...
end
[CueTS, Cue_idx] = sort(CueTS);
CueID = CueID(Cue_idx);
if isempty(CueTS)    % this is a wrong start trial where the wrong start happened before the center cue was even lit
    trialData.correct = 0;
    trialData.timestamps.cueOn = 0;
    trialData.centerNP = 0;
    trialData.countsAsTrial = 0;
    trialData.valid = 0;
    trialData.invalidNP = 1;
    trialData.movementTooLong = 0;
    trialData.falseStart = 0;

    boxLogConflicts.outcome = ~(logTrial.outcome == 3);
    isConflict = boxLogConflicts.outcome;

    trialData.logConflict.isConflict = isConflict;
    trialData.logConflict.boxLogConflicts = boxLogConflicts;

    return;
end
    
for iCue = 1 : 5
    if NoseInidx(iCue) > 0
        NoseInTS = [NoseInTS, trialEvents{NoseInidx(iCue)}.timestamps(trialEvents{NoseInidx(iCue)}.timestamps > CueTS(1))];
        if ~isempty(trialEvents{NoseInidx(iCue)}.timestamps)
            NoseInID = [NoseInID, ones(1, size(trialEvents{NoseInidx(iCue)}.timestamps, 2)) * iCue];
        end   % end if ~isempty...
    end   % end if NoseInidx...
    if NoseOutidx(iCue) > 0
        NoseOutTS = [NoseOutTS, trialEvents{NoseOutidx(iCue)}.timestamps(trialEvents{NoseOutidx(iCue)}.timestamps > CueTS(1))];
        if ~isempty(trialEvents{NoseOutidx(iCue)}.timestamps)
            NoseOutID = [NoseOutID, ones(1, size(trialEvents{NoseOutidx(iCue)}.timestamps, 2)) * iCue];
        end   % end if ~isempty...
    end    % end if NoseOutidx...

end   % end for iCue


[NoseInTS, NoseIn_idx] = sort(NoseInTS);
NoseInID = NoseInID(NoseIn_idx);
[NoseOutTS, NoseOut_idx] = sort(NoseOutTS);
NoseOutID = NoseOutID(NoseOut_idx);
   
% sometimes if the rat still had its nose in the port when the next
% trial starts, there is no nose-in event for that trial. If that
% happens, assign nose-in time to be the start of the trial
nose_out_event = 1;
if isempty(NoseInTS)
    NoseInTS = trialInterval(1);
    % figure out which port the rat had its nose in to start
    nose_out_event = 0;
    for iCue = 1 : 5
        if NoseOutidx(iCue) > 0
            if ~isempty(trialEvents{NoseOutidx(iCue)}.timestamps)
                NoseInID = iCue;
                nose_out_event = 1;
            end
        end
    end
            
end

if ~nose_out_event    % there was no nose-in event or nose-out event; this must have been the last trial and it wasn't completed
    return;
end

if ~isempty(trialEvents{Tone1idx}.timestamps)
    tone_ts = trialEvents{Tone1idx}.timestamps(1);
elseif ~isempty(trialEvents{Tone2idx}.timestamps)
    tone_ts = trialEvents{Tone2idx}.timestamps(1);
else
    tone_ts = [];
end

if NoseInTS(1) > tone_ts    % the first nose-in can only occur after the tone if the rat started in the correct center port before the cue was lit
    NoseInTS = [CueTS(1), NoseInTS];
    NoseInID = [CueID(1), NoseInID];
end
    
if ~isempty(trialEvents{FHidx}.timestamps) & (~isempty(trialEvents{Tone1idx}.timestamps) || ~isempty(trialEvents{Tone2idx}.timestamps))
    % this was a correct trial because the food hopper was activated
    trialData.countsAsTrial = 1;
    trialData.valid = 1;
    trialData.movementTooLong = 0;
    trialData.falseStart = 0;
    trialData.correct = 1;
    trialData.invalidNP = 0;
    
    trialData.timestamps.cueOn = CueTS(1);
    trialData.centerNP = CueID(1);
    trialData.timestamps.centerIn = NoseInTS(1);
    trialData.timestamps.centerOut = ...
        events{NoseOutidx(CueID(1))}.timestamps(events{NoseOutidx(CueID(1))}.timestamps > NoseInTS(1));
    trialData.timestamps.centerOut = trialData.timestamps.centerOut(1);
    % above line written this way to ensure that a nose-out left over from
    % a previous trial is not counted as the nose-out for this trial
    
    trialData.timestamps.tone = tone_ts;
    if isempty(trialEvents{Tone1idx}.timestamps)
        % tone 2 (high tone) was played
        trialData.tone = 2;
%         trialData.timestamps.tone = trialEvents{Tone2idx}.timestamps(1);
        trialData.sideNP = trialData.centerNP + 1;   % this is the port
                                                     % that the rat
                                                     % actually entered;
                                                     % NOT necessarily the
                                                     % target port (well,
                                                     % it is for correct
                                                     % trials)
        trialData.movementDirection = 2;             % moved right
        sideInAfterCue = trialEvents{NoseInidx(CueID(1) + 1)}.timestamps(trialEvents{NoseInidx(CueID(1) + 1)}.timestamps > CueTS(1));
        trialData.timestamps.sideIn = sideInAfterCue(1);
        trialData.timestamps.sideOut = ...
            events{NoseOutidx(CueID(1) + 1)}.timestamps(events{NoseOutidx(CueID(1) + 1)}.timestamps > NoseInTS(1));
        trialData.timestamps.sideOut = trialData.timestamps.sideOut(1);
        % done this way to prevent the algorithm from counting a nose-out
        % event that may be left over from a previous trial
    else
        % tone 1 (low tone) was played
        trialData.tone = 1;
%         trialData.timestamps.tone = trialEvents{Tone1idx}.timestamps(1);
        trialData.sideNP = trialData.centerNP - 1;
        trialData.movementDirection = 1;
        sideInAfterCue = trialEvents{NoseInidx(CueID(1) - 1)}.timestamps(trialEvents{NoseInidx(CueID(1) - 1)}.timestamps > CueTS(1));
        trialData.timestamps.sideIn = sideInAfterCue(1);
        trialData.timestamps.sideOut = ...
            events{NoseOutidx(CueID(1) - 1)}.timestamps(events{NoseOutidx(CueID(1) - 1)}.timestamps > NoseInTS(1));
        trialData.timestamps.sideOut = trialData.timestamps.sideOut(1);
        % done this way to prevent the algorithm from counting a nose-out
        % event that may be left over from a previous trial
    end    % end if isempty(trialEvents{Tone1idx}.timestamps)
    
    trialData.timestamps.foodClick = trialEvents{FHidx}.timestamps;
    
    % calculate timing of events within the trial
    trialData.timing.pretone = trialData.timestamps.tone - ...
        trialData.timestamps.centerIn;
    trialData.timing.RT = trialData.timestamps.centerOut - ...
        trialData.timestamps.tone;
    trialData.timing.MT = trialData.timestamps.sideIn - ...
        trialData.timestamps.centerOut;
    trialData.timing.foodDelay = trialData.timestamps.foodClick - ...
        trialData.timestamps.sideIn;
    trialData.timing.sidePortHold = trialData.timestamps.sideOut - ...
        trialData.timestamps.sideIn;
    
    % extract the FIRST time the rat went into the reward port. This is a
    % bit tricky because this may occur AFTER the next trial started
    % depending on how the behavior software was running and if the food
    % port sensor was working at all
    
    if FoodSensidx ~= 0         % the food port sensor was working
        firstFoodRetrieval = find(events{FoodSensidx}.timestamps > ...
            trialData.timestamps.sideIn);
        if ~isempty(firstFoodRetrieval)
            trialData.timestamps.foodRetrieval = events{FoodSensidx}.timestamps(firstFoodRetrieval(1));
            trialData.timing.foodRetrieval = trialData.timestamps.foodRetrieval - ...
                trialData.timestamps.foodClick;
        else
            trialData.timestamps.foodRetrieval = 0;   % presumably, port sensor was broken for this session
            trialData.timing.foodRetrieval = 0;
        end    % end if ~isempty...
    
    else
        trialData.timestamps.foodRetrieval = 0;   % presumably, port sensor was broken for this session
        trialData.timing.foodRetrieval = 0;
    end    % FoodSensidx ~= 0  
    
    % check that outcome was correct, RT, MT, pre-tone intervalS, center
    % and target ports match up
    boxLogConflicts.outcome = ~(logTrial.outcome == 0);
    boxLogConflicts.RT = ~(abs(logTrial.RT - trialData.timing.RT) < timingTolerance);
    boxLogConflicts.MT = ~(abs(logTrial.MT - trialData.timing.MT) < timingTolerance);
    boxLogConflicts.pretone = ~(abs(logTrial.pretone - trialData.timing.pretone) < timingTolerance);
    boxLogConflicts.centerNP = ~(logTrial.Center == trialData.centerNP);
    boxLogConflicts.sideNP = ~(logTrial.Target == trialData.sideNP);
    isConflict = boxLogConflicts.outcome | ...
                 boxLogConflicts.RT | ...
                 boxLogConflicts.MT | ...
                 boxLogConflicts.pretone | ...
                 boxLogConflicts.centerNP | ...
                 boxLogConflicts.sideNP;
    
    trialData.logConflict.isConflict = isConflict;
    trialData.logConflict.boxLogConflicts = boxLogConflicts;
    
else
    % this was an incorrect trial; need to figure out why
    trialData.correct = 0;
    trialData.timestamps.cueOn = CueTS(1);    
    trialData.centerNP = CueID(1);
    if ~isempty(trialEvents{HLidx}.timestamps)
        trialData.timestamps.houseLightOn = trialEvents{HLidx}.timestamps(1);
    end

    trialData.timestamps.centerIn = NoseInTS(1);
  %  trialData.timestamps.wrong = trialEvents{HLidx}.timestamps;


    % patch 3/29/2010. First, check to see if the rat started with its nose
    % in a port at the start of the trial. If so, counts as a false start
    % instead of a "wrong start"
    if ~isempty(NoseOutTS)
        % rarely, the rat did not pull its nose out of the initial port at
        % all until after the next trial started
        trialData.countsAsTrial = 0;
        trialData.valid = 0;

        %%%%%%%%%%CONTINUE WORKING HERE - THE NEXT FEW LINES WILL NEED SOME
        %%%%%%%%%%MODIFICATION IN THE NEW STRUCTURE
        if (NoseOutTS(1) < NoseInTS(1)) || ...
           (NoseInTS(1) == trialInterval(1)) || ...
           (NoseInTS(1) < CueTS(1))     % the rat pulled its nose out BEFORE
                                        % it put its nose in, OR no
                                        % nose-in was found at the
                                        % beginning of this function,
                                        % and NoseInTS(1) was reset to
                                        % the trial start time OR
                                        % the rat poked a port after the trial
                                        % started, but before the cue light
                                        % came on
            trialData.countsAsTrial = 0;
            trialData.valid = 0;
            trialData.invalidNP = 0;
            trialData.movementTooLong = 0;
            trialData.falseStart = 1;

            trialData.timestamps.centerOut = NoseOutTS(1);
            trialData.timing.wrongAnswerDelay = trialEvents{HLidx}.timestamps(1) - ...
                NoseOutTS(1);

            boxLogConflicts.outcome = ~(logTrial.outcome == 1);

            trialData.logConflict.isConflict = boxLogConflicts.outcome;
            trialData.logConflict.boxLogConflicts = boxLogConflicts;

            return;

        end
    end

    % check to see if the rat poked the wrong center port
    if trialData.centerNP ~= NoseInID(1)
        % wrong start trial
        trialData.countsAsTrial = 0;
        trialData.valid = 0;
        trialData.invalidNP = 1;
        trialData.movementTooLong = 0;
        trialData.falseStart = 0;

        % a bit of caution extracting the centerOut time, as this may
        % actually occur after the next trial has started
        noseOut = events{NoseOutidx(NoseInID(1))}.timestamps - trialInterval(1);
        trialData.timestamps.centerOut = min(noseOut(noseOut > 0));
        % I don't know what this is, it throws an error -Matt 20160110
%         trialData.timing.wrongAnswerDelay = trialEvents{HLidx}.timestamps(1) - ...
%             trialData.timestamps.centerIn;

        boxLogConflicts.outcome = ~(logTrial.outcome == 3);
        isConflict = boxLogConflicts.outcome;

        trialData.logConflict.isConflict = isConflict;
        trialData.logConflict.boxLogConflicts = boxLogConflicts;

        return;

    end    % end if trialData.centerNP ~= NoseInTS(1)

    % check to see if the rat left the center port before the tone played
    % (false start)
    % do this by checking to see if the tone played
    if isempty(trialEvents{Tone1idx}.timestamps) && isempty(trialEvents{Tone2idx}.timestamps)
        % neither tone played; this must have been a false start
        trialData.countsAsTrial = 0;
        trialData.valid = 0;
        trialData.invalidNP = 0;
        trialData.movementTooLong = 0;
        trialData.falseStart = 1;

        trialData.timestamps.centerOut = ...
            events{NoseOutidx(CueID(1))}.timestamps(events{NoseOutidx(CueID(1))}.timestamps > NoseInTS(1));
        trialData.timestamps.centerOut = trialData.timestamps.centerOut(1);

        trialData.timing.wrongAnswerDelay = trialEvents{HLidx}.timestamps - ...
            trialData.timestamps.centerOut;

        boxLogConflicts.outcome = ~(logTrial.outcome == 1);
        isConflict = boxLogConflicts.outcome;

        trialData.logConflict.isConflict = isConflict;
        trialData.logConflict.boxLogConflicts = boxLogConflicts;

        return;
    end    % end if isempty(trialEvents...

    % record the timing of the tone playing, and which tone played
    trialData.timestamps.tone = tone_ts;
    if isempty(trialEvents{Tone1idx}.timestamps)
        % tone 2 (high tone) was played
        trialData.tone = 2;
%         trialData.timestamps.tone = trialEvents{Tone2idx}.timestamps;
    else
        % tone 1 (low tone) was played
        trialData.tone = 1;
%         trialData.timestamps.tone = trialEvents{Tone1idx}.timestamps;
    end    % end if isempty(trialEvents{Tone1idx}.timestamps)

    trialData.timing.pretone = trialData.timestamps.tone - ...
        trialData.timestamps.centerIn;

    % check to see if this was a limited hold violation.
    % THIS CHECK IS DIFFERENT FROM THE ALGORITHM TO EXTRACT INDIVIDUAL
    % TRIAL DATA FROM THE .BOX.NEX FILE ALONE. CHECK TO SEE IF NOSE-OUT
    % TIMESTAMP WAS BEFORE LIMITED HOLD EXPIRED -DL 3/28/2010


    trialData.timestamps.centerOut = ...
        events{NoseOutidx(CueID(1))}.timestamps(events{NoseOutidx(CueID(1))}.timestamps > NoseInTS(1));
    trialData.timestamps.centerOut = trialData.timestamps.centerOut(1);
    trialData.timing.reactionTime = ...
        trialData.timestamps.centerOut - trialData.timestamps.tone;

%     if trialData.timing.reactionTime > logTrial.responseDurationLimit
%         % nose-out occurred after limited hold expired.
%         trialData.countsAsTrial = 1;
%         trialData.valid = 1;
%         trialData.invalidNP = 0;
%         trialData.holdTooLong = 1;
%         trialData.movementTooLong = 0;
%         trialData.falseStart = 0;
% 
%         trialData.timing.wrongAnswerDelay = ...
%             trialEvents{HLidx}.timestamps - ...
%             (trialData.timestamps.tone + logTrial.responseDurationLimit);
% 
%         % check that outcome, center port, and pre-tone interval match with .log file
%         boxLogConflicts.outcome = ~(logTrial.outcome == 4);
%         boxLogConflicts.centerNP = ~(logTrial.Center == trialData.centerNP);
%         boxLogConflicts.pretone = ~(abs(logTrial.pretone - trialData.timing.pretone) < timingTolerance);
% 
%         trialData.logConflict.isConflict = boxLogConflicts.outcome | ...
%                                            boxLogConflicts.centerNP | ...
%                                            boxLogConflicts.pretone;
%         trialData.logConflict.boxLogConflicts = boxLogConflicts;
%         return;
% 
%     end    % end if trialData.timing.reactionTime > logTrial.responseDurationLimit



% not a limited hold violation - did the rat poke a side port in time?
% THIS IS DIFFERENT FROM EXTRACTING GO TRIAL DATA EXCLUSIVELY FROM THE
% .BOX.NEX FILE. CHECK TO SEE IF MOVEMENT TIME WAS GREATER THAN 
% MOVEMENT HOLD (if the side poke occurred at all). -DL 3-28-2010


    if max(size(NoseInTS)) > 1
        trialData.timing.movementTime = ...
            NoseInTS(2) - trialData.timestamps.centerOut;
    end
    if (max(size(NoseInTS))) == 1

        trialData.countsAsTrial = 1;
        trialData.valid = 1;
        trialData.invalidNP = 0;
        trialData.holdTooLong = 0;
        trialData.movementTooLong = 1;
        trialData.falseStart = 0;


%         trialData.timing.wrongAnswerDelay = ...
%             trialEvents{HLidx}.timestamps - ...
%             (trialData.timestamps.tone + logTrial.responseDurationLimit);

        % check that outcome was movement hold violation, RT, pre-tone interval,
        % center ports match up
        boxLogConflicts.outcome = ~(logTrial.outcome == 6);
        boxLogConflicts.RT = ~(abs(logTrial.RT - trialData.timing.reactionTime) < timingTolerance);
        boxLogConflicts.pretone = ~(abs(logTrial.pretone - trialData.timing.pretone) < timingTolerance);
        boxLogConflicts.centerNP = ~(logTrial.Center == trialData.centerNP);

        trialData.logConflict.isConflict = boxLogConflicts.outcome | ...
                                           boxLogConflicts.RT | ...
                                           boxLogConflicts.pretone | ...
                                           boxLogConflicts.centerNP;
        trialData.logConflict.boxLogConflicts = boxLogConflicts;

        return;

    end    % end if max(size(NoseInTS...
    
    % this must have been a wrong port trial
    trialData.countsAsTrial = 1;
    trialData.valid = 1;
    trialData.invalidNP = 0;
    trialData.holdTooLong = 0;
    trialData.movementTooLong = 0;
    trialData.falseStart = 0;
    
    % figure out which port was actually poked
    trialData.sideNP = NoseInID(2);
    if trialData.sideNP > trialData.centerNP
        trialData.movementDirection = 2;
    else
        trialData.movementDirection = 1;
    end    % end if trialData.sideNP
    
    trialData.timestamps.sideIn = NoseInTS(2);
    trialData.timestamps.sideOut = ...
        min(events{NoseOutidx(trialData.sideNP)}.timestamps(events{NoseOutidx(trialData.sideNP)}.timestamps > NoseInTS(2)));
    if ~isempty(trialData.timestamps.sideOut)
        % on a wrong target trial (where the rat moves the wrong direction,
        % but no limited hold violation), the rat may still have its nose
        % in the side port when the next trial starts. Actually, this is
        % pretty unlikely.
        trialData.timestamps.sideOut = trialData.timestamps.sideOut(1);
    end    % end if ~isempty...
    trialData.timestamps.wrong = trialData.timestamps.sideIn;
    % assumes nose-out event occurred before houselight went off
    
    trialData.timing.movementTime = trialData.timestamps.sideIn - ...
        trialData.timestamps.centerOut;
    trialData.timing.sidePortHold = trialData.timestamps.sideOut - ...
        trialData.timestamps.sideIn;
    trialData.timing.wrongAnswerDelay = trialEvents{HLidx}.timestamps - ...
        trialData.timestamps.sideIn;
    
    % check that outcome was wrong target, RT, MT, pre-tone intervalS, center
    % and target ports match up (that is, are off by 2)
    boxLogConflicts.outcome = ~(logTrial.outcome == 5);
    boxLogConlicts.RT = ~(abs(logTrial.RT - trialData.timing.reactionTime) < timingTolerance);
    boxLogConflicts.MT = ~(abs(logTrial.MT - trialData.timing.movementTime) < timingTolerance);
    boxLogConflicts.pretone = ~(abs(logTrial.pretone - trialData.timing.pretone) < timingTolerance);
    boxLogConflicts.centerNP = ~(logTrial.Center == trialData.centerNP);
    boxLogConflicts.sideNP = ~(logTrial.SideNP == trialData.sideNP);
    
    trialData.logConflict.isConflict = boxLogConflicts.outcome | ...
                                       boxLogConlicts.RT | ...
                                       boxLogConflicts.MT | ...
                                       boxLogConflicts.pretone | ...
                                       boxLogConflicts.centerNP | ...
                                       boxLogConflicts.sideNP;
    trialData.logConflict.boxLogConflicts = boxLogConflicts; 


end   % end if ~isempty(trialEvents{FHidx}.timestamps)

end