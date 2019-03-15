% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local_altLookup')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')

doAlt = true;

freqList = logFreqList([1 200],30);
nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
loadedFile = [];
nSurr = 1;

if doSetup
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        % replace with alternative for LFP
        if doAlt
            sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
        end
        disp(sevFile);
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
        
        ts = all_ts{iNeuron};
        for iSurr = 1:nSurr+1
            if iSurr > 1 % replace ts
                spiketrain_duration = max(ts) * 1000; % ms
                spiketrain_meanrate = numel(ts) / max(ts); % s/sec
                spiketrain_gamma_order = 1; % poisson
                [t,s] = fastgammatrain(spiketrain_duration,spiketrain_meanrate,spiketrain_gamma_order);
                ts_poisson = t(s==1) / 1000;
            end
        end
    end
end