nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
analysis_storage_dir = '/Volumes/Tbolt_02/VM thal analysis';

sessions_to_analyze = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a',...
                       'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160508a','R0117_20160510a'};

lfpWire = [44,39,40,39];
plot_t_limits = [-1,1];

analysisConf = exportAnalysisConfv2('R0088',nasPath);
numRandomScalograms = 1000;

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 2.5; % for scalograms, xlim is set to -1/+1 in formatting
scaloWindow = 1;  % use this to pull out just +/- 1 second around each event
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
sevFile = '';

for iNeuron=1:size(analysisConf.neurons,1)
    fpass = [1 500];
%     freqList = logFreqList(fpass,30);
    freqList = logspace(0,2.7,50);            % DKL addition to match frequencies I've been using on my old data from Josh's lab
    
    neuronName = analysisConf.neurons{iNeuron};
    sessionName = analysisConf.sessionNames{iNeuron};
    sessionIdx = find(strcmp(sessionName,sessions_to_analyze));
    cur_lfpWire = lfpWire(sessionIdx);
    
    tsScalo_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_triggered_scalos']);
    tsScalo_session_dir = fullfile(tsScalo_subject_dir, analysisConf.sessionNames{iNeuron});
    
    disp(['Working on ',neuronName]);
    [tetrodeName,tetrodeId,tetrodeChs] = getTetrodeInfo(neuronName);
    
    % only load different sessions
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron}.sessions__name)
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
    
    if isNewSession
        logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
        logData = readLogData(logFile);
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);
        trialIds = find([trials.correct]==1);
    end
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
            [tsISI,tsLTS,tsPoisson,tsPoissonLTS,ISI_n,LTS_n,Poisson_n,PoissonLTS_n] = tsBurstFilters(ts);
            Lia = ismember(ts,tsISI);
            tsISIInv = ts(~Lia);
        end
    end
    
    % load SEV file and filter it for LFP analyses
    if isNewSession
        cd(tsScalo_session_dir)
        lfp_search_name = sprintf('*ch%02d_lfp.mat',cur_lfpWire);
        lfp_list = dir(lfp_search_name);
        if isempty(lfp_list)
            fprintf('%s not found',lfp_search_name);
            continue;
        end
        load(lfp_list.name);
    end
%     if sessionConf.singleWires(tetrodeId) == 0
%         lfpChannel = sessionConf.lfpChannels(tetrodeId); % tetrode
%     else
%         lfpIdx = find(tetrodeChs~=0,1);
%         lfpChannel = tetrodeChs(lfpIdx);
%     end
%     if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
%         sevFile = sessionConf.sevFiles{lfpChannel};
%         [sev,header] = read_tdt_sev(sevFile);
%         decimateFactor = round(header.Fs / (fpass(2) * 2)); % 2x max desired LFP freq
%         sevFilt = decimate(double(sev),decimateFactor);
%         Fs = header.Fs / decimateFactor;
%     end
    
    % ----- ANALYSIS START -----
    
    % produces waveform and ISI xcorr analyses
%     if isNewSession
%         makeUnitSummaries();
%     end
    
    % the big event-centered analysis
