function [burstEventData,lfpEventData,t,freqList,eventFieldnames,correctTrials] = ...
    lfpEventAnalysis(analysisConf)

% [] LFP analysis doesn't need to be done on every neuron if it's from the
% same tetrode

decimateFactor = 10;
scalogramWindow = 2; % seconds
plotEventIdx = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
fpass = [1 100];
lfpEventData = {};
burstEventData = {};
maxBurstISI = 0.007; % seconds
            
for iNeuron=1:size(analysisConf.neurons,1)
    disp(['Working on ',analysisConf.neurons{iNeuron}]);
    
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
        load(nexMatFile);
    else
        error('No NEX .mat file');
    end
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNeuron}.name,analysisConf.neurons{iNeuron});
            ts = nexStruct.neurons{iNeuron}.timestamps;
        end
    end
    
    % get the burst start times
    burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
    burstStartIdx = [1;diff(burstIdx)>1];
    tsBurst = ts(burstIdx(logical(burstStartIdx)));
    tsLTS = filterLTS(tsBurst);
    [~,~,poissonIdx]=burst(ts);
    tsPoisson = ts(poissonIdx);

    logFile = getLogPath(leventhalPaths.rawdata);
    logData = readLogData(logFile);
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    correctTrials = find([trials.correct]==1);
    
    disp(['Reading from ',tetrodeName]);
    
    lfpChannel = sessionConf.lfpChannels(tetrodeId);
    [sev,header] = read_tdt_sev(fullSevFiles{sessionConf.chMap(tetrodeId,lfpChannel+1)});
    sev = decimate(double(sev),decimateFactor);
    Fs = header.Fs/decimateFactor;
    scalogramWindowSamples = round(scalogramWindow * Fs);
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
        
        for iTrial=correctTrials
            eventFieldnames = fieldnames(trials(iTrial).timestamps);
            eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});
            
            tsPeths.tsEvents{iField} = [tsPeths.tsEvents{iField}; ts(ts < eventTs+scalogramWindow & ts >= eventTs-scalogramWindow) - eventTs];
            tsPeths.tsBurstEvents{iField} = [tsPeths.tsBurstEvents{iField}; tsBurst(tsBurst < eventTs+scalogramWindow & tsBurst >= eventTs-scalogramWindow) - eventTs];
            tsPeths.tsLTSEvents{iField} = [tsPeths.tsLTSEvents{iField}; tsLTS(tsLTS < eventTs+scalogramWindow & tsLTS >= eventTs-scalogramWindow) - eventTs];
            tsPeths.tsPoissonEvents{iField} = [tsPeths.tsPoissonEvents{iField}; tsPoisson(tsPoisson < eventTs+scalogramWindow & tsPoisson >= eventTs-scalogramWindow) - eventTs];
            
            eventSample = round(eventTs * Fs);
            data(:,iTrial) = sev((eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1));
        end
        [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass);
        allScalograms(iField,:,:) = squeeze(mean(abs(W).^2, 2))';
    end
    t = linspace(-scalogramWindow,scalogramWindow,size(W,1));
    
    lfpEventData{iNeuron} = allScalograms;
    burstEventData{iNeuron} = tsPeths;   
end