function [] = eventTriggeredAnalysis(ts,trials,sevFile)

% [] LFP analysis doesn't need to be done on every neuron if it's from the
% same tetrode
lfpThresh = 200; % diff of lfp in uV
decimateFactor = 10;
scalogramWindow = 2; % seconds
plotEventIdx = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
fpass = [10 100];
nFreqs = 30;
freqList = exp(linspace(log(fpass(1)),log(fpass(2)),30));
lfpEventData = {};
burstEventData = {};
maxBurstISI = 0.007; % seconds
correctTrialCount = [];
sevFile = '';


    
    allScalograms = [];
    tsPeths = struct;
    tsPeths.ts = ts;
    tsPeths.tsBurst = tsBurst;
    tsPeths.tsLTS = tsLTS;
    tsPeths.tsPoisson = tsPoisson;
    tsPeths.tsEvents = {};
    tsPeths.tsBurstEvents = {};
    tsPeths.tsLTSEvents = {};
    for iField=plotEventIdx
        tsPeths.tsEvents{iField} = [];
        tsPeths.tsBurstEvents{iField} = [];
        tsPeths.tsLTSEvents{iField} = [];
        tsPeths.tsPoissonEvents{iField} = [];
        
        trialCount = 1;
        for iTrial=correctTrials
            eventFieldnames = fieldnames(trials(iTrial).timestamps);
            eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});
            eventSample = round(eventTs * Fs);
            if eventSample - scalogramWindowSamples > 0 && eventSample + scalogramWindowSamples - 1 < length(sev)
                lfp = sev((eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1));
                if max(abs(diff(lfp))) > lfpThresh
                    disp(['skipping trial ',num2str(iTrial),' (lfp thresh)']);
                    continue;
                end
                data(:,trialCount) = lfp;
                tsPeths.tsEvents{trialCount,iField} = ts(ts < eventTs+scalogramWindow & ts >= eventTs-scalogramWindow)' - eventTs;
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
end