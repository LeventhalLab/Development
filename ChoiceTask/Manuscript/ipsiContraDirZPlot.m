doSave = false;
doLabels = false;
doPrimSecArrows = true;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';

cmapPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/contra-ipsi-scale.jpg';
cmapColors = mycmap(cmapPath);

neuronCount = 0;
% % analyzeRange = 40:70; % from ipsiContraShuffle.m
sorted_all_matrixDiff = all_matrixDiff(sorted_neuronIds,:,:); % from heatmapUnitClass.m
sorted_all_matrixDiffZ = all_matrixDiffZ(sorted_neuronIds,:,:);
sorted_all_ntpIdx = all_ntpIdx(sorted_neuronIds,:,:); 
% % sorted_all_ntpIdx = all_ntpIdx_whole(sorted_neuronIds,:,:); % !!
sorted_dirSelNeurons = dirSelNeuronsNO(sorted_neuronIds);
sorted_primSec = primSec(sorted_neuronIds,:);

selected_dirSelNeurons = [];
selected_sorted_all_ntpIdx = [];
selected_sorted_primSec = [];
selected_sorted_all_matrixDiffZ = [];

for iNeuron = 1:size(sorted_all_matrixDiff,1)
    checkNaNs = squeeze(sorted_all_matrixDiff(iNeuron,:,:));
    checkNaNs = checkNaNs(:);
    if any(isnan(checkNaNs)) || numel(find(checkNaNs == 0)) > 500
        continue;
    end
    neuronCount = neuronCount + 1;
    key_212_to_366(neuronCount) = sorted_neuronIds(iNeuron);
    selected_dirSelNeurons(neuronCount) = sorted_dirSelNeurons(iNeuron);
    selected_sorted_all_ntpIdx(neuronCount) = sorted_all_ntpIdx(iNeuron);
    selected_sorted_primSec(neuronCount,:) = sorted_primSec(iNeuron,:);
    for iEvent = 1:size(sorted_all_matrixDiff,2)
% %         matrixDiffRef = squeeze(sorted_all_matrixDiff(iNeuron,1,:));
% %         all_matrixDiff_z(neuronCount,iEvent,:) = (matrixDiff - mean(matrixDiffRef)) ./ std(matrixDiffRef);
        selected_sorted_all_matrixDiffZ(neuronCount,iEvent,:) = squeeze(sorted_all_matrixDiffZ(iNeuron,iEvent,:));
    end
end
selected_dirSelNeurons = logical(selected_dirSelNeurons);
selected_sorted_all_ntpIdx_norm = normalize(selected_sorted_all_ntpIdx);

% % [v,k] = sort(selected_sorted_all_ntpIdx); % use to sort by Z-score

cols = 7;
rows = 1;
subplotMargins = [0.05 0.02];
caxisVals = [-3 3];
dirType = 1;
if dirType == 1
    dirTypeUnits = selected_dirSelNeurons;
else
    dirTypeUnits = ~selected_dirSelNeurons;
end
% caxisVals = [-1 1];
h = figuree(1200,sum(dirTypeUnits)/.75);
for iEvent = 1:cols
    hs(iEvent) = subplot_tight(rows,cols,iEvent,subplotMargins);
    % sorted_neuronIds might be useful, check order
    matrixDiff = squeeze(selected_sorted_all_matrixDiffZ(dirTypeUnits,iEvent,:));
    imagesc(matrixDiff);
    hold on;
    colormap(cmapColors);
    caxis(caxisVals);
    xticks([1 round(size(matrixDiff,2)/2) size(matrixDiff,2)]);
    if doLabels
        if iEvent == 1
            ylabel('units, sorted');
        end
        yticks([1 size(matrixDiff,1)]);
        yticklabels({});
        xticklabels({'-1','0','1'});
        xlabel('time (s)');
        title(eventFieldlabels{iEvent});
    else
        yticks([]);
    end
    box off
    grid on;
end

if doPrimSecArrows
    markerSize = 4;
    neuronCount = 0;
    for iNeuron = find(dirTypeUnits == 1)
        neuronCount = neuronCount + 1;
        if ~isnan(selected_sorted_primSec(iNeuron,1))
            subplot(hs(selected_sorted_primSec(iNeuron,1)));
            plot(markerSize-1,neuronCount,'>','MarkerFaceColor','k','MarkerEdgeColor','none','markerSize',markerSize); % class 1
        end
    end
end

if doSave
    tightfig;
    setFig('','',[2 1]);
    print(gcf,'-painters','-depsc',fullfile(figPath,['ipsiContraDirZPlot_',num2str(dirType),'.eps']));
    close(h);
end