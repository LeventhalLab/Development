% load('session_20181106_entrainmentData.mat', 'all_ts','LFPfiles_local')
% load('session_20181106_entrainmentData.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'analysisConf')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')

freqList = [1 4;4 7;13 30;30 70;70 200];
iSession = 0;
sessionRhos_byPower = [];
sessionRhos_byEnvelope = [];
sessionRhos_byPhase = [];
sessionPvals = [];
for jNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    disp(['Session #',num2str(iSession)]);
    sevFile = LFPfiles_local{jNeuron};
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    curTrials = all_trials{iNeuron};
    trialTimeRanges = compileTrialTimeRanges(curTrials);
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
    
    % remove all ts intrial
    for iNeuron = find(strcmp(analysisConf.sessionNames,analysisConf.sessionNames(jNeuron)) == 1)'
        ts = all_ts{iNeuron};
        % remove in-trial ts
        for iTrial = 1:size(trialTimeRanges,1)
            ts(ts > trialTimeRanges(iTrial,1) & ts < trialTimeRanges(iTrial,2)) = [];
        end
    end
    
    s = equalVectors(spikeDensityEstimate(ts),dataZPower(iFreq,:));
    
    for iFreq = 1:size(freqList,1)
        [rho,pval] = corr(dataZPower(iFreq,:)',s');
        sessionRhos_byPower(iSession,iFreq) = rho;
        sessionPvals(iSession,iFreq) = pval;
        
        [rho,~] = circ_corrcc(dataPhase(iFreq,:)',s');
        sessionRhos_byPhase(iSession,iFreq) = rho;
        
        [rho,~] = corr(dataZEnvelope(iFreq,:)',s');
        sessionRhos_byEnvelope(iSession,iFreq) = rho;
    end
end