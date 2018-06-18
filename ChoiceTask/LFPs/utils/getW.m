function [W,freqList,allTimes,allTrialIds] = getW(sevFile,curTrials,eventFieldnames,freqList,sortBy)
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
    allTrialIds = 1:numel(curTrials);
    allTimes = [];
elseif strcmp(sortBy,'RT') || strcmp(sortBy,'MT')
    [trialIds,allTimes] = sortTrialsBy(curTrials,sortBy);
    useTrials = curTrials(trialIds);
    allTrialIds = trialsIds;
else
    [trialIdsRT,allTimesRT] = sortTrialsBy(curTrials,'RT');
    useTrials = curTrials(trialIdsRT);
    [trialIdsMT,allTimesMT] = sortTrialsBy(curTrials,'MT');
    allTimes = [allTimesRT;allTimesMT];
    allTrialIds = [trialIdsRT;trialIdsMT];
end
W = eventsLFP(useTrials,sevFilt,tWindow,Fs,freqList,eventFieldnames);