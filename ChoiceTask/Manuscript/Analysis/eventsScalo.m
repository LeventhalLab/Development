function [allScalograms,allLfpData] = eventsScalo(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)
% see eventsLFP.m for a similar function that returns the complex scalogram


% need better lfp thresh algorithm
lfpThresh = 2000; % diff of lfp in uV

tWindowSamples = round(Fs * tWindow);

allScalograms = [];
allLfpData = [];
for iField=1:numel(eventFieldnames)
    data = [];
    for iTrial=1:numel(trials)
        centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        centerSample = round(centerTs*Fs);
        centerRangeSamples = (centerSample - tWindowSamples):(centerSample + tWindowSamples - 1);
        if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFilt)
            lfp = sevFilt(centerRangeSamples);
            % disabled for now, throwing error on R0117_20160508a_T23_ch[0 0 0 104]a
% %             if max(abs(diff(lfp))) > lfpThresh
% %                 disp(['skipping trial ',num2str(iTrial),' (lfp thresh)']);
% %                 continue;
% %             end
            data(:,iTrial) = lfp;
        end
    end
    allLfpData(iField,:,:) = data;
    [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);
    allScalograms(iField,:,:) = squeeze(mean(abs(W).^2,2))';
end