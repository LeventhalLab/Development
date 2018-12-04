doSetup = true;
doMix = false;

freqList = logFreqList([1 200],50);
delta_ids = [closest(freqList,1) closest(freqList,4)];
theta_ids = [closest(freqList,4) closest(freqList,8)];
beta_ids = [closest(freqList,13) closest(freqList,30)];
gamma_ids = [closest(freqList,30) closest(freqList,70)];
gammah_ids = [closest(freqList,70) closest(freqList,200)];
narrow_ids = [delta_ids;theta_ids;beta_ids;gamma_ids;gammah_ids];
bandLabels = {'\delta','\theta','\beta','\gamma','\gamma_H','Broadband'};

tWindow = 0.5;
iEvent = 4;
oversampleBy = 3;
nSurr = 200;
zThresh = 5;

if doSetup
    avg_power = [];
    avg_firing = [];
    trialCount = 0;
    iSession = 0;

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
        if doMix
            surrLog = surrLog(:,randperm(nSurr));
        end
        W_pow = abs(W_surr).^2;

        ts = [];
        for jNeuron = find(strcmp(analysisConf.sessionNames,analysisConf.sessionNames(iNeuron)) == 1)'
            ts = [ts;all_ts{jNeuron}];
        end

        broadData = [];
        SDEs = [];
        narrowData = [];
        for iTrial = 1:size(W_pow,2)
            broadData(iTrial,:) = squeeze(mean(W_pow(:,iTrial,:)));
            for iFreq = 1:size(narrow_ids,1)
                narrowData(iFreq,iTrial) = mean(squeeze(mean(W_pow(:,iTrial,narrow_ids(iFreq,1):narrow_ids(iFreq,2)))));
            end
            trialTs = ts(ts >= surrLog(1,iTrial) & ts < surrLog(end,iTrial));
            SDEs(iTrial,:) = numel(trialTs);
        end
        broadMean = mean(broadData);
        broadStd = std(broadData);
        narrowMean = [];
        narrowStd = [];
        for iFreq = 1:size(narrow_ids,1)
            narrowMean(iFreq) = mean(narrowData(iFreq,:));
            narrowStd(iFreq) = std(narrowData(iFreq,:));
        end

        for iTrial = 1:size(W_pow,2)
            trialCount = trialCount + 1;

            for iFreq = 1:size(narrow_ids,1)
                avg_power(iFreq,trialCount) = (narrowData(iFreq,iTrial) - narrowMean(iFreq)) ./ narrowStd(iFreq);
            end

            y = (broadData(iTrial,:) - broadMean) ./ broadStd;
            x = 1:numel(freqList);
            brob = robustfit(x,y);
            avg_power(iFreq + 1,trialCount) = mean(brob(1)+brob(2)*x);
            avg_firing(trialCount,:) = (SDEs(iTrial) - mean(SDEs)) ./ std(SDEs);
        end
    end
end

rows = 2;
cols = size(avg_power,1);
ff(1400,600);
all_rho = [];
all_pval = [];
for iFreq = 1:cols
    subplot(rows,cols,prc(cols,[1,iFreq]));
    [x,k] = sort(avg_power(iFreq,:));
    yyaxis left;
    plot(avg_firing(k));
    ylim([-6 6]);
    yticks(sort([0,ylim]));
    ylabel('Z_{FR}');
    yyaxis right;
    plot(x,'lineWidth',2);
    ylabel('Z_{POWER}');
    xlim(size(x));
    ylim([-6 6]);
    xticks(xlim);
    yticks(sort([0,ylim]));
    xlabel('sorted trials');
    [rho,pval] = corr(x',avg_firing(k));
    all_rho(iFreq) = rho;
    all_pval(iFreq) = pval;
    title({bandLabels{iFreq},['rho = ',num2str(rho,3)],['pval = ',num2str(pval,3)]});
    
    subplot(rows,cols,prc(cols,[2,iFreq]));
    [f,gof] = fit(avg_power(iFreq,:)',avg_firing,'poly1');
    plot(f,avg_power(iFreq,:)',avg_firing);
    hold on;
    xlim([-2 2]);
    ylim([-3 3]);
    xticks(sort([0,xlim]));
    yticks(sort([0,ylim]));
    xlabel('Z_{POWER}');
    ylabel('Z_{FR}');
    title(['R^2 = ',num2str(gof.rsquare,3)]);
    grid on;
end
set(gcf,'color','w');

if doMix
    all_rho_mix = all_rho;
    all_pval_mix = all_pval;
end

ff(400,300);
bar(all_rho,'k');
hold on;
bar(all_rho_mix,'r');
xticklabels(bandLabels);
ylabel('rho');
ylim([-.05 .3]);
yticks(sort([0,ylim]));
for ii = 1:numel(all_pval)
    if all_pval < 0.05
        pval_text = '*';
    else
        pval_text = 'N.S.';
    end
    text(ii,abs(all_rho(ii)) + 0.02,pval_text,'color','k','horizontalAlignment','center');
end
for ii = 1:numel(all_pval)
    if all_pval_mix < 0.05
        pval_text = '*';
    else
        pval_text = 'N.S.';
    end
    text(ii,-abs(all_rho(ii)) - 0.02,pval_text,'color','r','horizontalAlignment','center');
end
title('Manning Method Power-Freq Corr');
legend({'no shuffle','ts shuffled'},'location','northwest')
set(gcf,'color','w');