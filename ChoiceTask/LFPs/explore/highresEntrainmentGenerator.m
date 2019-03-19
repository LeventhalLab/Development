% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local_altLookup')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')

doSetup = true;
doAlt = true;
doWrite = true;
doDebug = false;

freqList = logFreqList([1 200],30);
nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
loadedFile = [];
nSurr = 200;

if doDebug
    spiketrain_gamma_order = 0.5; % poisson
    [t,s] = fastgammatrain(spiketrain_duration,spiketrain_meanrate,spiketrain_gamma_order);
    tsp = t(s==1)' / 1000;
    
    h = ff(1000,600);
    rows = 2;
    cols = 2;
    binEdges = linspace(0,1,100);
    useTs = {ts,tsp};
    tsLabels = {'ts','tsp'};
    for iTs = 1:2
        subplot(rows,cols,prc(cols,[1 iTs]));
        histogram(diff(useTs{iTs}),binEdges);
        title(tsLabels{iTs});
        
        subplot(rows,cols,prc(cols,[2 iTs]));
        plot(diff(useTs{iTs}));
        xlim([1 numel(useTs{iTs})]);
        ylim([0 2]);
        title('diff');
    end
end

if doSetup
    entrainmentUnits = [];
    entrain_pvals = NaN(nSurr,2,numel(all_ts),numel(freqList));
    entrain_rs = NaN(nSurr,2,numel(all_ts),numel(freqList));
    entrain_mus = NaN(nSurr,2,numel(all_ts),numel(freqList));
    entrain_hist = NaN(nSurr,2,numel(all_ts),nBins,numel(freqList));
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        disp(['--> iNeuron ',num2str(iNeuron)]);
        ts = all_ts{iNeuron};
        FR = numel(ts) / max(ts);
        if FR < 5
            disp(['skipping at ',num2str(FR,2),' Hz']);
            continue;
        end
        entrainmentUnits = [entrainmentUnits iNeuron];
        % replace with alternative for LFP
        if doAlt
            sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
        end
        [~,name,~] = fileparts(sevFile);
        % only load uniques
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
            [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
            curTrials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
            trialTimeRanges = compileTrialTimeRanges(curTrials(trialIds));

            W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList); % size: 5568092, 1, 3
            W = squeeze(W); % size: 5568092, 3
        end
        
        for iSurr = 1:nSurr + 1
            if iSurr > 1 % replace ts
                ts = all_ts{iNeuron};
                spiketrain_duration = max(ts) * 1000; % ms
                spiketrain_meanrate = numel(ts) / max(ts); % s/sec
                spiketrain_gamma_order = 1; % poisson
                [t,s] = fastgammatrain(spiketrain_duration,spiketrain_meanrate,spiketrain_gamma_order);
                ts = t(s==1)' / 1000;
            end
            ts_samples = floor(ts * Fs);
            ts_samples = ts_samples(ts_samples > 0 & ts_samples <= size(W,1)); % clean conversion errors
            
            for iIn = 1:2
                if iIn == 1 % IN-TRIAL
                    spikeAngles = [];
                    inTrial_ids = [];
                    for ii = 1:size(trialTimeRanges,1)
                        theseIds = find(ts > trialTimeRanges(ii,1) & ts <= trialTimeRanges(ii,2));
                        inTrial_ids = [inTrial_ids;theseIds]; % compile for inter-trial
                        spikeAngles = [spikeAngles;angle(W(floor(ts(theseIds)*Fs),:))]; % compiling inTrial spikeAngles
                    end
                else % INTER-TRIAL
                    interTrial_ids = ones(numel(ts_samples),1);
                    interTrial_ids(inTrial_ids) = 0;
                    interTrial_ids = logical(interTrial_ids);
                    
                    % match in-trial sample count
                    useSamples = ts_samples(interTrial_ids);
                    limitSamples = randsample(useSamples,numel(inTrial_ids));
                    spikeAngles = angle(W(limitSamples,:));
                end
                for iFreq = 1:numel(freqList)
                    alpha = spikeAngles(:,iFreq);
                    entrain_pvals(iSurr,iIn,iNeuron,iFreq) = circ_rtest(alpha);
                    entrain_rs(iSurr,iIn,iNeuron,iFreq) = circ_r(alpha);
                    entrain_mus(iSurr,iIn,iNeuron,iFreq) = circ_mean(alpha);
                    entrain_hist(iSurr,iIn,iNeuron,:,iFreq) = histcounts(alpha,binEdges);
                end
            end
        end
    end
    if doWrite
        save('20190318_entrain','entrain_pvals','entrain_rs','entrain_mus','entrain_hist','binEdges','entrainmentUnits');
    end
end