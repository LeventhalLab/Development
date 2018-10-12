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
tWindow = [-1,1]; % for scalograms, xlim is set to -1/+1 in formatting
sevFile = '';

eventList = {'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval'};

for iNeuron=1:size(analysisConf.neurons,1)
    
    neuronName = analysisConf.neurons{iNeuron};
    sessionName = analysisConf.sessionNames{iNeuron};
    sessionIdx = find(strcmp(sessionName,sessions_to_analyze));
    cur_lfpWire = lfpWire(sessionIdx);
    
    RTcorr_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_RT_correlations']);
    RTcorr_session_dir = fullfile(RTcorr_subject_dir, analysisConf.sessionNames{iNeuron});
    if ~exist(RTcorr_session_dir,'dir')
        mkdir(RTcorr_session_dir);
    end
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
        logData = readLogData(logFile);
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);
        trialIds = find([trials.correct]==1);
        
        RT = [];
        for ii = 1 : length(trialIds)
            RT = [RT;trials(trialIds(ii)).timing.RT];
        end
    end
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            all_ts = nexStruct.neurons{iNexNeurons}.timestamps;
            all_trial_ts = extractTrial_ts(all_ts, trials,false);
            correct_ts = extractTrial_ts(all_ts, trials,true);
            
            ts = all_ts;
            
%             tr_trialsOnly = extractTrial_ts(ts, trials);
            [tsISI,tsLTS,tsPoisson,tsPoissonLTS,ISI_n,LTS_n,Poisson_n,PoissonLTS_n] = tsBurstFilters(ts);
            Lia = ismember(ts,tsISI);
            tsISIInv = ts(~Lia);
            
        end
    end
    sigma = 0.025; % 0.05 = 50ms
%     sigma = round(mean(diff(ts))/3,3); % use mean ISI?
    endTs = length(sevFilt) / Fs;
    [s,~,~] = spikeDensityEstimate_Fs(ts,endTs,sigma,Fs);
    [sISI,~,~] = spikeDensityEstimate_Fs(tsISI,endTs,sigma,Fs);
    [sLTS,~,~] = spikeDensityEstimate_Fs(tsLTS,endTs,sigma,Fs);
    [sPoisson,~,~] = spikeDensityEstimate_Fs(tsPoisson,endTs,sigma,Fs);

    RTcorr_all = calcRTcorrelations(s, trials(trialIds), tWindow, Fs, eventList);
    RTcorr_ISI = calcRTcorrelations(sISI, trials(trialIds), tWindow, Fs, eventList);
    RTcorr_LTS = calcRTcorrelations(sLTS, trials(trialIds), tWindow, Fs, eventList);
    RTcorr_Poisson = calcRTcorrelations(sPoisson, trials(trialIds), tWindow, Fs, eventList);
    
    [surr_RTcorr_all,std_surr_RTcorr_all] = calcRTcorr_surrogates(s, trials(trialIds), tWindow, Fs, numSurrogates, eventList);
    [surr_RTcorr_ISI,std_surr_surr_RTcorr_ISI] = calcRTcorr_surrogates(sISI, trials(trialIds), tWindow, Fs, numSurrogates, eventList);
    [surr_RTcorr_LTS,std_surr_RTcorr_LTS] = calcRTcorr_surrogates(sLTS, trials(trialIds), tWindow, Fs, numSurrogates,  eventList);
    [surr_RTcorr_Poisson,std_surr_RTcorr_Poisson] = calcRTcorr_surrogates(sPoisson, trials(trialIds), tWindow, Fs, numSurrogates, eventList);
    
    % ----- ANALYSIS START -----
    RTcorrMetadata.neuron = analysisConf.neurons{iNeuron};
    RTcorrMetadata.Fs = Fs;
    RTcorrMetadata.tWindow = tWindow;    % how far to look before and after each timestamp when computing scalograms
    RTcorrMetadata.t = t;
    RTcorrMetadata.eventList = eventList;
    RTcorrMetadata.numSurrogates = numSurrogates;
    
    RTcorr_name = [neuronName '_spike_RT_corr.mat'];
    RTcorr_name = fullfile(RTcorr_session_dir, RTcorr_name);
    save(RTcorr_name,'RTcorr_all','RTcorr_ISI','RTcorr_LTS','RTcorr_Poisson','RTcorrMetadata',...
                     'surr_RTcorr_all','surr_RTcorr_ISI','surr_RTcorr_LTS','surr_RTcorr_Poisson',...
                     'std_surr_RTcorr_all','std_surr_surr_RTcorr_ISI','std_surr_RTcorr_LTS','std_surr_RTcorr_Poisson');
    
    % high beta power centered analysis using ts raster
%     fpass = [13 30];
% %     tWindow = 1; % [] need to standardize time windows somehow
%     fieldname = 'centerOut';
%     [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(trials,trialIds,fieldname,ts,sev,header.Fs,fpass,scaloWindow);
%     lfpRasters(); % format

% % run_RTraster()
end

addUnitHeader(analysisConf,{'eventAnalysis'});