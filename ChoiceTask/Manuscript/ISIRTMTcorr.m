rows = 3;
timingField = 'RT';
useEventPeth = 4;

if true
    % % figuree(500,800);
    all_ttfs = [];
    all_curUseTime = [];
    neuronCount = 1;
    trialCount = 1;
    allRasters = {};
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron};
% %         if ~dirSelNeurons(iNeuron) %|| ~strcmp(analysisConf.sessionNames{81},analysisConf.sessionNames{iNeuron})
% %             continue;
% %         end

        if isempty(unitEvents{iNeuron}.class) || unitEvents{iNeuron}.class(1) ~= 4
            continue;
        end
%         disp(['Using neuron ',num2str(iNeuron),' - ',neuronName]);

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
        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
        usePeths = tsPeths;
        useTimes = allTimes;
%         usePeths = tsPeths(1:markContraTrials,:);
%         useTimes = allTimes(1:markContraTrials);

        % % figure;
        % % plotSpikeRaster(contraPeths(:,4),'PlotType','scatter','AutoLabel',false);
        ttfs = [];
        meanISI = [];
        curZ = [];
        for iTrial = 1:numel(useTimes)
            curTs = usePeths{iTrial,useEventPeth};
            curRefTs = usePeths{iTrial,1};
            if numel(curTs) < 5 || numel(curRefTs) < 5; continue; end;
            
            curRefMeanISI = mean(diff(curRefTs));
            curRefStdISI = std(diff(curRefTs));
            curUseTime = useTimes(iTrial);
            
            curAllTimeTs = curTs(curTs >= 0 & curTs < curUseTime);
            if numel(curAllTimeTs) < 4; continue; end;

            ttfs(iTrial) = mean(curTs(find(curTs >= 0,1)));
            all_curUseTime(trialCount) = curUseTime;
            all_ttfs(trialCount) = ttfs(iTrial);
            allRasters{trialCount} = curTs;
            trialCount = trialCount + 1;
        end

    % %     subplot(rows,1,1);
    % %     plot(ttfs); hold on;
    % %     xlim([1 numel(contraMTs)]);
    % %     title('time to first spike');
    % %     xlabel('trial');
    % % 
    % %     subplot(rows,1,2);
    % %     plot(meanISI); hold on;
    % %     xlim([1 numel(contraMTs)]);
    % %     title('mean ISI within MT');
    % %     xlabel('trial');
    % %     
    % %     subplot(rows,1,3);
    % %     plot(curMTz); hold on;
    % %     xlim([1 numel(contraMTs)]);
    % %     title('curMTz');
    % %     xlabel('trial');

        neuronCount = neuronCount + 1;
    end
end
[all_curUseTime_sorted,k] = sort(all_curUseTime);




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

[RHO,PVAL] = corr(time_bins',time_ttfs')
[f,gof] = fit(time_bins',time_ttfs','poly1')


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
plot([0 0],[1 numel(all_ttfs_sorted_desc)],'r');
xlim([-.5 .5]);
xlabel('time (s)');
title([timingField,' spikes']);

subplot(133);
barh(all_ttfs_sorted_desc,'FaceColor','k','EdgeColor','none');
hold on;
plot(time_ttfs,bin_curTime,'r','LineWidth',3);
ylim([1 numel(all_curUseTime_sorted_desc)]);
xlim([0 0.1]);
xlabel('time (s)');
title([timingField,' ttfs']);

addNote(h,{'ttfs 100 bins','---',['corr = ',num2str(RHO)],['p = ',num2str(PVAL)],['R2 = ',num2str(gof.rsquare)]});

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