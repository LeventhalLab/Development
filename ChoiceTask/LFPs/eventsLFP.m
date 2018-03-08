function allW = eventsLFP(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)
tWindowSamples = round(Fs * tWindow);

allW = [];
for iField=1:numel(eventFieldnames)
    data = [];
    for iTrial=1:numel(trials)
        centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        centerSample = round(centerTs*Fs);
        centerRangeSamples = (centerSample - tWindowSamples):(centerSample + tWindowSamples - 1);
        if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFilt)
            lfp = sevFilt(centerRangeSamples);
            data(:,iTrial) = lfp;
        end
    end
    allW(iField,:,:,:) = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);
end