nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
analysis_storage_dir = '/Volumes/Tbolt_02/VM thal analysis';

sessions_to_analyze = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a',...
                       'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160508a','R0117_20160510a'};

lfpWire = [44,39,40,39,93,120,100,93,120,93,120];
plot_t_limits = [-1,1];

analysisConf = exportAnalysisConfv2('R0117',nasPath);
numSurrogate_xcorrs = 100;
fpass = [16 25];

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 2.5; % for scalograms, xlim is set to -1/+1 in formatting
xcorrWindow = 2;  % use this to pull out just +/- 1 second around each event
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
sevFile = '';

for iNeuron=1:size(analysisConf.neurons,1)
    
%     freqList = logFreqList(fpass,30);
%     freqList = logspace(0,2.7,50);            % DKL addition to match frequencies I've been using on my old data from Josh's lab
    
    neuronName = analysisConf.neurons{iNeuron};
    sessionName = analysisConf.sessionNames{iNeuron};
    sessionIdx = find(strcmp(sessionName,sessions_to_analyze));
    cur_lfpWire = lfpWire(sessionIdx);
    
    tsScalo_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_triggered_scalos']);
    tsScalo_session_dir = fullfile(tsScalo_subject_dir, analysisConf.sessionNames{iNeuron});
    
    disp(['Working on ',neuronName]);
    [tetrodeName,tetrodeId,tetrodeChs] = getTetrodeInfo(neuronName);
    
    % only load different sessions
    if ~exist('sessionConf','var') || ...
       ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron}.sessions__name) || ...
       iNeuron == 1
   
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
        if exist(logFile,'file') ~= 2; continue; end
        
        logData = readLogData(logFile);
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);
        trialIds = find([trials.correct]==1);
        event_ts = extractEvent_ts('centerOut', trials, true);
    end
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            all_ts = nexStruct.neurons{iNexNeurons}.timestamps;
            all_trial_ts = extractTrial_ts(all_ts, trials, false);
            correct_ts = extractTrial_ts(all_ts, trials, true);
            
            ts = all_ts;
            
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
    
    Wn = fpass / (Fs/2);
    b = fir1(200,Wn);
    
    sigma = 0.025; % 0.05 = 50ms
%     sigma = round(mean(diff(ts))/3,3); % use mean ISI?
    endTs = length(sevFilt) / Fs;
    [s,~,~] = spikeDensityEstimate_Fs(ts,endTs,sigma,Fs);
    [sISI,~,~] = spikeDensityEstimate_Fs(tsISI,endTs,sigma,Fs);
    [sLTS,~,~] = spikeDensityEstimate_Fs(tsLTS,endTs,sigma,Fs);
    [sPoisson,~,~] = spikeDensityEstimate_Fs(tsPoisson,endTs,sigma,Fs);
    
    beta_sevFilt = filtfilt(b,1,sevFilt);
    sevHilbert = hilbert(beta_sevFilt);
    betaPower = abs(sevHilbert).^2;
    betaMean = mean(betaPower);
    betaStd = std(betaPower);
    
    % filenames to store the analyzed scalogram data
    xcorr_name = [neuronName '_spike_beta_xcorr_trialsOnly_bursts.mat'];
    xcorr_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_beta_xcorr']);
    if ~exist(xcorr_subject_dir,'dir')
        mkdir(xcorr_subject_dir);
    end
    xcorr_session_dir = fullfile(xcorr_subject_dir, analysisConf.sessionNames{iNeuron});
    if ~exist(xcorr_session_dir,'dir')
        mkdir(xcorr_session_dir);
    end
    xcorr_name = fullfile(xcorr_session_dir, xcorr_name);

    [ mean_all_xcorr ] = calc_trial_xcorr( s, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow );
    [ mean_ISI_xcorr ] = calc_trial_xcorr( sISI, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow );
    [ mean_LTS_xcorr ] = calc_trial_xcorr( sLTS, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow );
    [ mean_Poisson_xcorr ] = calc_trial_xcorr( sPoisson, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow );
    
    [ mean_surr_all_xcorr, std_surr_all_xcorr ] = calc_trial_xcorr_surrogates( s, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow, numSurrogate_xcorrs );
    [ mean_surr_ISI_xcorr, std_surr_ISI_xcorr ] = calc_trial_xcorr_surrogates( sISI, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow, numSurrogate_xcorrs );
    [ mean_surr_LTS_xcorr, std_surr_LTS_xcorr ] = calc_trial_xcorr_surrogates( sLTS, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow, numSurrogate_xcorrs );
    [ mean_surr_Poisson_xcorr, std_surr_Poisson_xcorr ] = calc_trial_xcorr_surrogates( sPoisson, event_ts, abs(sevHilbert), Fs, [-1,1]*xcorrWindow, numSurrogate_xcorrs );


%     [ mean_logxcorr ] = calc_trial_xcorr( s, event_ts, log10(betaPower), Fs, [-1 1]*xcorrWindow );
%     [ mean_surr_xcorr,std_surr_xcorr ] = calc_trial_xcorr_surrogates( s, event_ts, abs(sevHilbert), Fs, [-1 1]*xcorrWindow, numSurrogate_xcorrs );
    
    pre_samps = floor(length(mean_all_xcorr)/2);
    t = (-pre_samps:pre_samps)/Fs;
    
    xcorrMetadata.neuron = analysisConf.neurons{iNeuron};
    xcorrMetadata.Fs = Fs;
    xcorrMetadata.tWindow = tWindow;    % how far to look before and after each timestamp when computing xcorrgrams
    xcorrMetadata.xcorrWindow = xcorrWindow;
    xcorrMetadata.fpass = fpass;
    xcorrMetadata.t = t;
    xcorrMetadata.numSurrogate_xcorrs = numSurrogate_xcorrs;
    
    save(xcorr_name,'mean_all_xcorr',...
                    'xcorrMetadata',...
                    'mean_ISI_xcorr',...
                    'mean_LTS_xcorr',...
                    'mean_Poisson_xcorr',...
                    'mean_surr_all_xcorr',...
                    'mean_surr_ISI_xcorr',...
                    'mean_surr_LTS_xcorr',...
                    'mean_surr_Poisson_xcorr',...
                    'std_surr_all_xcorr',...
                    'std_surr_ISI_xcorr',...
                    'std_surr_LTS_xcorr',...
                    'std_surr_Poisson_xcorr');
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