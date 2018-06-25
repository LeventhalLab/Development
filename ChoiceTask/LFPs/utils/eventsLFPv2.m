function all_LFP = eventsLFPv2(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)
nLoop = 1;
if iscell(freqList)
    nLoop = size(freqList{:},1);
end

tWindow_samples = round(Fs * tWindow);
tWindow_oversamples = tWindow_samples * 2;

all_LFP = [];
for iFreq = 1:nLoop
    if iscell(freqList) & ~isnan(freqList{:}(iFreq,:)) %#ok<AND2>
        Fc = freqList{:}(iFreq,:);
        Wn = Fc ./ (Fs/2);
        [b,a] = butter(4,Wn);
        sevFiltFilt = hilbert(filtfilt(b,a,sevFilt));
    else
        sevFiltFilt = sevFilt; % non-analytic
    end
    for iField = 1:numel(eventFieldnames)
        data = [];
        for iTrial = 1:numel(trials)
            try
                centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
                centerSample = round(centerTs*Fs);
                centerRangeSamples = (centerSample - tWindow_oversamples):(centerSample + tWindow_oversamples - 1);
                if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFiltFilt)
                    lfp = sevFiltFilt(centerRangeSamples);
                end
            catch % for trials without all events
                centerRangeSamples = -tWindow_oversamples:tWindow_oversamples - 1;
                lfp = NaN(1,numel(centerRangeSamples));
            end
            data(:,iTrial) = lfp;
        end
        selectRange = (numel(lfp)/2) - round(tWindow_samples):(numel(lfp)/2) + round(tWindow_samples) - 1;
        
        if iscell(freqList)
            all_LFP(iField,:,:,iFreq) = data(selectRange,:);
        else
            W = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);
            all_LFP(iField,:,:,:) = W(selectRange,:,:);
        end
    end
end