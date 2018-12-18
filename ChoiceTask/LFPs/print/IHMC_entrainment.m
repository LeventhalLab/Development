close all
doSave = false;
savePath = '/Users/mattgaidica/Dropbox/Presentations/2018 IHMC/Supp';

conds_pvals = {squeeze(all_spikeHist_pvals_surr(1,:,:,:)),all_spikeHist_inTrial_pvals,all_spikeHist_pvals};
conds_angles = {squeeze(all_spikeHist_angles_surr(1,:,:,:)),all_spikeHist_inTrial_angles,all_spikeHist_angles};
freqLabels = {'\delta (1-4 Hz)','\theta (4-8 Hz)','\alpha','\beta (13-30 Hz)'};

pThresh = 0.05;
x = [];
iCond = 2; % in-trial
useRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
useFreqs = [1,2,4];
unitCount = [];
for iFreq = 1:3
    for iDir = 1:2
        use_pvals = conds_pvals{iCond}(useRanges{iDir},useFreqs(iFreq));
        unitCount(iFreq) = sum(use_pvals < pThresh);
        x(iFreq,iDir) = unitCount(iFreq) / (numel(useRanges{1}) + numel(useRanges{2}));
    end
end

h = ff(500,400);
b = bar(x,'stacked');
ylabel(['Fraction p < ',num2str(pThresh,'%1.2f')]);
yticks(ylim);
xticks([1:3]);
xticklabels(freqLabels(useFreqs));
xtickangle(30);
title('Fraction of Entrained Units');
for ii = 1:3
    text(ii,sum(x(ii,:)) + 0.02,['n = ',num2str(unitCount(ii))],'fontSize',12,'horizontalAlign','center');
end
set(gca,'fontSize',16);
set(gcf,'color','w');
legend({'"Directional" Unit','"Non-directional" Unit'});
legend boxoff;
box off;

if doSave
    saveas(h,fullfile(savePath,'fraction-of-entrained-units.png'));
    close(h);
end

for iFreq = [1,2,4]
    h = ff(500,400);
    for iDir = 2:3
        use_pvals = conds_pvals{iCond}(useRanges{iDir},iFreq);
        use_angles = conds_angles{iCond}(useRanges{iDir},:,iFreq);
        sigMat = use_angles(use_pvals < pThresh,:);
        sig_zMean = mean(sigMat,2);
        sig_zStd = std(sigMat,[],2);
        sigMatZ = (sigMat - sig_zMean) ./ sig_zStd;
        sigBinMax = [];
        for ii = 1:size(sigMat,1)
            [v,k] = max(sigMat(ii,:));
            sigBinMax(ii) = k;
        end
% %         counts = histcounts(sigBinMax,12) / size(sigMat,1); % !!assumes range(nSigBinMax) is 1:12
        plot([mean(sigMatZ) mean(sigMatZ)],'-','lineWidth',4);
        hold on;
    end
    xticks([1,6.5,12.5,18.5,24]);
    xticklabels([0 180 360 540 720]);
    xtickangle(30);
    xlim([min(xticks) max(xticks)]);
    xlabel('Spike phase (deg)');
    ylim([-1 1]);
    yticks(sort([ylim,0]));
    ylabel('Z-score');
    grid on;
    set(gca,'fontSize',24);
    set(gcf,'color','w');
    title([freqLabels{iFreq},' Entrainment']);
    box off;
    if iFreq ~= 1
        ylabel([]);
        yticklabels([]);
    end

    if doSave
        saveas(h,fullfile(savePath,['freq',num2str(iFreq),'-entrainment.png']));
        close(h);
    end
end