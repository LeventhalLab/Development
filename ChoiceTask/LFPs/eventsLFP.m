function allW = eventsLFP(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)
tWindowSamples = round(Fs * tWindow);
doDebug = false;

allW = [];
newFig = true;
for iField=1:numel(eventFieldnames)
    data = [];
    for iTrial=1:numel(trials)
        centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        centerSample = round(centerTs*Fs);
        centerRangeSamples = (centerSample - tWindowSamples):(centerSample + tWindowSamples - 1);
        if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFilt)
            lfp = sevFilt(centerRangeSamples);
            if doDebug
%                 simpleFFT(lfp,Fs,'newFig',newFig);
%                 newFig = false;
            end
            data(:,iTrial) = lfp;
        end
    end
    if doDebug
        simpleFFT(mean(data,2)',Fs,'newFig',true);
    end
    allW(iField,:,:,:) = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList,'doplot',doDebug);
end