function [allScalograms,eventFieldnames] = eventsScalo(trials,sevFilt,tWindow,Fs,fpass,freqList)
% need better lfp thresh algorithm
lfpThresh = 2000; % diff of lfp in uV

tWindowSamples = round(Fs * tWindow);

allScalograms = [];
eventFieldnames = fieldnames(trials(1).timestamps); % assumes fields are same for all
for iField=1:numel(eventFieldnames)
    data = [];
    for iTrial=1:numel(trials)
        centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        centerSample = round(centerTs*Fs);
        centerRangeSamples = (centerSample - tWindowSamples):(centerSample + tWindowSamples - 1);
        if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFilt)
            lfp = sevFilt(centerRangeSamples);
            if max(abs(diff(lfp))) > lfpThresh
                disp(['skipping trial ',num2str(iTrial),' (lfp thresh)']);
                continue;
            end
            data(:,iTrial) = lfp;
        end
    end
    [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass,'freqList',freqList);
    allScalograms(iField,:,:) = squeeze(mean(abs(W).^2,2))';
end