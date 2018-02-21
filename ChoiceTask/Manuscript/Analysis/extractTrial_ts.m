function [ trial_ts ] = extractTrial_ts( ts, trials, onlyCorrect )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% make sure ts is a column vector
if size(ts,2) == length(ts)
    ts = ts';
end

trialWindow = [0,1]; % time before and after each trial to extract
trialTimes = zeros(length(trials),2);
trial_ts = [];
for iTrial = 1 : length(trials)
    tr = trials(iTrial);
    if onlyCorrect
        if ~tr.correct; continue; end
    end
    trialTimes(iTrial,1) = tr.timestamps.centerIn - trialWindow(1);
    
    % find latest trial time
    eventNames = fieldnames(tr.timestamps);
    possTimes = zeros(1,length(eventNames));
    for iEvent = 1 : length(eventNames)
        try
            possTimes(iEvent) = tr.timestamps.(eventNames{iEvent});
        catch
        end
    end
    trialTimes(iTrial,2) = max(possTimes);
    
    trial_ts = [trial_ts;ts((ts > trialTimes(iTrial,1)) & ts < (trialTimes(iTrial,2)))];
end

