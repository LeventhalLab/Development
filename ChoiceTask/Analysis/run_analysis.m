% nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
% analysisConf = exportAnalysisConf('R0088',nasPath);

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 2; % for scalograms, xlim is set to -1/+1 in formatting
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
sevFile = '';

for iNeuron=1:size(analysisConf.neurons,1)
    fpass = [10 100];
    freqList = logFreqList(fpass,30);
    freqList = [0:80];
    
    neuronName = analysisConf.neurons{iNeuron};
    disp(['Working on ',neuronName]);
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName)
    
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
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    trialIds = find([trials.correct]==1);
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
            [tsISI,tsLTS,tsPoisson] = tsBurstFilters(ts);
            Lia = ismember(ts,tsISI);
            tsISIInv = ts(~Lia);
        end
    end
    
    % load SEV file and filter it for LFP analyses
    rows = sessionConf.session_electrodes.site == electrodeSite;
    channels = sessionConf.session_electrodes.channel(rows);
    lfpChannel = 108;%channels(1);
    
    if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
        sevFile = sessionConf.sevFiles{lfpChannel};
        [sev,header] = read_tdt_sev(sevFile);
        decimateFactor = round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
    end
    
    % ----- ANALYSIS START -----
    
    % produces waveform and ISI xcorr analyses
    if isNewSession
%         makeUnitSummaries();
    end
    
    % the big event-centered analysis
    tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
    tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow);
    tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
    tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
    tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow); 
    [eventScalograms,eventFieldnames,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList);
    t = linspace(-tWindow,tWindow,size(eventScalograms,3));
    eventAnalysis(); % format
    
    % scalograms based on different ts bursts separated by low-med-high
    % spike density
    tsScalograms = tsScalogram(ts,sevFilt,tWindow,Fs,freqList);
    t = linspace(-tWindow,tWindow,size(tsScalograms,3)); % set one for all
    tsISIScalograms = tsScalogram(tsISI,sevFilt,tWindow,Fs,freqList);
    tsLTSScalograms = tsScalogram(tsLTS,sevFilt,tWindow,Fs,freqList);
    tsPoissonScalograms = tsScalogram(tsPoisson,sevFilt,tWindow,Fs,freqList);
    allTsScalograms = {tsScalograms,tsISIScalograms,tsLTSScalograms,tsPoissonScalograms};
    allScalogramTitles = {'ts','tsISI','tsLTS','tsPoisson'};
    tsPrctlScalos(); % format
    
    % high beta power centered analysis using ts raster
    fpass = [13 30];
    tWindow = 1; % [] need to standardize time windows somehow
    fieldname = 'centerOut';
    [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(trials,trialIds,fieldname,ts,sev,header.Fs,fpass,tWindow);
    lfpRasters(); % format

% % run_RTraster()
end

addUnitHeader(analysisConf,{'eventAnalysis'});