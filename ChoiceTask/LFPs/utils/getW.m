function [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList)
decimateFactor = 10;
% % fpass = [1 100];
% % freqList = logFreqList(fpass,30);
tWindow = [1,2];

[sev,header] = read_tdt_sev(sevFile);
sevFilt = decimate(double(sev),decimateFactor);
Fs = header.Fs / decimateFactor;
[trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
W = eventsLFP(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);