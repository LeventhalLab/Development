function [ event_ts ] = extractEvent_ts( eventName, trials, onlyCorrect )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


event_ts = [];
for iTrial = 1 : length(trials)
    tr = trials(iTrial);
    if onlyCorrect
        if ~tr.correct; continue; end
    end
    
    if isfield(tr.timestamps, eventName)
        event_ts = [event_ts; tr.timestamps.(eventName)];
    end

end

