% % nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
% % analysisConf = exportAnalysisConfv2('R0088',nasPath);
tWindow = 3; % for scalograms, xlim is set to -1/+1 in formatting

% RT = cue -> centerOut
% MT = centerOut -> sideIn
% pretone = centerIn -> tone
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
sevFile = '';
fpass = [1 100];
freqList = logFreqList(fpass,30);

for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['Working on ',neuronName]);
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    
    % only load different sessions
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron})
        sessionConf = analysisConf.sessionConfs{iNeuron};
        isNewSession = true;
        % load nexStruct.. I don't love using 'load'
        nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
        if exist(nexMatFile,'file')
            disp(['Loading ',nexMatFile]);
            load(nexMatFile);
        else
            error('No NEX .mat file');
        end
    else
        isNewSession = false;
    end
    
    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    if strcmp(neuronName(1:5),'R0154')
        nexStruct = fixMissingEvents(logData,nexStruct);
    end
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    all_trials{iNeuron} = trials; % for debugging
    trialIdInfo = organizeTrialsById(trials);
    useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi];

    % load timestamps for neuron
    for iNexNeurons = 1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
        end
    end

    % load SEV file and filter it for LFP analyses
    needsLfp = true;
    
    % this is really not perfect yet, needs LFP channel in DB I think
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channels = sessionConf.session_electrodes.channel(any(rows')');
    lfpChannel = channels(1);

    if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
%             sevFile = sessionConf.sevFiles{lfpChannel};
        sevFile = sessionConf.sevFiles{lfpChannel};
        if needsLfp
            [sev,header] = read_tdt_sev(sevFile);
            decimateFactor = round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
            sevFilt = decimate(double(sev),decimateFactor);
            Fs = header.Fs / decimateFactor;
        else
            header = getSEVHeader(sevFile);
        end
    end
    
    % --- ANALYZE
    [eventScalograms,allLfpData] = eventsScalo(trials(useTrials),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    
    % --- DISPLAY
    
end