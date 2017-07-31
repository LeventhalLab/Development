lastSession = '';
iCount = 1;
all_subjects__id = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    sessionConf = analysisConf.sessionConfs{iNeuron};
    if strcmp(sessionConf.sessions__name,lastSession)
        continue;
    end
    lastSession = sessionConf.sessions__name;
    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    neuronName = analysisConf.neurons{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
    load(nexMatFile);
    if strcmp(neuronName(1:5),'R0154')
        nexStruct = fixMissingEvents(logData,nexStruct);
    end
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    timingField = 'RT';
    [trialIds,rt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
    all_rt = [all_rt rt];
    
    for iNexNeurons = 1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
            [tsISI,tsLTS,tsPoisson] = tsBurstFilters(ts);
            Lia = ismember(ts,tsISI);
            tsISIInv = ts(~Lia);
        end
    end
    
%     channelData = get_channelData(sessionConf,electrodeChannels);
    lfpChannel = electrodeChannels(1);

    if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
        sevFile = sessionConf.sevFiles{lfpChannel};
        if needsLfp
            [sev,header] = read_tdt_sev(sevFile);
            decimateFactor = 1;%round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
            sevFilt = decimate(double(sev),decimateFactor);
            sevFilt = double(sev);
            Fs = header.Fs / decimateFactor;
        else
            header = getSEVHeader(sevFile);
        end
    end
    
    all_subjects__id = [all_subjects__id sessionConf.subjects__id];
    iCount = iCount + 1;
end