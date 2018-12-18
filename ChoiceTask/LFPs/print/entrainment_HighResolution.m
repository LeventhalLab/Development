close all;

doPlot_bars = false;

conds_pvals = {squeeze(all_spikeHist_pvals_surr(1,:,:,:)),all_spikeHist_inTrial_pvals,all_spikeHist_pvals};
conds_angles = {squeeze(all_spikeHist_angles_surr(1,:,:,:)),all_spikeHist_inTrial_angles,all_spikeHist_angles};

freqList = logFreqList([1 200],30);

pThresh = 0.05;
barData = [];
dirSelRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
dirSelTypes = {'all','dirSel','~dirSel'};
unitCount = [];
trialTypes = {'shuffle','IN trial','OUT trial'};

% !! add unit count to title, make preferred phase matrix to compare dir/~dir
entMat = [];
rows = 3;
cols = 3;
h = ff(1100,900);
for iTrialType = 1:3
    for iDirSel = 1:3
        for iFreq = 1:numel(freqList)
            use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
            use_angles = conds_angles{iTrialType}(dirSelRanges{iDirSel},:,iFreq);
            sigMat = use_angles(use_pvals < pThresh,:);
            sig_zMean = mean(sigMat,2);
            sig_zStd = std(sigMat,[],2);
            sigMatZ = (sigMat - sig_zMean) ./ sig_zStd;
            if size(sigMatZ,1) == 1
                entMat(iFreq,:) = zeros(1,24);
            else
                entMat(iFreq,:) = [mean(sigMatZ) mean(sigMatZ)];
            end
    % %         counts = histcounts(sigBinMax,12) / size(sigMat,1); % !!assumes range(nSigBinMax) is 1:12
        end
        subplot(rows,cols,prc(cols,[iDirSel,iTrialType]));
        imagesc(entMat);
        xticks([1,6.5,12.5,18.5,24]);
        xticklabels([0 180 360 540 720]);
        xtickangle(30);
        xlabel('Spike phase (deg)');
        yticks(1:numel(freqList));
        yticklabels(compose('%2.1f',freqList));
        ylabel('Freq. (Hz)');
        caxis([-0.8 .8]);
        set(gca,'ydir','normal')
        colormap(jet);
        cb = colorbar;
        ylabel(cb,['Z p < ',num2str(pThresh,'%1.2f')])
        title([dirSelTypes{iDirSel},' units ',trialTypes{iTrialType}]);
    end
end
set(gcf,'color','w');


if doPlot_bars
    rows = 3;
    cols = 2;
    ff(1400,800);
    for iTrialType = 1:3
        for iFreq = 1:numel(freqList)
            for iDirSel = 1:3
                use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
                unitCount(iFreq) = sum(use_pvals < pThresh);
                barData(iFreq,iDirSel) = unitCount(iFreq) / (numel(dirSelRanges{iDirSel}));
            end
        end
        subplot(rows,cols,prc(cols,[iTrialType,1]));
        bar(barData);
        xticks(1:numel(freqList));
        xticklabels(compose('%2.1f',freqList));
        xtickangle(270);
        xlabel('Freq. (Hz)');
        ylim([0 0.8]);
        ylabel(['Entrained p < ',num2str(pThresh,'%1.2f')])
        title(trialTypes{iTrialType});
        if iTrialType == 1
            legend(dirSelTypes{:});
        end
    end

    colors = lines(3);
    for iDirSel = 1:3
        for iFreq = 1:numel(freqList)
            for iTrialType = 1:3
                use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
                unitCount(iFreq) = sum(use_pvals < pThresh);
                barData(iFreq,iTrialType) = unitCount(iFreq) / (numel(dirSelRanges{iDirSel}));
            end
        end
        subplot(rows,cols,prc(cols,[iDirSel,2]));
        bar(barData,'faceColor',colors(iDirSel,:));
        xticks(1:numel(freqList));
        xticklabels(compose('%2.1f',freqList));
        xtickangle(270);
        xlabel('Freq. (Hz)');
        ylim([0 0.8]);
        ylabel(['Entrained p < ',num2str(pThresh,'%1.2f')]);
        title(dirSelTypes{iDirSel});
        legend(strjoin(trialTypes,', '));
    end
    set(gcf,'color','w');
end