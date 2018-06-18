function [W_power,W_phase,W_median,W_timing,W_key] = compileW(useEvents,freqList,all_trials,LFPfiles_local,eventFieldnames)
decimateFactor = 20;
sevFile = '';
W_power = [];
W_phase = [];
W_median = [];
W_timing = {};
W_key = [];
loopCount = 0;
trialCount = zeros(numel(freqList),numel(useEvents));
for iNeuron = 1:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    loopCount = loopCount + 1;
    disp(num2str(iNeuron));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};
    [W,freqList,allTimes,allTrialIds] = getW(sevFile,curTrials,eventFieldnames,freqList,'RTMT');
    W_timing{loopCount} = [allTimes;allTrialIds];
    for iFreq = 1:numel(freqList)
        refW = squeeze(squeeze(W(1,1:round(size(W,2)/2),:,iFreq)));
        W_median(loopCount,iFreq) = nanmedian(abs(refW(:)).^2);
        for iEvent = 1:numel(useEvents)
            for iTrial = 1:size(W,3)
                trialCount(iFreq,iEvent) = trialCount(iFreq,iEvent) + 1;
                curW = decimate(squeeze(squeeze(W(useEvents(iEvent),:,iTrial,iFreq))),decimateFactor);
                W_power(iFreq,iEvent,trialCount(iFreq,iEvent),:) = abs(curW).^2;
                W_phase(iFreq,iEvent,trialCount(iFreq,iEvent),:) = angle(curW);
                W_key(trialCount(iFreq,iEvent),:) = [iNeuron,loopCount];
            end
        end
    end
end