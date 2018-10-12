function [ spikeHist ] = getTrialHist( spike_ts,event_ts,histBins )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

spikeHist = zeros(length(event_ts), length(histBins)-1);
for i_eventTS = 1 : length(event_ts)
    
    a = tsPeth(spike_ts,event_ts(i_eventTS),max(histBins));
    if ~isempty(a)
        spikeHist(i_eventTS,:) = histcounts(a,histBins);
    end
end

