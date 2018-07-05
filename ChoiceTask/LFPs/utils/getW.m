function [W,freqList,allTimes,allTrialIds,LFP] = getW(sevFile,curTrials,eventFieldnames,freqList,sortBy)
if ~exist('sortBy')
    sortBy = 'RT';
end
decimateFactor = 10;
% % fpass = [1 100];
% % freqList = logFreqList(fpass,30);
tWindow = [1,2];

[sev,header] = read_tdt_sev(sevFile);
sevDec = decimate(double(sev),decimateFactor);
Fs = header.Fs / decimateFactor;

% % Fc = [1 200];
% % Wn = Fc ./ (Fs/2);
% % [b,a] = butter(4,Wn);
% % sevFilt_lfp = filtfilt(b,a,sevFilt);

if isempty(sortBy)
    useTrials = curTrials;
    allTrialIds = 1:numel(curTrials);
    allTimes = [];
elseif strcmp(sortBy,'RT') || strcmp(sortBy,'MT')
    [trialIds,allTimes] = sortTrialsBy(curTrials,sortBy);
    useTrials = curTrials(trialIds);
    allTrialIds = trialIds;
else
    [trialIdsRT,allTimesRT] = sortTrialsBy(curTrials,'RT');
    useTrials = curTrials(trialIdsRT);
    [trialIdsMT,allTimesMT] = sortTrialsBy(curTrials,'MT');
    allTimes = [allTimesRT;allTimesMT];
    allTrialIds = [trialIdsRT;trialIdsMT];
end
[W,LFP] = eventsLFPv2(useTrials,sevDec,tWindow,Fs,freqList,eventFieldnames);