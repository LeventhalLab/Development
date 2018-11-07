function [all_LFP,all_data] = eventsLFPv2(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)
eliminateData = 0;

nLoop = 1;
tWindow_samples = round(Fs * tWindow);
if iscell(freqList)
    nLoop = size(freqList{:},1);
    tWindow_oversamples = (tWindow_samples * 2) + (4 * round(Fs/min(freqList{:}(:))));
else
    tWindow_oversamples = (tWindow_samples * 2) + (4 * round(Fs/min(freqList)));
end
% +/- tWindow + edge based on lowest frequency


all_LFP = [];
for iFreq = 1:nLoop
    if iscell(freqList) & ~isnan(freqList{:}(iFreq,:)) %#ok<AND2>
        sevFiltFilt = eegfilt(sevFilt,Fs,freqList{:}(iFreq,1),freqList{:}(iFreq,2));
    else
        sevFiltFilt = sevFilt;
    end
    all_data = [];
    for iField = 1:numel(eventFieldnames)
        data = [];
        return_data = [];
        for iTrial = 1:numel(trials)
            try
                centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
                centerSample = round(centerTs*Fs);
                centerRangeSamples = (centerSample - tWindow_oversamples):(centerSample + tWindow_oversamples - 1);
                if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFiltFilt)
                    lfp = sevFiltFilt(centerRangeSamples);
                    lfp = lfp - mean(lfp);
                    
                    rlfp = sevFilt(centerRangeSamples); % same for scalo method
                    rlfp = rlfp - mean(rlfp);
                    
                    if sign(eliminateData) == 1
                        lfp(ceil(numel(lfp)/2):end) = 0; % after t0
                        rlfp(ceil(numel(rlfp)/2):end) = 0; % after t0
                    elseif sign(eliminateData) == -1
                        lfp(1:floor(numel(lfp)/2)) = 0; % before t0
                        rlfp(1:floor(numel(rlfp)/2)) = 0; % before t0
                    end
                end
            catch % for trials without all events
                centerRangeSamples = -tWindow_oversamples:tWindow_oversamples - 1;
                lfp = NaN(1,numel(centerRangeSamples));
                rlfp = NaN(1,numel(centerRangeSamples));
            end
            data(:,iTrial) = lfp;
            return_data(:,iTrial) = rlfp;
        end
        selectRange = (numel(lfp)/2) - round(tWindow_samples):(numel(lfp)/2) + round(tWindow_samples) - 1;
        
        if iscell(freqList)
            all_LFP(iField,:,:,iFreq) = hilbert(data(selectRange,:));
        else
            W = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);
            all_LFP(iField,:,:,:) = W(selectRange,:,:);
        end
        all_data(iField,:,:) = return_data(selectRange,:);
    end
end