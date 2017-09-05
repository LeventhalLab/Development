rows = 3;
if true
    % % figuree(500,800);
    all_ttfs = [];
    all_curMTz = [];
    all_curMT = [];
    neuronCount = 1;
    trialCount = 1;
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron};
        if ~dirSelNeurons(iNeuron) || isempty(unitEvents{iNeuron}.class) || unitEvents{iNeuron}.class(1) ~= 4%|| ~strcmp(analysisConf.sessionNames{81},analysisConf.sessionNames{iNeuron})
            continue;
        end
        disp(['Using neuron ',num2str(iNeuron),' - ',neuronName]);

        curTrials = all_trials{iNeuron};
        [useTrials,allTimes] = sortTrialsBy(curTrials,'MT');
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
        contraPeths = tsPeths(1:markContraTrials,:);
        contraMTs = allTimes(1:markContraTrials);

        % % figure;
        % % plotSpikeRaster(contraPeths(:,4),'PlotType','scatter','AutoLabel',false);
        ttfs = [];
        meanISI = [];
        curMTz = [];
        for iTrial = 1:numel(contraPeths(:,4))
            curTs = contraPeths{iTrial,4};
            curRefTs = contraPeths{iTrial,1};
            if numel(curTs) < 5 || numel(curRefTs) < 5; continue; end;
            
            curRefMeanISI = mean(diff(curRefTs));
            curRefStdISI = std(diff(curRefTs));

            curMT = contraMTs(iTrial);
            curMTTs = curTs(curTs >= 0 & curTs < curMT);
            if numel(curMTTs) < 3; continue; end;

            ttfs(iTrial) = mean(curTs(find(curTs >= 0,2)));
            meanISI(iTrial) = mean(diff(curMTTs));

    %         MTSpikesPerSec = (1 / curMT) * numel(curMTTs);
            curMTz(iTrial) = meanISI(iTrial) / curRefMeanISI;
            all_curMTz(trialCount) = curMTz(iTrial);
            all_curMT(trialCount) = curMT;
            all_ttfs(trialCount) = ttfs(iTrial);
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
[all_curMT_sorted,k] = sort(all_curMT);
% figure;
% plot(all_curMTz(k))
figure; plot(all_curMT_sorted,all_curMTz(k));

binSteps = 0.1;
maxBin = 1;
mtBins = 0:binSteps:maxBin-binSteps;
bin_mean = [];
bin_std = [];
for iBin = 1:numel(mtBins)
    allBinVals = all_curMTz(all_curMT >= mtBins(iBin) & all_curMT < mtBins(iBin) + binSteps);
    bin_mean(iBin) = nanmedian(allBinVals);
    bin_std(iBin) = nanstd(allBinVals);
end
figure;
errorbar(bin_mean,bin_std);
xlim([0 11]);