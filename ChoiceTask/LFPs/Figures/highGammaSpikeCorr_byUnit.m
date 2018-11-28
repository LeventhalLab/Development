% load('session_20181106_entrainmentData.mat', 'all_ts','LFPfiles_local')
% load('session_20181106_entrainmentData.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'analysisConf')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local_altLookup')
useAlt = true;
freqList = [1 4;4 7;13 30;30 70;70 200];
loaded_sevFile = '';
sessionRhos_byPower = [];
sessionRhos_byEnvelope = [];
sessionRhos_byPhase = [];
sessionPvals = [];
for iNeuron = 1:numel(LFPfiles_local)
    curTrials = all_trials{iNeuron};
    trialTimeRanges = compileTrialTimeRanges(curTrials);
    
    sessionName = analysisConf.sessionNames{iNeuron};
    disp(sessionName);
    sevFile = LFPfiles_local{iNeuron};
    if useAlt
        sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
    end

    if ~strcmp(sevFile,loaded_sevFile)
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        loaded_sevFile = sevFile;

        dataZPower = [];
        dataPhase = [];
        dataZEnvelope = [];
        for iFreq = 1:size(freqList,1)
            dataFilt = eegfilt(sevFilt,Fs,freqList(iFreq,1),freqList(iFreq,2));
            hx = hilbert(dataFilt);

            dataPower = abs(hx);
            dataZPower(iFreq,:) = (dataPower - mean(dataPower)) ./ std(dataPower);

            dataPhase(iFreq,:) = angle(hx);

            dataEnvelope = abs(dataFilt);
            dataZEnvelope(iFreq,:) = (dataEnvelope - mean(dataEnvelope)) ./ std(dataEnvelope);
        end
    end
    disp(['iNeuron ',num2str(iNeuron)]);
    
    ts = all_ts{iNeuron};
    % remove in-trial ts
    for iTrial = 1:size(trialTimeRanges,1)
        ts(ts > trialTimeRanges(iTrial,1) & ts < trialTimeRanges(iTrial,2)) = [];
    end
    
    s = equalVectors(spikeDensityEstimate(ts),dataZPower(iFreq,:));
    
    for iFreq = 1:size(freqList,1)
        [rho,pval] = corr(dataZPower(iFreq,:)',s');
        sessionRhos_byPower(iNeuron,iFreq) = rho;
        sessionPvals(iNeuron,iFreq) = pval;
        
        [rho,~] = circ_corrcl(dataPhase(iFreq,:)',s');
        sessionRhos_byPhase(iNeuron,iFreq) = rho;
        
        [rho,~] = corr(dataZEnvelope(iFreq,:)',s');
        sessionRhos_byEnvelope(iNeuron,iFreq) = rho;
    end
end