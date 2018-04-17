all_matrixDiff_z = [];
all_matrixDiff_abs = [];
neuronCount = 0;
sorted_all_matrixDiff = all_matrixDiff(sorted_neuronIds,:,:);
sorted_dirSelNeurons = dirSelNeuronsNO_01(sorted_neuronIds);
selected_dirSelNeurons = [];

for iNeuron = 1:size(sorted_all_matrixDiff,1)
    checkNaNs = squeeze(sorted_all_matrixDiff(iNeuron,:,:));
    checkNaNs = checkNaNs(:);
    if any(isnan(checkNaNs)) || numel(find(checkNaNs == 0)) > 500
        continue;
    end
    neuronCount = neuronCount + 1;
    selected_dirSelNeurons(neuronCount) = sorted_dirSelNeurons(iNeuron);
    for iEvent = 1:size(sorted_all_matrixDiff,2)
        matrixDiffRef = squeeze(sorted_all_matrixDiff(iNeuron,1,:));
        matrixDiff = squeeze(sorted_all_matrixDiff(iNeuron,iEvent,:));
        all_matrixDiff_z(neuronCount,iEvent,:) = (matrixDiff - mean(matrixDiffRef)) ./ std(matrixDiffRef);
        all_matrixDiff_abs(neuronCount,iEvent,:) = matrixDiff;
    end
end

selected_dirSelNeurons = logical(selected_dirSelNeurons);
cmapPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Resubmission/contra-ipsi-scale.jpg';
cmapColors = mycmap(cmapPath);

figuree(1100,500);
event_maxUnsigned = NaN(7,size(all_matrixDiff_abs,1));
event_maxSigned = NaN(7,size(all_matrixDiff_abs,1));
event_maxUnsignedZ = NaN(7,size(all_matrixDiff_abs,1));
event_maxSignedZ = NaN(7,size(all_matrixDiff_abs,1));
colors = lines(2);

for iEvent = 1:7
    for iNeuron = 1:size(all_matrixDiff_abs,1)
        matrixDiff = squeeze(all_matrixDiff_abs(iNeuron,iEvent,:));
        [v,k] = max(abs(matrixDiff));
        event_maxSigned(iEvent,iNeuron) = matrixDiff(k); % signed value
        event_maxUnsigned(iEvent,iNeuron) = v; % signed value
        
        matrixDiff = squeeze(all_matrixDiff_z(iNeuron,iEvent,:));
        [v,k] = max(abs(matrixDiff));
        event_maxSignedZ(iEvent,iNeuron) = matrixDiff(k); % signed value
        event_maxUnsignedZ(iEvent,iNeuron) = v; % signed value
    end
    subplot(4,7,iEvent);
    binEdges = -1:.1:1;
    counts = histcounts(event_maxSigned(iEvent,selected_dirSelNeurons),binEdges);
    bar(counts,'r'); % dirSel
    hold on;
    counts = histcounts(event_maxSigned(iEvent,~selected_dirSelNeurons),binEdges);
    bar(counts,'k'); % ~dirSel
    xlim(size(counts));
    xticks([1 round(numel(counts)/2) numel(counts)]);
    xticklabels({'ipsi','0','contra'});
    ylim([0 30]);
    grid on;
    title('raw SI, +/-');
    
    subplot(4,7,iEvent+7);
    binEdges = 0:.05:1;
    counts = histcounts(event_maxUnsigned(iEvent,selected_dirSelNeurons),binEdges);
    bar(counts,'r');
    hold on;
    counts = histcounts(event_maxUnsigned(iEvent,~selected_dirSelNeurons),binEdges);
    bar(counts,'k');
    xlim(size(counts));
    xticks([1 numel(counts)]);
    xticklabels({'0','1'});
    ylim([0 30]);
    grid on;
    title('raw SI, only +');
    
    subplot(4,7,iEvent+14);
    binEdges = -10:1:10;
    counts = histcounts(event_maxSignedZ(iEvent,selected_dirSelNeurons),binEdges);
    bar(counts,'r');
    hold on;
    counts = histcounts(event_maxSignedZ(iEvent,~selected_dirSelNeurons),binEdges);
    bar(counts,'k');
    xlim(size(counts));
    xticks([1 round(numel(counts)/2) numel(counts)]);
    xticklabels({'ipsi','0','contra'});
    ylim([0 80]);
    grid on;
    title('Z SI, +/-');
    
    subplot(4,7,iEvent+21);
    binEdges = 0:.5:10;
    counts = histcounts(event_maxUnsignedZ(iEvent,selected_dirSelNeurons),binEdges);
    bar(counts,'r');
    hold on;
    counts = histcounts(event_maxUnsignedZ(iEvent,~selected_dirSelNeurons),binEdges);
    bar(counts,'k');
    xlim(size(counts));
    xticks([1 numel(counts)]);
    xticklabels({'0','10'});
    ylim([0 80]);
    grid on;
    title('Z SI, only +');
end

cols = 7;
rows = 1;
caxisVals = [-10 10];
% caxisVals = [-1 1];
figuree(1400,400);
for iEvent = 1:cols
    subplot(rows,cols,iEvent);
    % sorted_neuronIds might be useful, check order
    matrixDiff = squeeze(all_matrixDiff_z(:,iEvent,:)); 
    imagesc(matrixDiff);
    colormap(cmapColors);
    caxis(caxisVals);
    if iEvent == 1
        ylabel('units, sorted');
    end
    yticks([1 size(all_matrixDiff_z,1)]);
    yticklabels({});
    xticks([1 round(size(all_matrixDiff_z,3)/2) size(all_matrixDiff_z,3)]);
    xticklabels({'-1','0','1'});
    xlabel('time (s)');
    title(eventFieldlabels{iEvent});
    grid on;
end
set(gcf,'color','w');
tightfig;