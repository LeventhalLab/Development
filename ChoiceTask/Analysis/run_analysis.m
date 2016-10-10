% analysisConf = exportAnalysisConf('R0117',nasPath);
fpass = [10 100];
freqList = logFreqList(fpass,30);
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn

for iNeuron=1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['Working on ',neuronName]);
    [tetrodeName,tetrodeId,tetrodeChs] = getTetrodeInfo(neuronName);
    
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
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron});
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
            [tsISI,tsLTS,tsPoisson] = tsBurstFilters(ts);
        end
    end
    
    if sessionConf.singleWires(tetrodeId) == 0
        lfpChannel = sessionConf.lfpChannels(tetrodeId);
    else
        lfpIdx = find(tetrodeChs~=0,1);
        lfpChannel = tetrodeChs(lfpIdx);
    end
    sevFile = sessionConf.sevFiles{lfpChannel};
    [sev,header] = read_tdt_sev(sevFile);
    decimateFactor = round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    
    trialIds = find([trials.correct]==1);
    
    tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
    tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
    tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
    tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow); 
    [allScalograms,eventFieldnames] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,fpass,freqList);
    eventAnalysis();
    
    allScalograms = tsScalogram(ts,sevFilt,tWindow,Fs,fpass,freqList);
    tsScalograms();
    
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

% run_eventTriggeredAnalysis();