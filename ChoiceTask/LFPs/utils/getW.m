function [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList,sortBy)
if ~exist('sortBy')
    sortBy = 'RT';
end
decimateFactor = 10;
% % fpass = [1 100];
% % freqList = logFreqList(fpass,30);
tWindow = [1,2];

[sev,header] = read_tdt_sev(sevFile);
sevFilt = decimate(double(sev),decimateFactor);
Fs = header.Fs / decimateFactor;
if isempty(sortBy)
    useTrials = curTrials;
    allTimes = [];
else
    [trialIds,allTimes] = sortTrialsBy(curTrials,sortBy);
    useTrials = curTrials(trialIds);
end
W = eventsLFP(useTrials,sevFilt,tWindow,Fs,freqList,eventFieldnames);