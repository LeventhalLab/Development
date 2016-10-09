% analysisConf = exportAnalysisConf('R0117',nasPath);

% log git commit hash to file
% sandbox and save session variables?

for iNeuron=1:size(analysisConf.neurons,1)
    disp(['Working on ',analysisConf.neurons{iNeuron}]);
    [tetrodeName,tetrodeId] = getTetrodeInfo(analysisConf.neurons{iNeuron});
    
    analysisConf.sessionConfs{1}
    leventhalPaths = buildLeventhalPaths(sessionConf);
    
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
    if isempty(sevFile) || ~strcmp(nextSevFile,sevFile) % if they are different
        sevFile = nextSevFile;
        [sev,header] = read_tdt_sev(sevFile);
        Fs = header.Fs/decimateFactor;
        sev = decimate(double(sev),decimateFactor);
        [b,a] = butter(4,200/(Fs/2)); % low-pass 200Hz
        sev = filtfilt(b,a,sev); % needed for power criteria
        scalogramWindowSamples = round(scalogramWindow * Fs);
    end
    
    neuronName = analysisConf.neurons{iNeuron};
end

run_eventTriggeredAnalysis();