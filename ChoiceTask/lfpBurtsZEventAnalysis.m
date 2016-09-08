function [burstEventData,lfpEventData,t,freqList,eventFieldnames,correctTrialCount] = ...
    lfpBurtsZEventAnalysis(analysisConf)

% [] LFP analysis doesn't need to be done on every neuron if it's from the
% same tetrode

decimateFactor = 10;
scalogramWindow = 2; % seconds
plotEventIdx = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
fpass = [1 100];
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
    % [] what if burstIdx is empty?
    burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
    if isempty(burstIdx)
        disp('no bursting, skipping...');
        continue;
    end
    burstStartIdx = [1;diff(burstIdx)>1];
    tsBurst = ts(burstIdx(logical(burstStartIdx)));
    tsLTS = filterLTS(tsBurst);
    [~,~,poissonIdx]=burst(ts);
    tsPoisson = ts(poissonIdx);

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
        sev = decimate(double(sev),decimateFactor);
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
        
        for iTrial=correctTrials
            eventFieldnames = fieldnames(trials(iTrial).timestamps);
            eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});
            eventSample = round(eventTs * Fs);
            if eventSample - scalogramWindowSamples > 0 && eventSample + scalogramWindowSamples - 1 < length(sev)
                tsPeths.tsEvents{iField} = [tsPeths.tsEvents{iField}; ts(ts < eventTs+scalogramWindow & ts >= eventTs-scalogramWindow) - eventTs];
                tsPeths.tsBurstEvents{iField} = [tsPeths.tsBurstEvents{iField}; tsBurst(tsBurst < eventTs+scalogramWindow & tsBurst >= eventTs-scalogramWindow) - eventTs];
                tsPeths.tsLTSEvents{iField} = [tsPeths.tsLTSEvents{iField}; tsLTS(tsLTS < eventTs+scalogramWindow & tsLTS >= eventTs-scalogramWindow) - eventTs];
                tsPeths.tsPoissonEvents{iField} = [tsPeths.tsPoissonEvents{iField}; tsPoisson(tsPoisson < eventTs+scalogramWindow & tsPoisson >= eventTs-scalogramWindow) - eventTs];

                data(:,iTrial) = sev((eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1));
            end
        end
        [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass);
        allScalograms(iField,:,:) = squeeze(mean(abs(W).^2, 2))';
    end
    t = linspace(-scalogramWindow,scalogramWindow,size(W,1));
    
    lfpEventData{iNeuron} = allScalograms;
    burstEventData{iNeuron} = tsPeths;
end