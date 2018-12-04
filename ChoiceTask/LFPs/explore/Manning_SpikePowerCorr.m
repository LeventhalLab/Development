freqList = logFreqList([1 200],50);
tWindow = 0.5;
iEvent = 4;

avg_power = [];
avg_firing = [];
trialCount = 0;
        
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    disp(['Session #',num2str(iSession)]);
    
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);

    keepTrials = threshTrialData(all_data,zThresh);
    W_pow = abs(W(:,:,keepTrials,:)).^2;

    ts = [];
    for jNeuron = find(strcmp(analysisConf.sessionNames,analysisConf.sessionNames(iNeuron)) == 1)'
        ts = [ts;all_ts{jNeuron}];
    end
    tsPeths = eventsPeth(curTrials(trialIds),ts,tWindow,eventFieldnames);
    tsPeths_com = tsPeths(keepTrials,iEvent);

    spectrumData = [];
    SDEs = [];
    for iTrial = 1:size(W_pow,3)
        spectrumData(iTrial,:) = squeeze(mean(W_pow(iEvent,:,iTrial,:),2));
        SDEs(iTrial,:) = mean(spikeDensityEstimate(tsPeths_com{iTrial},tWindow));
    end

    for iTrial = 1:size(W_pow,3)
        trialCount = trialCount + 1;
        spectrumMean = mean(spectrumData);
        spectrumStd = std(spectrumData);
        y = (spectrumData(iTrial,:) - spectrumMean) ./ spectrumStd;
        x = 1:numel(freqList);
        brob = robustfit(x,y);
        avg_power(trialCount,:) = mean(brob(1)+brob(2)*x);
        avg_firing(trialCount,:) = (SDEs(iTrial) - mean(SDEs)) ./ std(SDEs);
    end
end

ff(500,500);
plot(avg_power,avg_firing,'k.');
xlim([-2 2]);
ylim(xlim);
xlabel('power_z');
ylabel('FR_z');