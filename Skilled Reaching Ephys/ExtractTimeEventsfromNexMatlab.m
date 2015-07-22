%Titus John
%7/21/2015
%Leventhal Lab, University of Michigan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% TTL/Event Breakdown 

% EventlineNum         TTL
% 33                    TTL1on actuator pos 1(all the way down)
% 34                    TTL1off actuator pos 1(all the way down)
% 41                    TTL2on actuator pos 2(pellet loaded but not fully extended)
% 42                    TTL2on actuator pos 2(pellet loaded but not fully extended)
% 7                     TTL3on actuator pos 3(pellet all the way up after triggered by ir)
% 8                     TTL3off actuator pos 3(pellet all the way up after triggered by ir)
% 9                     TTL4on Back IR sensor triggered
% 10                    TTL4off Back IR sensor triggered
% 43                    TTL5on Frame Triggered
% 44                    TTL5off
% 25                    TTL6on GreenVideo Trigger
% 26                    TTL6on GreenVideo Trigger

%% Order of Events for the reach possibilities
%True Reach - TTL1on,TTL2on,TTL4on,TTL6


%%
function allTTLTs = ExtractTimeEventsfromNexMatlab(NexMatStruct)

    timeArrayMatrix = [];

    events = NexMatStruct.events;
    
    %Timestamps for the TTL signals
    TTL1onTS = events{33,1}.timestamps;
    TTL1offTS = events{34,1}.timestamps;
    
    TTL2onTS = events{41,1}.timestamps;
    TTL2offTS = events{42,1}.timestamps;
    
    
    TTL3onTS = events{7,1}.timestamps;
    TTL3offTS = events{8,1}.timestamps;
    
    
    TTL4onTS = events{9,1}.timestamps;
    TTL4offTS = events{10,1}.timestamps;
    
    
    TTL5onTS = events{43,1}.timestamps;
    TTL5offTS = events{44,1}.timestamps;
     
    TTL6onTS = events{25,1}.timestamps;
    TTL6offTS = events{26,1}.timestamps;
    
    
    allTTLTs = padcat(TTL1onTS,TTL2onTS,TTL3onTS,TTL4onTS,TTL6onTS);
    
    
end


