iEvent = 4;
dirSelNeurons_criteria = zeros(size(pNeuronDiff,1),1);
criteriaCount = [];
xLabels = {};
    
for iNeuron = dirSelUsedNeurons
    dirSelNeurons_contra_ntpIdx = movsum(curBins(analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
    dirSelNeurons_ipsi_ntpIdx = movsum(curBins(analyzeRange) < 1-pVal,[0 pVal_minBins-1]) == pVal_minBins;
    % exclude units already assigned as directional to a higher p-value
    dirSelNeurons_criteria(iNeuron) = sum(dirSelNeurons_contra_ntpIdx | dirSelNeurons_ipsi_ntpIdx);
end

% %     plotPermDirNeurons = dirSelNeurons_pVals(ii_pVal,:);
% %     plotPermutations;
figuree(800,300);
plot(criteriaCount);
xtickangle(90);
ylabel('dir units');
ylim([0 max(criteriaCount)+10]);