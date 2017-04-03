% % nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
% % analysisConf = exportAnalysisConfv2('R0088',nasPath);

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 2; % for scalograms, xlim is set to -1/+1 in formatting
% plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
sevFile = '';

all_meanTiming = [];
all_trials = {};
neuronPeth = [];

all_tidx_contra_correct = [];
all_tidx_ipsi_correct = [];
all_tidx_contra_incorrect = [];
all_tidx_ipsi_incorrect = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    fpass = [10 100];
    freqList = logFreqList(fpass,30);
    
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
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    all_trials{iNeuron} = trials; % for debugging
    timingField = 'movementDirection';
    [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
    
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
    needsLfp = false;
    
    % this is really not perfect yet, needs LFP channel in DB I think
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channels = sessionConf.session_electrodes.channel(any(rows')');
    lfpChannel = channels(1);
% lfpChannel = 65;

    if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
%             sevFile = sessionConf.sevFiles{lfpChannel};
        sevFile = sessionConf.sevFiles{lfpChannel};
        if needsLfp
            [sev,header] = read_tdt_sev(sevFile);
            decimateFactor = 1;%round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
% %             sevFilt = decimate(double(sev),decimateFactor);
            sevFilt = double(sev);
% %             Fs = header.Fs / decimateFactor;
            Fs = header.Fs;
        else
            header = getSEVHeader(sevFile);
        end
    end

    
    % ----- ANALYSIS START -----
    
    % produces waveform and ISI xcorr analyses
    if isNewSession
% %         makeUnitSummaries();
    end
    
    % timing raster investigation
% %     tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
% %     tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow);
% %     tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
% %     tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
% %     tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow);


    % unit-to-event classifier analysis
    sessionSeconds = header.fileSizeBytes/header.Fs/4; % seconds
    sessionFR = 1 / mean(diff(ts));
    binMs = 50; % ms
    nBins = round((2*tWindow / .001) / binMs);
    nBinHalfWidth = ((tWindow*2) / nBins) / 2;
    nBins_tWindow = linspace(-tWindow+nBinHalfWidth,tWindow-nBinHalfWidth,nBins);
    nBins_all = round((sessionSeconds / .001) / binMs);
    nBins_all_tWindow = linspace(0,sessionSeconds,nBins_all);

    tsPeth = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
    all_meanTiming(iNeuron) = mean(allTimes);

    [allCounts,allCenters] = hist(ts,all_nBins);
    for iEvent = 1:numel(eventFieldnames)
        [counts,centers] = hist([tsPeth{:,iEvent}],nBins);
        zCounts = ((counts / size(tsPeth,1)) - mean(allCounts)) / std(allCounts);
        neuronPeth(iNeuron,iEvent,:) = zCounts;
    end
    
    % ipsi/contra analysis
    trials_correct = trials;
%     trials_correct = trials(trialIds);
    tsPeths = eventsPeth(trials_correct,ts,tWindow,eventFieldnames);
    [allCounts,allCenters] = hist(ts,nBins_all_tWindow);
    zCounts = [];
    if ~isempty(tsPeths)
        for iEvent = 1:size(tsPeths,2)
            for iTrial = 1:size(tsPeths,1)
                [counts,centers] = hist(tsPeths{iTrial,iEvent},nBins_tWindow);
                zCounts(iEvent,iTrial,:) = (counts - mean(allCounts)) / std(allCounts);
            end
        end
    end
    
%     ipsiContraHists();
    ipsiContraZTrialCompare();


    % event-centered analysis
% %     tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
% %     tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow);
% %     tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
% %     tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
% %     tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow);
% %     [eventScalograms,eventFieldnames,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList);
% %     t = linspace(-tWindow,tWindow,size(eventScalograms,3));
% %     eventAnalysis(); % format
    
    % scalograms based on different ts bursts separated by low-med-high
    % spike density
% %     tsScalograms = tsScalogram(ts,sevFilt,tWindow,Fs,freqList);
% %     t = linspace(-tWindow,tWindow,size(tsScalograms,3)); % set one for all
% %     tsISIScalograms = tsScalogram(tsISI,sevFilt,tWindow,Fs,freqList);
% %     tsLTSScalograms = tsScalogram(tsLTS,sevFilt,tWindow,Fs,freqList);
% %     tsPoissonScalograms = tsScalogram(tsPoisson,sevFilt,tWindow,Fs,freqList);
% %     allTsScalograms = {tsScalograms,tsISIScalograms,tsLTSScalograms,tsPoissonScalograms};
% %     allScalogramTitles = {'ts','tsISI','tsLTS','tsPoisson'};
% %     tsPrctlScalos(); % format
    
% %     % high beta power centered analysis using ts raster
% %     fpass = [13 30];
% %     tWindow = 1; % [] need to standardize time windows somehow
% %     fieldname = 'centerOut';
% %     [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(trials,trialIds,fieldname,ts,sev,header.Fs,fpass,tWindow);
% %     lfpRasters(); % format

% % run_RTraster()
end

% % addUnitHeader(analysisConf,{'eventAnalysis'});