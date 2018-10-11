nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
analysis_storage_dir = '/Volumes/Tbolt_02/VM thal analysis';

sessions_to_analyze = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a',...
                       'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160508a','R0117_20160510a'};

lfpWire = [44,39,40,39,93,120,100,93,120,93,120];
plot_t_limits = [-1,1];

ratIDs = {'R0088','R0117'};

[ validNeuronList, validLTSunits ] = getValidNeurons();
units_to_use = validLTSunits;

numRandomScalograms = 100;

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 1; % for scalograms, xlim is set to -1/+1 in formatting
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
sevFile = '';

fpass_beta = [16 24];
fpass_gamma = [45 55];
numRandomTs = 1000;

for iRat = 1 : length(ratIDs)
    analysisConf = exportAnalysisConfv2(ratIDs{iRat},nasPath);
    for iNeuron=1:size(analysisConf.neurons,1)
    %     freqList = logFreqList(fpass,30);

        neuronName = analysisConf.neurons{iNeuron};
        if ~any(strcmp(neuronName,units_to_use))
            continue;
        end
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
            logData = readLogData(logFile);
            trials = createTrialsStruct_simpleChoice(logData,nexStruct);
            trialIds = find([trials.correct]==1);
        end

        % load timestamps for neuron
        for iNexNeurons=1:length(nexStruct.neurons)
            if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
                disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
                all_ts = nexStruct.neurons{iNexNeurons}.timestamps;
                all_trial_ts = extractTrial_ts(all_ts, trials,false);
                correct_ts = extractTrial_ts(all_ts, trials,true);

                ts = correct_ts;

    %             tr_trialsOnly = extractTrial_ts(ts, trials);
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
            Wn = fpass_beta / (Fs/2);
            b = fir1(250,Wn);
            
            Wn = fpass_gamma / (Fs/2);
            c = fir1(200,Wn);

            gamma_sevFilt = filtfilt(c,1,sevFilt);
            beta_sevFilt = filtfilt(b,1,sevFilt);
            
            sev_betaHilbert = hilbert(beta_sevFilt);
            sev_gammaHilbert = hilbert(gamma_sevFilt);
            
            betaPower = abs(sev_betaHilbert).^2;
            gammaPower = abs(sev_gammaHilbert).^2;
            
            betaMean = mean(abs(sev_betaHilbert));
            gammaMean = mean(abs(sev_gammaHilbert));
            
            betaSTD = std(sev_betaHilbert);
            gammaSTD = std(sev_gammaHilbert);
            
            betaPowerMean = mean(betaPower);
            gammaPowerMean = mean(gammaPower);
            betaPowerStd = std(betaPower);
            gammaPowerStd = std(gammaPower);
        end

        % filenames to store the analyzed LFP data
        periSpike_beta_name = [neuronName '_periSpikeBeta_correctOnly.mat'];
        tsScalo_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_triggered_scalos']);
        if ~exist(tsScalo_subject_dir,'dir')
            mkdir(tsScalo_subject_dir);
        end
        tsScalo_session_dir = fullfile(tsScalo_subject_dir, analysisConf.sessionNames{iNeuron});
        if ~exist(tsScalo_session_dir,'dir')
            mkdir(tsScalo_session_dir);
        end
        periSpike_beta_name = fullfile(tsScalo_session_dir, periSpike_beta_name);

        burstIdx = (LTS_n > 2) & (LTS_n < 6);
        numBursts = length(burstIdx);
        periSpikeBeta = calcPeriSpikeLFP( tsLTS(burstIdx), abs(sev_betaHilbert), tWindow, Fs );
        periSpikeGamma = calcPeriSpikeLFP( tsLTS(burstIdx), abs(sev_gammaHilbert), tWindow, Fs );
        
        rand_ts = tWindow + (rand(numRandomTs,1) * (length(sevFilt)/Fs - 2*tWindow));
        periRandomBeta = calcPeriSpikeLFP( rand_ts, abs(sev_betaHilbert), tWindow, Fs );
        periRandomGamma = calcPeriSpikeLFP( rand_ts, abs(sev_gammaHilbert), tWindow, Fs );
        
        t = linspace(-tWindow,tWindow,size(periSpikeBeta,2)); % set one for all


        peri_tsMetadata.neuron = analysisConf.neurons{iNeuron};
        peri_tsMetadata.Fs = Fs;
        peri_tsMetadata.tWindow = tWindow;    % how far to look before and after each timestamp when computing scalograms
        peri_tsMetadata.fpass_beta = fpass_beta;
        peri_tsMetadata.fpass_gamma = fpass_gamma;
        peri_tsMetadata.t = t;
        peri_tsMetadata.numRandomTs = numRandomTs;

        save(periSpike_beta_name,'peri_tsMetadata','periRandomBeta','betaMean','betaStd','periSpikeBeta','hilbertMean','hilbertSTD');

    end

end