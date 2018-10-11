nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
analysis_storage_dir = '/Volumes/Tbolt_02/VM thal analysis';

sessions_to_analyze = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a',...
                       'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160508a','R0117_20160510a'};

lfpWire = [44,39,40,39,93,120,100,93,120,93,120];
plot_t_limits = [-1,1];

eventList = {'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval'};

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

binWidth = 0.025;
histBins = (plot_t_limits(1) : binWidth : plot_t_limits(2));

for iRat = 1:2%length(ratIDs)
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

                ts = all_ts;

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
        periEvent_beta_name = sprintf('%s_periEventBeta_correctOnly_bin%03d.mat',neuronName,binWidth*1000);
        tsScalo_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_triggered_scalos']);
        if ~exist(tsScalo_subject_dir,'dir')
            mkdir(tsScalo_subject_dir);
        end
        tsScalo_session_dir = fullfile(tsScalo_subject_dir, analysisConf.sessionNames{iNeuron});
        if ~exist(tsScalo_session_dir,'dir')
            mkdir(tsScalo_session_dir);
        end
        periEvent_beta_name = fullfile(tsScalo_session_dir, periEvent_beta_name);

        burstIdx = (LTS_n > 2) & (LTS_n < 6);
        numBursts = length(burstIdx);
        
        event_ts = extractEvent_ts( eventList{1}, trials, true );
        temp = calcPeriSpikeLFP( event_ts, abs(sev_betaHilbert), tWindow, Fs );
        LTShist = zeros(length(eventList),size(temp,1),length(histBins)-1);
        all_tsHist = zeros(length(eventList),size(temp,1),length(histBins)-1);
        periEventBeta = zeros(length(eventList),size(temp,1),size(temp,2));
        periEventGamma = zeros(length(eventList),size(temp,1),size(temp,2));
        periEventBeta(1,:,:) = temp;
        temp = calcPeriSpikeLFP( event_ts, abs(sev_gammaHilbert), tWindow, Fs );
        periEventGamma(1,:,:) = temp;
        
        temp = getTrialHist( tsLTS, event_ts,histBins);
        LTShist(1,:,:) = temp;
        temp = getTrialHist( all_ts, event_ts,histBins);
        all_tsHist(1,:,:) = temp;
        
%         LTShist = zeros(length(eventList), length(histBins)-1);
%         all_tsHist = zeros(length(eventList), length(histBins)-1);
%         hist_LTS_ts = [0];
%         hist_all_ts = [0];
%         for ii = 1 : length(event_ts)
%             a = tsPeth(tsLTS,event_ts(ii),max(histBins));
%             a2 = tsPeth(all_ts,event_ts(ii),max(histBins));
%             if ~isempty(a)
%                 hist_LTS_ts = [hist_LTS_ts,a];
%                 hist_all_ts = [hist_all_ts,a2];
%             end
%         end
%         if length(hist_LTS_ts) > 1;hist_LTS_ts = hist_LTS_ts(1:end-1);end
%         if length(hist_all_ts) > 1;hist_all_ts = hist_all_ts(1:end-1);end
        
%         LTShist(1,:) = histcounts(hist_LTS_ts,histBins);
%         all_tsHist(1,:) = histcounts(hist_all_ts,histBins);
        for ii = 2 : length(eventList)
            event_ts = extractEvent_ts( eventList{ii}, trials, true );
            temp = calcPeriSpikeLFP( event_ts, abs(sev_betaHilbert), tWindow, Fs );
            periEventBeta(ii,:,:) = temp;
            periEventGamma(ii,:,:) = calcPeriSpikeLFP( event_ts, abs(sev_gammaHilbert), tWindow, Fs );
            
            temp = getTrialHist( tsLTS, event_ts,histBins);
            LTShist(ii,:,:) = temp;
            temp = getTrialHist( all_ts, event_ts,histBins);
            all_tsHist(ii,:,:) = temp;
        
%             hist_LTS_ts = [0];
%             hist_all_ts = [0];
%             for jj = 1 : length(event_ts)
%                 a = tsPeth(tsLTS,event_ts(jj),max(histBins));
%                 a2 = tsPeth(all_ts,event_ts(jj),max(histBins));
%                 if ~isempty(a)
%                     hist_LTS_ts = [hist_LTS_ts,a];
%                     hist_all_ts = [hist_all_ts,a2];
%                 end
%             end
%             if length(hist_LTS_ts) > 1;hist_LTS_ts = hist_LTS_ts(1:end-1);end
%             if length(hist_all_ts) > 1;hist_all_ts = hist_all_ts(1:end-1);end
% 
%             LTShist(ii,:) = histcounts(hist_LTS_ts,histBins);
%             all_tsHist(ii,:) = histcounts(hist_all_ts,histBins);
        end
        endTs = length(sevFilt)/Fs;
        rand_ts = tWindow + (rand(numRandomTs,1) * (endTs - 2*tWindow));
        periRandomBeta = calcPeriSpikeLFP( rand_ts, abs(sev_betaHilbert), tWindow, Fs );
        periRandomGamma = calcPeriSpikeLFP( rand_ts, abs(sev_gammaHilbert), tWindow, Fs );
        periRandomLTS = calcRandomHist( tsLTS, tWindow, endTs, histBins, numRandomTs );
        periRandom_all_ts = calcRandomHist( all_ts, tWindow, endTs, histBins, numRandomTs );
        t = linspace(-tWindow,tWindow,size(periEventBeta,3)); % set one for all

        peri_eventMetadata.neuron = analysisConf.neurons{iNeuron};
        peri_eventMetadata.Fs = Fs;
        peri_eventMetadata.tWindow = tWindow;    % how far to look before and after each timestamp when computing scalograms
        peri_eventMetadata.fpass_beta = fpass_beta;
        peri_eventMetadata.fpass_gamma = fpass_gamma;
        peri_eventMetadata.t = t;
        peri_eventMetadata.numRandomTs = numRandomTs;
        peri_eventMetadata.binEdges = histBins;
        peri_eventMetadata.binWidth = binWidth;
        peri_eventMetadata.eventList = eventList;

        save(periEvent_beta_name,'peri_eventMetadata','periRandomBeta','periRandomGamma','LTShist','all_tsHist','periEventBeta','periEventGamma','periRandomLTS','periRandom_all_ts');

    end

end