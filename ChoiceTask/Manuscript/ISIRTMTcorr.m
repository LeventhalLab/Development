timingField = 'MT';
useEventPeth = 4;
plotBySubject = false;

if plotBySubject
    nSubjects = numel(analysisConf.subjects);
else
    nSubjects = 1;
end

if true
    tWindow = 1;
    binMs = 50;
    binS = binMs / 1000;
    nBins_tWindow = [-tWindow:binS:tWindow];
    all_curUseTime_sorted = [];
    allSubject_trialCount = 1;
    k = [];
    allRasters = {};
    all_z = [];
    for iSubject = 1:nSubjects
        all_curUseTime = [];
        trialCount = 1;
        useSubject = analysisConf.subjects{iSubject};
        for iNeuron = 1:numel(analysisConf.neurons)
            if plotBySubject && ~strcmp(analysisConf.sessionConfs{iNeuron}.subjects__name,useSubject)
                continue;
            end

            neuronName = analysisConf.neurons{iNeuron};
    % %         if ~dirSelNeurons(iNeuron) %|| ~strcmp(analysisConf.sessionNames{81},analysisConf.sessionNames{iNeuron})
    % %             continue;
    % %         end

            if isempty(unitEvents{iNeuron}.class) || unitEvents{iNeuron}.class(1) ~= 4
                continue;
            end
            disp(['Using neuron ',num2str(iNeuron),' - ',neuronName]);

            curTrials = all_trials{iNeuron};
            [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
            trialIdInfo = organizeTrialsById(curTrials);

            t_useTrials = [];
            t_allTimes = [];
            tc = 1;
            for iTrial = 1:numel(useTrials)
                if ismember(useTrials(iTrial),trialIdInfo.correctContra)
                    t_useTrials(tc) = useTrials(iTrial);
                    t_allTimes(tc) = allTimes(iTrial);
                    tc = tc + 1;
                end
            end
            markContraTrials = tc - 1;
            for iTrial = 1:numel(useTrials)
                if ismember(useTrials(iTrial),trialIdInfo.correctIpsi)
                    t_useTrials(tc) = useTrials(iTrial);
                    t_allTimes(tc) = allTimes(iTrial);
                    tc = tc + 1;
                end
            end
            useTrials = t_useTrials;
            allTimes = t_allTimes;

            tsPeths = {};
            ts = all_ts{iNeuron};
            [zMean,zStd] = zParams(ts,binMs);
            tsPeths = eventsPeth(curTrials(useTrials),ts,tWindow,eventFieldnames);
            usePeths = tsPeths;
            useTimes = allTimes;
    %         usePeths = tsPeths(1:markContraTrials,:);
    %         useTimes = allTimes(1:markContraTrials);

            meanISI = [];
            curZ = [];
            for iTrial = 1:numel(useTimes)
                curTs = usePeths{iTrial,useEventPeth};
                curRefTs = usePeths{iTrial,1};
                if numel(curTs) < 5 || numel(curRefTs) < 5; continue; end;
                
                counts = histcounts(curTs,nBins_tWindow);
                curZ = smooth((counts - zMean) / zStd,3);
                all_z(allSubject_trialCount,:) = curZ;
                
                curUseTime = useTimes(iTrial);

                curAllTimeTs = curTs(curTs >= 0 & curTs < curUseTime);
                if numel(curAllTimeTs) < 4; continue; end;

                ttfs(iTrial) = mean(curTs(find(curTs >= 0,1)));
                all_curUseTime(trialCount) = curUseTime;
                allRasters{allSubject_trialCount} = curTs;
                trialCount = trialCount + 1;
                allSubject_trialCount = allSubject_trialCount + 1;
            end
        end
        % compile from per-subject
        [vs,ks] = sort(all_curUseTime);
        all_curUseTime_sorted = [all_curUseTime_sorted vs];
        k = [k ks];
    end
end
% [all_curUseTime_sorted,k] = sort(all_curUseTime);




% figure;
% plot(all_curUseTime_sorted,smooth(all_ttfs(k),10));
% xlim([0 1]);
% title([timingField,' ttfs']);
% 
% [RHO,PVAL] = corr(all_curUseTime',all_ttfs')
% [f,gof] = fit(all_curUseTime',all_ttfs','poly1')


all_curUseTime_sorted_desc = fliplr(all_curUseTime_sorted);
all_ttfs_sorted_desc = fliplr(all_ttfs(k));
loopCount = 0;
binCount = 1;
time_bins = [];
bin_curTime = [];
time_ttfs = [];
tally_ttfsVals = [];
groupEvery = 100;
for iCurTime = 1:numel(all_curUseTime_sorted_desc)
    if loopCount == 100
        time_bins(binCount) = all_curUseTime_sorted_desc(iCurTime);
        time_ttfs(binCount) = mean(tally_ttfsVals);
        bin_curTime(binCount) = iCurTime;
        tally_ttfsVals = [];
        binCount = binCount + 1;
        loopCount = 0;
    end
    tally_ttfsVals = [tally_ttfsVals all_ttfs_sorted_desc(iCurTime)];
    loopCount = loopCount + 1;
end

% figure;
% plot(time_bins,time_ttfs);
% title([timingField,' ttfs']);

% % [RHO,PVAL] = corr(time_bins',time_ttfs')
% % [f,gof] = fit(time_bins',time_ttfs','poly1')


h = figuree(800,500);
subplot(131);
barh(all_curUseTime_sorted_desc,'FaceColor','k','EdgeColor','none');
ylim([1 numel(all_curUseTime_sorted_desc)]);
xlim([0 1]);
xlabel('time (s)');
title([timingField]);
ylabel('trials');

subplot(132);
allRasters_sorted = allRasters(k);
plotSpikeRaster(allRasters_sorted,'PlotType','scatter','AutoLabel',false); hold on;
plot([0 0],[1 numel(allRasters_sorted)],'r:');
xlimVals = [-1 1];
xlim(xlimVals);
xlabel('time (s)');
title([timingField,' spikes']);

nMeanBins = 31;
meanColors = jet(nMeanBins);
meanBins = floor(linspace(1,numel(allRasters_sorted),nMeanBins));
all_z_sorted = all_z(k,:);
mean_z = [];
tMean = linspace(-1,1,size(all_z_sorted,2));
for iBin = 1:numel(meanBins)-1
    mean_z(iBin,:) = smooth(mean(all_z_sorted(meanBins(iBin):meanBins(iBin+1),:)),3);
    makey = (meanBins(iBin) + round(mean(diff(meanBins)))) + 250 * mean_z(iBin,:) * -0.8; % -1 for orientation
    plot(tMean,makey,'linewidth',2,'color',[meanColors(iBin,:),0.5]);
end

subplot(133);
imagesc(all_z_sorted);
colormap(jet);
xticks([1 10 20 30 40]);
xticklabels({'-1','-0.5','0','0.5','1'});
caxis([-1 3]);


figure;
plot(all_z_sorted,all_curUseTime_sorted,'k.');

% % barh(all_ttfs_sorted_desc,'FaceColor','k','EdgeColor','none');
% % hold on;
% % plot(time_ttfs,bin_curTime,'r','LineWidth',3);
% % ylim([1 numel(all_curUseTime_sorted_desc)]);
% % xlim([0 0.1]);
% % xlabel('time (s)');
% % title([timingField,' ttfs']);

% addNote(h,{'ttfs 100 bins','---',['corr = ',num2str(RHO)],['p = ',num2str(PVAL)],['R2 = ',num2str(gof.rsquare)]});

% % binSteps = 0.3;
% % maxBin = 1;
% % mtBins = 0:binSteps:maxBin-binSteps;
% % bin_mean = [];
% % bin_std = [];
% % for iBin = 1:numel(mtBins)
% %     allBinVals = all_curMTz(all_curMT >= mtBins(iBin) & all_curMT < mtBins(iBin) + binSteps);
% %     bin_mean(iBin) = nanmedian(allBinVals);
% %     bin_std(iBin) = nanstd(allBinVals);
% % end
% % figure;
% % errorbar(bin_mean,bin_std);
% % xlim([0 11]);

% lowRTz = median(all_curMTz(all_curMT < .3))
% highRTz = median(all_curMTz(all_curMT >= .3))