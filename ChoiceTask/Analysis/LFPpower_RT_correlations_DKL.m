nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
analysis_storage_dir = '/Volumes/Tbolt_02/VM thal analysis';

sessions_to_analyze = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a',...
                       'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160508a','R0117_20160510a'};

lfpWire = [44,39,40,39,93,120,100,93,120,93,120];
plot_t_limits = [-1,1];

analysisConf = exportAnalysisConfv2('R0088',nasPath);
numSurrogates = 100;

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 2.5; % for scalograms, xlim is set to -1/+1 in formatting
scaloWindow = 1;  % use this to pull out just +/- 1 second around each event
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
sevFile = '';

eventList = {'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval'};
prevSession = '';
freqList = logspace(0,2.7,37);
for iNeuron=1:size(analysisConf.neurons,1)

    neuronName = analysisConf.neurons{iNeuron};
    sessionName = analysisConf.sessionNames{iNeuron};
    if strcmp(sessionName, prevSession); continue; end
    prevSession = sessionName;
    
    sessionIdx = find(strcmp(sessionName,sessions_to_analyze));
    cur_lfpWire = lfpWire(sessionIdx);
    
    ratID = sessionName(1:5);
    
    tsScalo_subject_dir = fullfile(analysis_storage_dir, [ratID '_spike_triggered_scalos']);
    tsScalo_session_dir = fullfile(tsScalo_subject_dir, sessionName);
    
    LFPcorr_subject_dir = fullfile(analysis_storage_dir, [ratID '_LFP_RT_correlations']);
    LFPcorr_session_dir = fullfile(LFPcorr_subject_dir, sessionName);
    if ~exist(LFPcorr_session_dir,'dir')
        mkdir(LFPcorr_session_dir);
    end
    disp(['Working on ',sessionName]);
    
    sessionConf = analysisConf.sessionConfs{iNeuron};

    nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
    if exist(nexMatFile,'file')
        disp(['Loading ',nexMatFile]);
        load(nexMatFile);
    else
        error('No NEX .mat file');
    end

    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    trialIds = find([trials.correct]==1);

    cd(tsScalo_session_dir)
    lfp_search_name = sprintf('*ch%02d_lfp.mat',cur_lfpWire);
    lfp_list = dir(lfp_search_name);
    if isempty(lfp_list)
        fprintf('%s not found',lfp_search_name);
        continue;
    end
    load(lfp_list.name);
        
%     RT = [];
%     for ii = 1 : length(trialIds)
%         RT = [RT;trials(trialIds(ii)).timing.RT];
%     end

    [LFP_RTcorr,log_LFP_RTcorr] = scalo_RTcorr(trials(trialIds),sevFilt,tWindow,scaloWindow,Fs,freqList,eventList);
    
%     [surr_RTcorr_all,std_surr_RTcorr_all] = calcRTcorr_surrogates(s, trials(trialIds), tWindow, Fs, numSurrogates, eventList);
%     [surr_surr_RTcorr_ISI,std_surr_surr_RTcorr_ISI] = calcRTcorr_surrogates(sISI, trials(trialIds), tWindow, Fs, numSurrogates, eventList);
%     [surr_RTcorr_LTS,std_surr_RTcorr_LTS] = calcRTcorr_surrogates(sLTS, trials(trialIds), tWindow, Fs, numSurrogates,  eventList);
%     [surr_RTcorr_Poisson,std_surr_RTcorr_Poisson] = calcRTcorr_surrogates(sPoisson, trials(trialIds), tWindow, Fs, numSurrogates, eventList);
    
    % ----- ANALYSIS START -----
    t = linspace(-scaloWindow,scaloWindow,size(LFP_RTcorr,3));
    
    scaloRTcorrMetadata.neuron = analysisConf.neurons{iNeuron};
    scaloRTcorrMetadata.Fs = Fs;
    scaloRTcorrMetadata.tWindow = tWindow;    % how far to look before and after each timestamp when computing scalograms
    scaloRTcorrMetadata.t = t;
    scaloRTcorrMetadata.eventList = eventList;
    scaloRTcorrMetadata.numSurrogates = numSurrogates;
    scaloRTcorrMetadata.freqList = freqList;
    
    RTcorr_name = [neuronName '_spike_RT_corr.mat'];
    RTcorr_name = fullfile(LFPcorr_session_dir, RTcorr_name);
    save(RTcorr_name,'LFP_RTcorr','log_LFP_RTcorr','scaloRTcorrMetadata');
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