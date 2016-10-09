% analysisConf = exportAnalysisConf('R0117',nasPath);

% log git commit hash to file
% sandbox and save session variables?

for iNeuron=1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['Working on ',neuronName]);
    [tetrodeName,tetrodeId] = getTetrodeInfo(neuronName);
    
    sessionConf = analysisConf.sessionConfs{iNeuron};
    
    % load nexStruct
    nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
    if exist(nexMatFile,'file')
        disp(['Loading ',nexMatFile]);
        load(nexMatFile);
    else
        error('No NEX .mat file');
    end
    
    logFile = getLogPath(leventhalPaths.rawdata);
    logData = readLogData(logFile);
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
%     correctTrials = find([trials.correct]==1);
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron});
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
            [tsISI,tsLTS,tsPoisson] = tsBurstFilters(ts);
        end
    end
    
    lfpChannel = sessionConf.lfpChannels(tetrodeId);
    nextSevFile = fullSevFiles{sessionConf.chMap(tetrodeId,lfpChannel+1)};
    
%     disp(['Reading LFP (SEV file) for ',tetrodeName]);
%     disp(nextSevFile);
%     if isempty(sevFile) || ~strcmp(nextSevFile,sevFile) % if they are different
%         sevFile = nextSevFile;
%         [sev,header] = read_tdt_sev(sevFile);
%         Fs = header.Fs/decimateFactor;
%         sev = decimate(double(sev),decimateFactor);
%         [b,a] = butter(4,200/(Fs/2)); % low-pass 200Hz
%         sev = filtfilt(b,a,sev); % needed for power criteria
%         scalogramWindowSamples = round(scalogramWindow * Fs);
%     end

end

run_eventTriggeredAnalysis();