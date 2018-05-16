curEvent = 4;
pVal = 0.99;
pVal_minBins = 2;
dirSelDurations_contra = zeros(size(pNeuronDiff,1),1);
dirSelDurations_ipsi = dirSelDurations_contra;
neuronDirFlags = zeros(size(pNeuronDiff,1),1);
for iEvent = 1:7
    for iNeuron = dirSelUsedNeurons
        curBins = squeeze(pNeuronDiff(iNeuron,curEvent,:));
        neuronSigEvent_pos = (curBins > pVal)';
        neuronSigEvent_neg = (curBins < 1-pVal)';
        neuronDirFlags(iNeuron) = neuronDirFlags(iNeuron) | any(neuronSigEvent_pos) | any(neuronSigEvent_neg);
        
        if iEvent == 4
            dirSelNeurons_contra_ntpIdx = movsum(curBins(analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
            dirSelNeurons_ipsi_ntpIdx = movsum(curBins(analyzeRange) < 1-pVal,[0 pVal_minBins-1]) == pVal_minBins;
            % add back bins following detection to quantify time spent
            % directional
            contra_durations = (sum(dirSelNeurons_contra_ntpIdx) + sum(diff(dirSelNeurons_contra_ntpIdx) == -1) * pVal_minBins);
            dirSelDurations_contra(iNeuron) = contra_durations;
            ipsi_durations = (sum(dirSelNeurons_ipsi_ntpIdx) + sum(diff(dirSelNeurons_ipsi_ntpIdx) == -1) * pVal_minBins);
            dirSelDurations_ipsi(iNeuron) = ipsi_durations;
        end
    end
end

neuronsShowingDirSel = sum(neuronDirFlags) / numel(dirSelUsedNeurons);

h = figuree(600,600);
dirSelDurations = dirSelDurations_contra;
titleLabel = 'Contra';
allMTs = [];
for iNeuron = 1:numel(all_trials)
    if ismember(iNeuron,excludeUnits)
        continue;
    end
    curTrials = all_trials{iNeuron};
    [useTrials,allTimes] = sortTrialsBy(curTrials,'MT');
    allMTs = [allMTs allTimes];
end
medMT = median(allMTs)*1000; %ms
for ii = 1:3
    subplot(2,3,ii);
    if ii == 2
        dirSelDurations = dirSelDurations_ipsi;
        titleLabel = 'Ipsi';
    elseif ii == 3
        dirSelDurations = dirSelDurations_contra + dirSelDurations_ipsi;
        titleLabel = 'Both (summed)';
    end
    % bar(durationCounts);
    boxplot(dirSelDurations(dirSelDurations > 0)); % !!! 0 = no directional selectivity, exclude!
    xticks([]);
    ylabel('Nose Out DirSel Duration (ms)');
    ylimVals = [0 30];
    ylim(ylimVals);
    yticks([ylimVals(1):5:ylimVals(2)]);
    yticklabels(yticks.*binMs);
    grid on;
    title(titleLabel);
    durationMed = median(dirSelDurations(dirSelDurations > 0)) * binMs;
    durationStd = std(dirSelDurations(dirSelDurations > 0)) * binMs;
    durationNonZero = numel(dirSelDurations(dirSelDurations > 0));

    noteText = {['n = ',num2str(durationNonZero)],['median: ',num2str(durationMed,'%2.2f'),' ms'],['std: ',num2str(durationStd,'%2.2f'),' ms']};
    text(1,-4,noteText);
    
    subplot(2,3,ii+3);
    durationCounts = histcounts(dirSelDurations(dirSelDurations > 0),0:ylimVals(2)+0.5);
    fractionUnderMT = sum(dirSelDurations(dirSelDurations > 0) < medMT/binMs) / sum(dirSelDurations > 0);
    bar(durationCounts);
    hold on;
    xticks([ylimVals(1):5:ylimVals(2)]);
    xticklabels(xticks * binMs);
    xlim(ylimVals);
    xtickangle(45);
    xlabel('Time (ms)');
    ylabel('units/bin');
    ylim([0 30]);
    yticks(ylim);
    grid on;
    plot([medMT/binMs medMT/binMs],ylim,'r:');
    text(medMT/binMs,20,['\leftarrow median MT (',num2str(medMT),')']);
    plot([durationMed/binMs durationMed/binMs],ylim,'r-');
    text(durationMed/binMs,25,'\leftarrow median dirSel');
    title([num2str(fractionUnderMT*100,'%2.2f'),'% of units < MT']);
end