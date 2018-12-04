freqList = logFreqList([1 200],50);
tWindow = 0.5;
iEvent = 4;
oversampleBy = 3;
nSurr = 200;
zThresh = 5;

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
% %     [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    
    % surrogates
    trialTimeRanges = compileTrialTimeRanges(curTrials);
    takeTime = tWindow * oversampleBy;
    takeSamples = round(takeTime * Fs);
    minTime = min(trialTimeRanges(:,2));
    maxTime = max(trialTimeRanges(:,1)) - takeTime;

    data = [];
    surrLog = [];
    iSurr = 0;
    disp('Gathering surrogates...');
    while iSurr < nSurr + 40 % add buffer for artifact removal
        % try randTs
        randTs = (maxTime-minTime) .* rand + minTime;
        iSurr = iSurr + 1;
        randSample = round(randTs * Fs);
        sampleRange = randSample:randSample + takeSamples - 1;
        surrLog(:,iSurr) = sampleRange;
        data(:,iSurr) = sevFilt(sampleRange);
    end
    disp('Done searching!');
    keepTrials = threshTrialData(data,zThresh);
    W_surr = calculateComplexScalograms_EnMasse(data(:,keepTrials(1:nSurr)),'Fs',Fs,'freqList',freqList);
    surrLog = surrLog(:,keepTrials(1:nSurr));
    tWindow_sample = round(tWindow * Fs);
    reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
    W_surr = W_surr(reshapeRange,:,:);
    surrLog = surrLog(reshapeRange,:) ./ Fs;
    W_pow = abs(W_surr).^2;

    ts = [];
    for jNeuron = find(strcmp(analysisConf.sessionNames,analysisConf.sessionNames(iNeuron)) == 1)'
        ts = [ts;all_ts{jNeuron}];
    end

    spectrumData = [];
    SDEs = [];
    for iTrial = 1:size(W_pow,2)
        spectrumData(iTrial,:) = squeeze(mean(W_pow(:,iTrial,:)));
        trialTs = ts(ts >= surrLog(1,iTrial) & ts < surrLog(end,iTrial));
        SDEs(iTrial,:) = mean(spikeDensityEstimate(trialTs,tWindow));
    end

    for iTrial = 1:size(W_pow,2)
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
[f,gof] = fit(avg_power,avg_firing,'poly1');
plot(f,avg_power,avg_firing);
hold on;
xlim([-2 2]);
ylim([-3 3]);
xticks(sort([0,xlim]));
yticks(sort([0,ylim]));
xlabel('power_z'); 
ylabel('FR_z');
title({'Manning Method, Broadband',['R^2 = ',num2str(gof.rsquare,4)]});
grid on;