%     tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
%     tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow);
%     tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
%     tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
%     tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow); 
%     [eventScalograms,eventFieldnames,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList);
%     t = linspace(-tWindow,tWindow,size(eventScalograms,3));
%     eventAnalysis(); % format
    
    % filenames to store the analyzed scalogram data
    tsScalo_name = [neuronName '_scalos.mat'];
    tsScalo_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_triggered_scalos']);
    if ~exist(tsScalo_subject_dir,'dir')
        mkdir(tsScalo_subject_dir);
    end
    tsScalo_session_dir = fullfile(tsScalo_subject_dir, analysisConf.sessionNames{iNeuron});
    if ~exist(tsScalo_session_dir,'dir')
        mkdir(tsScalo_session_dir);
    end
    tsScalo_name = fullfile(tsScalo_session_dir, tsScalo_name);
    
    % scalograms based on different ts bursts separated by low-med-high
    % spike density
    if isNewSession
        [meanScalo, stdScalo, log_meanScalo, log_stdScalo] = meanScalogram(sevFilt,tWindow,scaloWindow,Fs,freqList,numRandomScalograms);
        mean_psd = mean(meanScalo,2);
        mean_logpsd = mean(log_meanScalo,2);
        std_psd = mean(stdScalo,2);
        std_logpsd = mean(log_stdScalo,2);
    end
    
    [tsScalograms,tsMRL,n_tsScalograms,ts_logScalograms] = tsScalogram_DKL_20170215(ts,sevFilt,tWindow,scaloWindow,Fs,freqList);
    t = linspace(-scaloWindow,scaloWindow,size(tsScalograms,3)); % set one for all
    
    
    % MODIFIED HERE - MUST HAVE AT LEAST 3 SPIKES BUT LESS THAN 6 TO BE A
    % BURST
    burstIdx = (ISI_n > 2) & (ISI_n < 6);
    [tsISIScalograms,tsISIMRL,n_tsISIScalograms,ts_ISIlogScalograms] = tsScalogram_DKL_20170215(tsISI(burstIdx),sevFilt,tWindow,scaloWindow,Fs,freqList);
    burstIdx = (LTS_n > 2) & (LTS_n < 6);
    [tsLTSScalograms,tsLTSMRL,n_tsLTSScalograms,ts_LTSlogScalograms] = tsScalogram_DKL_20170215(tsLTS(burstIdx),sevFilt,tWindow,scaloWindow,Fs,freqList);
    burstIdx = (Poisson_n > 2) & (Poisson_n < 6);
    [tsPoissonScalograms,tsPoissonMRL,n_tsPoissonScalograms,ts_PoissonlogScalograms] = tsScalogram_DKL_20170215(tsPoisson(burstIdx),sevFilt,tWindow,scaloWindow,Fs,freqList);
    [allTsScalograms] = {tsScalograms,tsISIScalograms,tsLTSScalograms,tsPoissonScalograms};
    [all_logTsScalograms] = {ts_logScalograms,ts_ISIlogScalograms,ts_LTSlogScalograms,ts_PoissonlogScalograms};
    [allTsMRL] = {tsMRL,tsISIMRL,tsLTSMRL,tsPoissonMRL};
    [allnScalograms] = [n_tsScalograms,n_tsISIScalograms,n_tsLTSScalograms,n_tsPoissonScalograms];
    allScalogramTitles = {'ts','tsISI','tsLTS','tsPoisson'};
    
    scaloMetadata.neuron = analysisConf.neurons{iNeuron};
    scaloMetadata.densityLabels = {'all','low density','med density','high density'};
    scaloMetadata.allScalogramTitles = allScalogramTitles;
    scaloMetadata.Fs = Fs;
    scaloMetadata.tWindow = tWindow;    % how far to look before and after each timestamp when computing scalograms
    scaloMetadata.scaloWindow = scaloWindow;
    scaloMetadata.f = freqList;
    scaloMetadata.t = t;
    scaloMetadata.numRandomScalograms = numRandomScalograms;
    
    save(tsScalo_name,'allTsScalograms','all_logTsScalograms','allTsMRL','allnScalograms','scaloMetadata','mean_psd','mean_logpsd','std_psd','std_logpsd');
%     tsPrctlScalos_DKL(); % format
    
    % high beta power centered analysis using ts raster
%     fpass = [13 30];
% %     tWindow = 1; % [] need to standardize time windows somehow
%     fieldname = 'centerOut';
%     [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(trials,trialIds,fieldname,ts,sev,header.Fs,fpass,scaloWindow);
%     lfpRasters(); % format

% % run_RTraster()
end

addUnitHeader(analysisConf,{'eventAnalysis'});