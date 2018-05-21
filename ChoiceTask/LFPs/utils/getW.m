function [W,freqList] = getW(sevFile,curTrials,eventFieldnames)
decimateFactor = 10;
fpass = [1 100];
freqList = logFreqList(fpass,30);
tWindow = [1,2];

disp(sevFile);
[sev,header] = read_tdt_sev(sevFile);
sevFilt = decimate(double(sev),decimateFactor);
Fs = header.Fs / decimateFactor;
trialIds = sortTrialsBy(curTrials,'RT');
W = eventsLFP(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);