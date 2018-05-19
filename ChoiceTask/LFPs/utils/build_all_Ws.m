function [all_Ws,freqList] = build_all_Ws(LFPfiles,all_trials,eventFieldnames)
decimateFactor = 10;
fpass = [1 100];
freqList = logFreqList(fpass,30);
tWindow = 1;

all_Ws = {};
for iFile = 1:numel(LFPfiles)
    disp(LFPfiles{iFile});
    sevFile = LFPfiles{iFile};
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    
    curTrials = all_trials{iFile};
    trialIds = sortTrialsBy(curTrials,'RT');
    allW = eventsLFP(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    all_Ws{iNeuron} = allW;
end
