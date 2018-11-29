% load('session_20181106_entrainmentData.mat', 'all_ts','LFPfiles_local')
% load('session_20181106_entrainmentData.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'analysisConf')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local_altLookup')

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

            dataPower = abs(hx).^2;
            dataZPower(iFreq,:) = (dataPower - mean(dataPower)) ./ std(dataPower);

            dataPhase(iFreq,:) = angle(hx);

            dataEnvelope = abs(dataFilt);
            dataZEnvelope(iFreq,:) = (dataEnvelope - mean(dataEnvelope)) ./ std(dataEnvelope);
        end
    end
    disp(['iNeuron ',num2str(iNeuron)]);
    
    % this is only apples to apples if time ranges are applied
    ts = all_ts{iNeuron};
%     if useInTrial
%         temp = [];
%         % include in-trial ts, reset ts to temp
%         for iTrial = 1:size(trialTimeRanges,1)
%             temp = [temp;ts(ts > trialTimeRanges(iTrial,1) & ts < trialTimeRanges(iTrial,2))];
%         end
%         ts = temp;
%     else
%         % remove in-trial ts
%         for iTrial = 1:size(trialTimeRanges,1)
%             ts(ts > trialTimeRanges(iTrial,1) & ts < trialTimeRanges(iTrial,2)) = [];
%         end
%     end
    s = equalVectors(spikeDensityEstimate(ts),dataZPower(iFreq,:));
    trialTimeRanges_s = round(trialTimeRanges*Fs);
    sample_range = [];
    if useInTrial
        for iTrial = 1:size(trialTimeRanges,1)
            sample_range = [sample_range trialTimeRanges_s(iTrial,1):trialTimeRanges_s(iTrial,2)];
        end
    else
        for iTrial = 2:size(trialTimeRanges,1)-1 % bracketed by trials
            sample_range = [sample_range trialTimeRanges_s(iTrial-1,2):trialTimeRanges_s(iTrial,1)];
        end
    end
    
    for iFreq = 1:size(freqList,1)
        [rho,pval] = corr(dataZPower(iFreq,sample_range)',s(sample_range)');
        sessionRhos_byPower(iNeuron,iFreq) = rho;
        sessionPvals(iNeuron,iFreq) = pval;
        
        [rho,~] = circ_corrcl(dataPhase(iFreq,sample_range)',s(sample_range)');
        sessionRhos_byPhase(iNeuron,iFreq) = rho;
        
        [rho,~] = corr(dataZEnvelope(iFreq,sample_range)',s(sample_range)');
        sessionRhos_byEnvelope(iNeuron,iFreq) = rho;
    end
end

if useInTrial
    if useAlt
        data_source_inTrial_alt = {sessionRhos_byPower,sessionRhos_byEnvelope,sessionRhos_byPhase};
    else
         data_source_inTrial_no_alt = {sessionRhos_byPower,sessionRhos_byEnvelope,sessionRhos_byPhase};
    end
else
    if useAlt
        data_source_outTrial_alt = {sessionRhos_byPower,sessionRhos_byEnvelope,sessionRhos_byPhase};
    else
        data_source_outTrial_no_alt = {sessionRhos_byPower,sessionRhos_byEnvelope,sessionRhos_byPhase};
    end
end