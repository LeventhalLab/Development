% % nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 1; % for scalograms, xlim is set to -1/+1 in formatting
% plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn

% RT = cue -> centerOut
% MT = centerOut -> sideIn
% pretone = centerIn -> tone
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
sevFile = '';

all_meanTiming = [];
all_trials = {};
all_tsPeths = {};
all_ts = {};
neuronPeth = [];

all_tidx_contra_correct = [];
all_tidx_ipsi_correct = [];
all_tidx_contra_incorrect = [];
all_tidx_ipsi_incorrect = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    fpass = [1 100];
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
% %     if strcmp(neuronName(1:5),'R0154')
        nexStruct = fixMissingEvents(logData,nexStruct);
% %     end
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    all_trials{iNeuron} = trials; % for debugging
    timingField = 'RT';
    [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
    
%     continue;
    
    % load timestamps for neuron
    for iNexNeurons = 1:length(nexStruct.neurons)
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

    if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
%             sevFile = sessionConf.sevFiles{lfpChannel};
        sevFile = sessionConf.sevFiles{lfpChannel};
        if needsLfp
            [sev,header] = read_tdt_sev(sevFile);
            decimateFactor = 1;%round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
            sevFilt = decimate(double(sev),decimateFactor);
            Fs = header.Fs / decimateFactor;
        else
            header = getSEVHeader(sevFile);
        end
    end

    
    % ----- ANALYSIS START -----
    
    % produces waveform and ISI xcorr analyses
    if isNewSession
%         makeUnitSummaries();
    end
    
    % !! Not used but need eventFieldnames
    % timing raster investigation
% %     tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
% %     tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow);
% %     tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
% %     tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
% %     tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow);

    if true
        % !!!review binning to make sure edges are handled
        % unit-to-event classifier analysis
        sessionSeconds = header.fileSizeBytes/header.Fs/4; % seconds
        sessionFR = 1 / mean(diff(ts));
        binMs = 50; % ms
        nBins = round((2*tWindow / .001) / binMs);
        nBinHalfWidth = ((tWindow*2) / nBins) / 2;
        nBins_tWindow = linspace(-tWindow+nBinHalfWidth,tWindow-nBinHalfWidth,nBins);
        nBins_all = round((sessionSeconds / .001) / binMs);
        nBins_all_tWindow = linspace(0,sessionSeconds,nBins_all);

        all_ts{iNeuron} = ts;
        tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
        all_tsPeths{iNeuron} = tsPeths;
    %     all_meanTiming(iNeuron) = mean(allTimes);

        [allCounts,allCenters] = hist(ts,nBins_all);
        for iEvent = 1:numel(eventFieldnames)
            [counts,centers] = hist([tsPeths{:,iEvent}],nBins);
            zCounts = ((counts / size(tsPeths,1)) - mean(allCounts)) / std(allCounts);
            neuronPeth(iNeuron,iEvent,:) = zCounts;
        end

        % ipsi/contra analysis
    %     trials_correct = trials;
    %     trials_correct = trials(trialIds);
    %     tsPeths = eventsPeth(trials_correct,ts,tWindow,eventFieldnames);
        tsPeths = eventsPeth(trials,ts,tWindow,eventFieldnames);
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
%         ipsiContraZTrialCompare();
    end


    if false
        % event-centered analysis
        tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
        tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow,eventFieldnames);
        tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow,eventFieldnames);
        tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow,eventFieldnames);
        tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow,eventFieldnames);
        [eventScalograms,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        t = linspace(-tWindow,tWindow,size(tsPeths,1));
        eventAnalysis(); % format
    end
    
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

% addUnitHeader(analysisConf,{'eventAnalysis'});