function [allW,allLfp] = eventsLFP(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)
tWindowSamples = round(Fs * tWindow);
doDebug = false;

allW = [];
allLfp = [];
newFig = true;
for iField = 1:numel(eventFieldnames)
    data = [];
    for iTrial = 1:numel(trials)
        centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        centerSample = round(centerTs*Fs);
        centerRangeSamples = (centerSample - tWindowSamples):(centerSample + tWindowSamples - 1);
        if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFilt) % !!!shouldn't use iTrial below
            lfp = sevFilt(centerRangeSamples);
            if doDebug
                simpleFFT(lfp,Fs,'newFig',newFig);
% %                 newFig = false;
                title(iTrial);
            end
            data(:,iTrial) = lfp;
        end
    end
    allLfp(iField,:,:) = data;
    allW(iField,:,:,:) = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList,'doplot',doDebug);
end