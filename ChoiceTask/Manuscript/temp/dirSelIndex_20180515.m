% % load('pNeuronDiff.mat');
% % load('contraIpsiZHistogramVars.mat');
% tRange = [-0.2,0.4];
% analyzeRange = 50 + round(tRange * 50);
% get max magnitude Z within analyzeRange

doSave = true;
doLabels = false;

figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';

%%  CALCULATING THE SELECTIVITY INDEX
pCutoff = 0.01;
iEvent = 4;
unitIDs = cell(1,2);
unitIDs{1} = dirSelUnitIds;
unitIDs{2} = ndirSelUnitIds;
zDiff = cell(1,2);
p_values = cell(1,2);
abs_zDiff_sum = cell(1,2);
abs_zDiff_mean = cell(1,2);
zDiff_sum = cell(1,2);
zDiff_mean = cell(1,2);
for iType = 1 : 2
    zDiff{iType} = squeeze(all_matrixDiffZ(unitIDs{iType},iEvent,:));
    p_values{iType} = squeeze(pNeuronDiff(unitIDs{iType},iEvent,:));
    
    [abs_zDiff_sum{iType},abs_zDiff_mean{iType},zDiff_sum{iType},zDiff_mean{iType}] = ...
        integrate_over_significant_regions(zDiff{iType},p_values{iType},analyzeRange, 'pcutoff',pCutoff);
    
    sig_p_idx{iType} = zeros(size(p_values{iType},1),size(p_values{iType},2),3);
    sig_p_idx{iType}(:,:,1) = (p_values{iType} < pCutoff);
    sig_p_idx{iType}(:,:,2) = (p_values{iType} > (1-pCutoff));
    sig_p_idx{iType}(:,:,3) = squeeze(sig_p_idx{iType}(:,:,1)) | squeeze(sig_p_idx{iType}(:,:,2));

end

%%
% figure out whether individual units are ipsi-selective, contra-selective,
% or both


%%    ASSEMBLING THE DATA TO MAKE THE HISTOGRAMS
% binEdges = -10.5 : 2 : 10.5;
% binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;

binEdges = -11 : 2 : 11;
binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;

NzDiff_sum = zeros(2, 3, length(binEdges) - 1);
NzDiff_sum_abs = zeros(2, 3, length(binEdges) - 1);
NzDiff_mean = zeros(2, 3, length(binEdges) - 1);
NzDiff_mean_abs = zeros(2, 3, length(binEdges) - 1);

fract_zDiff_sum = zeros(2, 3, length(binEdges) - 1);
fract_zDiff_sum_abs = zeros(2, 3, length(binEdges) - 1);
fract_zDiff_mean = zeros(2, 3, length(binEdges) - 1);
fract_zDiff_mean_abs = zeros(2, 3, length(binEdges) - 1);

for iType = 1 : 2
    for iDir = 1 : 3
        [NzDiff_sum(iType,iDir,:), ~] = histcounts(zDiff_sum{iType}(:,iDir), binEdges);
        [NzDiff_sum_abs(iType,iDir,:), ~] = histcounts(abs_zDiff_sum{iType}(:,iDir), binEdges);
        [NzDiff_mean(iType,iDir,:), ~] = histcounts(zDiff_mean{iType}(:,iDir), binEdges);
        [NzDiff_mean_abs(iType,iDir,:), ~] = histcounts(abs_zDiff_mean{iType}(:,iDir), binEdges);

        fract_zDiff_sum(iType,iDir,:) = NzDiff_sum(iType,iDir,:) / sum(NzDiff_sum(iType,iDir,:));
        fract_zDiff_sum_abs(iType,iDir,:) = NzDiff_sum_abs(iType,iDir,:) / sum(NzDiff_sum_abs(iType,iDir,:));
        fract_zDiff_mean(iType,iDir,:) = NzDiff_mean(iType,iDir,:) / sum(NzDiff_mean(iType,iDir,:));
        fract_zDiff_mean_abs(iType,iDir,:) = NzDiff_mean_abs(iType,iDir,:) / sum(NzDiff_mean_abs(iType,iDir,:));
    end
end

h = figuree(200,250);
b = bar(binCenters,[squeeze(fract_zDiff_sum(1,3,:)) squeeze(fract_zDiff_sum(2,3,:))],'stacked');
b(1).FaceColor = [1 0 0];
b(2).FaceColor = [0 0 0];
xticks(binCenters);
xlim([binCenters(1)-1 binCenters(end)+1]);
ylim([0 1]);
yticks(ylim);

if doSave
    if doLabels
        xlabel('net sum of all z-scores where p < 0.01');
        ylabel('fraction of units');
        saveas(h,fullfile(figPath,'dirSelIndex.png'));
    else
        xticklabels({});
        yticklabels({});
        tightfig;
        setFig('','',[1,6]);
        print(gcf,'-painters','-depsc',fullfile(figPath,'dirSelIndex.eps'));
    end
    close(h);
end

%%
if false
    % close(1)
    figure(1)

    for iType = 1 : 2
        iAxes = 0;

        iAxes = iAxes + 1;
        subplot(2,2,iAxes)
        plot(binCenters, squeeze(NzDiff_sum(iType,iDir,:)));
        hold on
        title('net sum')

        iAxes = iAxes + 1;
        subplot(2,2,iAxes)
        plot(binCenters, squeeze(NzDiff_mean(iType,iDir,:)));
        hold on
        title('net mean')

        iAxes = iAxes + 1;
        subplot(2,2,iAxes)
        plot(binCenters, squeeze(NzDiff_sum_abs(iType,iDir,:)));
        hold on
        title('abs sum')

        iAxes = iAxes + 1;
        subplot(2,2,iAxes)
        plot(binCenters, squeeze(NzDiff_mean_abs(iType,iDir,:)));
        hold on
        title('abs mean')

    end

    %% LOOK AT THIS ONE FOR THE PLOTS (USE TOP LEFT)
    % close(2)
    % figure(2)
    for iDir = 1 : 3
        figure(iDir)
        for iType = 1 : 2
            iAxes = 0;

            switch iType
                case 1  % directionally selective
                    barColor = 'b';
                case 2  % non-directionally selective
                    barColor = 'r';
            end

            iAxes = iAxes + 1;
            subplot(2,2,iAxes)
            h_bar = bar(binCenters, squeeze(fract_zDiff_sum(iType,iDir,:)));
            hold on
            title('net sum')

            iAxes = iAxes + 1;
            subplot(2,2,iAxes)
            h_bar = bar(binCenters, squeeze(fract_zDiff_mean(iType,iDir,:)));
            hold on
            title('net mean')

            iAxes = iAxes + 1;
            subplot(2,2,iAxes)
            h_bar = bar(binCenters, squeeze(fract_zDiff_sum_abs(iType,iDir,:)));
            hold on
            title('abs sum')

            iAxes = iAxes + 1;
            subplot(2,2,iAxes)
            h_bar = bar(binCenters, squeeze(fract_zDiff_mean_abs(iType,iDir,:)));
            hold on
            title('abs mean')

        end
    end
    %%
    figure(4)
    scatter(squeeze(abs(zDiff_sum{1}(:,1))),squeeze(zDiff_sum{1}(:,2)))
end