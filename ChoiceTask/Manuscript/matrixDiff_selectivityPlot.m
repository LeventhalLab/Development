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

% % binEdges = 0:.1:1;
% % figure;
% % noseOut_SIs = selected_sorted_all_ntpIdx_norm(find(selected_sorted_primSec(:,1) == 4));
% % noseOut_counts = histcounts(noseOut_SIs,binEdges);
% % 
% % hold on;
% % tone_SIs = selected_sorted_all_ntpIdx_norm(find(selected_sorted_primSec(:,1) == 3));
% % tone_counts = histcounts(tone_SIs,binEdges);
% % bar([tone_counts;noseOut_counts]');
% % 
% % xlabel('SI');
% % xticks(1:numel(binEdges));
% % xticklabels(binEdges);

if false
    dataZ = {};
    dataBins = {};
    for iEvent = 1:7
        eventIdxs = find(selected_sorted_primSec(:,1) == iEvent);
        eventZs = squeeze(selected_sorted_all_matrixDiffZ(eventIdxs,4,analyzeRange));
        eventZs_AUC = trapz((eventZs'));
        dataZ{iEvent} = eventZs_AUC;
        dataBins{iEvent} = selected_sorted_all_ntpIdx_norm(eventIdxs);
    end
    figuree(500,600);
    subplot(211);
    plotSpread(dataZ,'showMM',3); % median
    title('AUC contra-ipsi Z-score');
    subplot(212);
    plotSpread(dataBins,'showMM',3); % median
    title('Normalized Bin Count p < 0.01')
end

if true
    toneIdxs = find(selected_sorted_primSec(:,1) == 3);
    noIdxs = find(selected_sorted_primSec(:,1) == 4);
    
    toneIdxs = find(selected_dirSelNeurons==0);
    noIdxs = find(selected_dirSelNeurons==1);
% %     toneIdxs = [find(selected_sorted_primSec(:,1) == 3);find(selected_sorted_primSec(:,2) == 3)];
%     noIdxs = [find(selected_sorted_primSec(:,1) == 4);find(selected_sorted_primSec(:,1) == 6)];

    y = [selected_sorted_all_ntpIdx_norm(toneIdxs) selected_sorted_all_ntpIdx_norm(noIdxs)];
    group = [ones(1,numel(toneIdxs)) ones(1,numel(noIdxs))*2];
    p = anova1(y,group);
    xticklabels({'Tone','Nose Out + Side Out'});
    title('SI based on existing criteria (bins)');

    toneZ = squeeze(selected_sorted_all_matrixDiffZ(toneIdxs,4,analyzeRange));
    noZ = squeeze(selected_sorted_all_matrixDiffZ(noIdxs,4,analyzeRange));
    toneAOC = trapz(abs(toneZ'));
    noAOC = trapz(abs(noZ'));
    y = [toneAOC noAOC];
    group = [ones(1,numel(toneAOC)) ones(1,numel(noAOC))*2];
    p = anova1(y,group);
    xticklabels({'Tone','Nose Out + Side Out'});
    title('SI based on contra-ipsi Z-score area');
end

% % figure;
% % plot(selected_sorted_all_ntpIdx);
% % hold on;
% % plot(find(selected_dirSelNeurons == 1),selected_sorted_all_ntpIdx(find(selected_dirSelNeurons == 1)),'ro');

cmapPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Resubmission/contra-ipsi-scale.jpg';
cmapColors = mycmap(cmapPath);

event_maxUnsigned = NaN(7,size(all_matrixDiffZ,1));
event_maxSigned = NaN(7,size(all_matrixDiffZ,1));
event_maxUnsignedZ = NaN(7,size(all_matrixDiffZ,1));
event_maxSignedZ = NaN(7,size(all_matrixDiffZ,1));
colors = lines(2);

% % for iEvent = 1:7
% %     for iNeuron = 1:size(all_matrixDiff_z,1)
% %         matrixDiff = squeeze(all_matrixDiff_z(iNeuron,iEvent,:));
% %         [v,k] = max(abs(matrixDiff));
% %         event_maxSigned(iEvent,iNeuron) = matrixDiff(k); % signed value
% %         event_maxUnsigned(iEvent,iNeuron) = v; % signed value
% %         
% %         matrixDiff = squeeze(all_matrixDiff_z(iNeuron,iEvent,:));
% %         [v,k] = max(abs(matrixDiff));
% %         event_maxSignedZ(iEvent,iNeuron) = matrixDiff(k); % signed value
% %         event_maxUnsignedZ(iEvent,iNeuron) = v; % signed value
% %     end
% % end


[v,k] = sort(selected_sorted_all_ntpIdx);

cols = 7;
rows = 4;
caxisVals = [-5 5];
% caxisVals = [-1 1];
figuree(1400,400);
for iEvent = 1:cols
    subplot(rows,cols,iEvent);
    % sorted_neuronIds might be useful, check order
    matrixDiff = squeeze(selected_sorted_all_matrixDiffZ(:,iEvent,:));
    imagesc(matrixDiff);
    colormap(cmapColors);
    caxis(caxisVals);
    if iEvent == 1
        ylabel('units, sorted');
    end
    yticks([1 size(all_matrixDiffZ,1)]);
    yticklabels({});
    xticks([1 round(size(all_matrixDiffZ,3)/2) size(all_matrixDiffZ,3)]);
    xticklabels({'-1','0','1'});
    xlabel('time (s)');
    title(eventFieldlabels{iEvent});
    grid on;
    
    
    subplot(rows,cols,iEvent + 7);
    imagesc(matrixDiff(k,:));
    colormap(cmapColors);
    caxis(caxisVals);
    if iEvent == 1
        ylabel('units, sorted');
    end
    yticks([1 size(all_matrixDiffZ,1)]);
    yticklabels({});
    xticks([1 round(size(all_matrixDiffZ,3)/2) size(all_matrixDiffZ,3)]);
    xticklabels({'-1','0','1'});
    xlabel('time (s)');
    title('sorted by SI');
    grid on;
    
    % tone NO
    subplot(rows,cols,iEvent + 14);
    imagesc(matrixDiff(toneIdxs,:));
    colormap(cmapColors);
    caxis(caxisVals);
    if iEvent == 1
        ylabel('units, sorted');
    end
    yticks([1 size(all_matrixDiffZ,1)]);
    yticklabels({});
    xticks([1 round(size(all_matrixDiffZ,3)/2) size(all_matrixDiffZ,3)]);
    xticklabels({'-1','0','1'});
    xlabel('time (s)');
    title('tone');
    grid on;
    
    subplot(rows,cols,iEvent + 21);
    imagesc(matrixDiff(noIdxs,:));
    colormap(cmapColors);
    caxis(caxisVals);
    if iEvent == 1
        ylabel('units, sorted');
    end
    yticks([1 size(all_matrixDiffZ,1)]);
    yticklabels({});
    xticks([1 round(size(all_matrixDiffZ,3)/2) size(all_matrixDiffZ,3)]);
    xticklabels({'-1','0','1'});
    xlabel('time (s)');
    title('nose out');
    grid on;
end

figure;
plot(mean(abs(matrixDiff(selected_dirSelNeurons,:))),'r','linewidth',2);
hold on
plot(mean(abs(matrixDiff(~selected_dirSelNeurons,:))),'k','linewidth',2);
grid on

set(gcf,'color','w');
tightfig;

X = repmat(1:size(matrixDiff,2),[size(matrixDiff,1) 1]);
X = repmat(1:size(matrixDiff,2),[size(matrixDiff,1) 1]);
Z = matrixDiff;
figure;
plot3(Z);