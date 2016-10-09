function [tsPeths,t] = eventTriggeredAnalysis(ts,trials,sevFile)

% [] LFP analysis doesn't need to be done on every neuron if it's from the
% same tetrode
lfpThresh = 200; % diff of lfp in uV
scalogramWindow = 2; % seconds
plotEventIdx = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
fpass = [10 100];
freqList = logFreqList(fpass,30);
lfpEventData = {};
burstEventData = {};
correctTrials = find([trials.correct]==1);

[sev,header] = read_tdt_sev(sevFile);
decimateFactor = round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
sevFilt = decimate(sev,decimateFactor);
Fs = header.Fs / decimateFactor;

allScalograms = [];
tsPeths = struct;
% tsPeths.tsEvents = {};
% tsPeths.tsISIEvents = {};
% tsPeths.tsLTSEvents = {};
% tsPeths.tsPoissonEvents = {};
for iField=plotEventIdx
    trialCount = 1;
    for iTrial=correctTrials
        eventFieldnames = fieldnames(trials(iTrial).timestamps);
        eventTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
        eventSample = round(eventTs*Fs);
        eventSampleRange = (eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1);
        if eventSampleRange(1) > 0 && eventSampleRange(end) < length(sev)
            lfp = sevFilt(eventSampleRange);
            if max(abs(diff(lfp))) > lfpThresh
                disp(['skipping trial ',num2str(iTrial),' (lfp thresh)']);
                continue;
            end
            data(:,trialCount) = lfp;
            tsPeths.tsEvents{trialCount,iField} = tsPeth(ts,eventTs,scalogramWindow);
            tsPeths.tsISIEvents{trialCount,iField} = tsPeth(ts,eventTs,scalogramWindow);
            
            if ~isempty(tsBurst)
                tsPeths.tsBurstEvents{trialCount,iField} = tsBurst(tsBurst < eventTs+scalogramWindow & tsBurst >= eventTs-scalogramWindow)' - eventTs;
            end
            if ~isempty(tsLTS)
                tsPeths.tsLTSEvents{trialCount,iField} = tsLTS(tsLTS < eventTs+scalogramWindow & tsLTS >= eventTs-scalogramWindow)' - eventTs;
            end
            if ~isempty(tsPoisson)
                tsPeths.tsPoissonEvents{trialCount,iField} = tsPoisson(tsPoisson < eventTs+scalogramWindow & tsPoisson >= eventTs-scalogramWindow)' - eventTs;
            end
            trialCount = trialCount + 1;
        end
    end
    [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass,'freqList',freqList);
    allScalograms(iField,:,:) = squeeze(mean(abs(W).^2, 2))';
end

t = linspace(-scalogramWindow,scalogramWindow,size(W,1));

lfpEventData{iNeuron} = allScalograms;
burstEventData{iNeuron} = tsPeths;
