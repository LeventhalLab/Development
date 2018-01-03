curEvent = 4;
pVal = 0.99;
pVal_minBins = 2;
dirSelDurations = zeros(size(pNeuronDiff,1),1);
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
            dirSelDurations(iNeuron) = sum(dirSelNeurons_contra_ntpIdx) + sum(dirSelNeurons_ipsi_ntpIdx);
        end
    end
end

neuronsShowingDirSel = sum(neuronDirFlags) / numel(dirSelUsedNeurons);

h = figure;
durationCounts = histcounts(dirSelDurations,linspace(0,max(dirSelDurations),10));
% bar(durationCounts);
boxplot(dirSelDurations(dirSelDurations > 0));
ylabel('Nose Out DirSel Duration (ms)');
ylimVals = [0 20];
ylim(ylimVals);
yticks([ylimVals(1):ylimVals(2)]);
yticklabels(yticks.*20);
grid on;

durationMed = median(dirSelDurations(dirSelDurations > 0));
durationStd = std(dirSelDurations(dirSelDurations > 0));
durationNonZero = numel(dirSelDurations(dirSelDurations > 0));

noteText = {['n = ',num2str(durationNonZero)],['median: ',num2str(durationMed,'%2.2f')],['std: ',num2str(durationStd,'%2.2f')]};
addNote(h,noteText);