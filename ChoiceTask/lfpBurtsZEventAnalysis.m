function [burstEventData,lfpEventData,t,freqList,eventFieldnames,correctTrialCount,scalogramWindow] = ...
    lfpBurtsZEventAnalysis(analysisConf)

% [] LFP analysis doesn't need to be done on every neuron if it's from the
% same tetrode

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

for iNeuron=1:size(analysisConf.neurons,1)
    disp(['----- Working on ',analysisConf.neurons{iNeuron}]);
    
    [tetrodeName,tetrodeId] = getTetrodeInfo(analysisConf.neurons{iNeuron});
    % save time if the sessionConf is already for the correct session
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessionName,analysisConf.sessionNames{iNeuron})
        sessionConf = exportSessionConf(analysisConf.sessionNames{iNeuron},'nasPath',analysisConf.nasPath);
        leventhalPaths = buildLeventhalPaths(sessionConf);
        fullSevFiles = getChFileMap(leventhalPaths.channels);
    end
    
    % load nexStruct
    nexMatFile = [sessionConf.nexPath,'.mat'];
    if exist(nexMatFile)
        disp(['Loading ',nexMatFile]);
        load(nexMatFile);
    else
        error('No NEX .mat file');
    end
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron});
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
        end
    end
    
    % get the burst start times
    tsBurst = [];
    tsLTS = [];
    burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
    if ~isempty(burstIdx) % ISI-based bursts and TLS bursts exist
        burstStartIdx = [1;diff(burstIdx)>1];
        tsBurst = ts(burstIdx(logical(burstStartIdx)));
        tsLTS = filterLTS(tsBurst);
    end
    [~,~,poissonIdx] = burst(ts);
    tsPoisson = [];
    if ~isempty(poissonIdx)
        tsPoisson = ts(poissonIdx);
    end

    logFile = getLogPath(leventhalPaths.rawdata);
    logData = readLogData(logFile);
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    correctTrials = find([trials.correct]==1);
    correctTrialCount(iNeuron) = length(correctTrials);
    
    lfpChannel = sessionConf.lfpChannels(tetrodeId);
    nextSevFile = fullSevFiles{sessionConf.chMap(tetrodeId,lfpChannel+1)};
    disp(['Reading LFP (SEV file) for ',tetrodeName]);
    disp(nextSevFile);
    if ~isempty(sevFile) || strcmp(nextSevFile,sevFile) == 0 % if they are different
        sevFile = nextSevFile;
        [sev,header] = read_tdt_sev(sevFile);
        sev = decimate(double(sev),decimateFactor,'fir');
        Fs = header.Fs/decimateFactor;
        scalogramWindowSamples = round(scalogramWindow * Fs);
    end
    
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

                data(:,trialCount) = sev((eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1));
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