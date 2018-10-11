function [ randHist ] = calcRandomHist( ts,tWin,endTs,histBins,numRandomHists )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

rand_ts = tWin + (rand(numRandomHists,1) * endTs - 2*tWin);
randHist = zeros(numRandomHists, length(histBins)-1);
for ii = 1 : numRandomHists
    a = tsPeth(ts,rand_ts(ii),max(histBins));
    if ~isempty(a)
        randHist(ii,:) = histcounts(a,histBins);%[hist_ts,a];
    end
end

% if length(hist_ts) > 1;hist_ts = hist_ts(1:end-1);end
% 
% randHist = histcounts(hist_ts,histBins);