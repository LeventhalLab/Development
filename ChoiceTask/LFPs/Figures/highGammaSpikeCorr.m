% load('session_20181106_entrainmentData.mat', 'all_ts','LFPfiles_local')
% load('session_20181106_entrainmentData.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'analysisConf')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')

freqList = [1 4;4 7;13 30;30 70;70 200];
iSession = 0;
sessionRhos = [];
sessionPvals = [];
for jNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    disp(['Session #',num2str(iSession)]);
    sevFile = LFPfiles_local{jNeuron};
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    
    dataZPower = [];
    for iFreq = 1:size(freqList,1)
        dataPower = abs(hilbert(eegfilt(sevFilt,Fs,freqList(iFreq,1),freqList(iFreq,2))));
        dataZPower(iFreq,:) = (dataPower - mean(dataPower)) ./ std(dataPower);
    end
    
    ts = [];
    for iNeuron = find(strcmp(analysisConf.sessionNames,analysisConf.sessionNames(jNeuron)) == 1)'
        ts = [ts;all_ts{iNeuron}];
    end
    s = decimate(spikeDensityEstimate(ts),2); % always smaller than signal
    filtSamples = floor(linspace(1,size(dataZPower,2),numel(s)));
    
    for iFreq = 1:size(freqList,1)
        [rho,pval] = corr(dataZPower(iFreq,filtSamples)',s');
        sessionRhos(iSession,iFreq) = rho;
        sessionPvals(iSession,iFreq) = pval;
    end
end