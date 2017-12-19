iEvent = 4;
dirSelNeurons_criteria = zeros(size(pNeuronDiff,1),1);
dirSelNeuronsNO_test = false(size(pNeuronDiff,1),1);
pVal_minBins = 2;
pVal = 0.99;
for iNeuron = dirSelUsedNeurons
    curBins = squeeze(pNeuronDiff(iNeuron,iEvent,:));
    dirSelNeurons_contra_ntpIdx = movsum(curBins(analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
    dirSelNeurons_ipsi_ntpIdx = movsum(curBins(analyzeRange) < 1-pVal,[0 pVal_minBins-1]) == pVal_minBins;
    % exclude units already assigned as directional to a higher p-value
    dirSelNeurons_criteria(iNeuron) = sum(dirSelNeurons_contra_ntpIdx | dirSelNeurons_ipsi_ntpIdx);
    dirSelNeuronsNO_test(iNeuron) = any(dirSelNeurons_contra_ntpIdx | dirSelNeurons_ipsi_ntpIdx);
end

figuree(400,400);
colors = cool(10);
for ii = 1:10
    useIdx = find(dirSelNeurons_criteria == ii);
    plot(smooth(mean(squeeze(all_zscores(useIdx,4,:))),5),'LineWidth',lineWidth,'Color',colors(ii,:));
    hold on;
end

% plotPermDirNeurons = dirSelNeurons_criteria > 0 & dirSelNeurons_criteria < 5;
% plotPermDirNeurons = dirSelNeurons_criteria > 4;
% % for ii = 1:7
% %     plotPermDirNeurons = dirSelNeurons_criteria == ii;
% %     plotPermutations;
% % end

% %     plotPermDirNeurons = dirSelNeurons_pVals(ii_pVal,:);
% %     plotPermutations;
figuree(800,300);
criteriaCount = histcounts(dirSelNeurons_criteria,[-.5:max(dirSelNeurons_criteria)]);
bar(criteriaCount);
xtickangle(90);
ylabel('dir units');