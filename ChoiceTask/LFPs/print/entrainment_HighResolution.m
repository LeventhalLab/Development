close all;
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';

doPlot_mats = false;
doPlot_bars = true;
useLines = true;

conds_pvals = {squeeze(all_spikeHist_pvals_surr(1,:,:,:)),all_spikeHist_inTrial_pvals,all_spikeHist_pvals};
conds_angles = {squeeze(all_spikeHist_angles_surr(1,:,:,:)),all_spikeHist_inTrial_angles,all_spikeHist_angles};

freqList = logFreqList([1 200],30);

if doPlot_mats
    pThresh = 1;%0.05;
    barData = [];
    dirSelRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
    dirSelTypes = {'all','dirSel','~dirSel'};
    trialTypes = {'shuffle','IN trial','OUT trial'};

    entMat = [];
    unitCount = [];
    for iTrialType = 1:3
        for iDirSel = 1:3
            iPrc = prc(3,[iDirSel,iTrialType]);
            for iFreq = 1:numel(freqList)
                use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
                use_angles = conds_angles{iTrialType}(dirSelRanges{iDirSel},:,iFreq);
                sigMat = use_angles(use_pvals < pThresh,:);
                sig_zMean = mean(sigMat,2);
                sig_zStd = std(sigMat,[],2);
                sigMatZ = (sigMat - sig_zMean) ./ sig_zStd;
                if size(sigMatZ,1) == 1
                    entMat(iPrc,iFreq,:) = zeros(1,24);
                else
                    entMat(iPrc,iFreq,:) = [mean(sigMatZ) mean(sigMatZ)];
                end
                unitCount(iPrc) = size(sigMat,1);
        % %         counts = histcounts(sigBinMax,12) / size(sigMat,1); % !!assumes range(nSigBinMax) is 1:12
            end
        end
    end

    rows = 4;
    cols = 4;
    h = ff(1100,900);
    iPrcMap = [1 2 3 5 6 7 9 10 11];
    for iTrialType = 1:3
        for iDirSel = 1:3
            iPrc = prc(3,[iDirSel,iTrialType]);
            useMat = squeeze(entMat(iPrc,:,:));
            subplot(rows,cols,iPrcMap(iPrc));
            imagesc(useMat);
            formatAxes(freqList,pThresh);
            title({[dirSelTypes{iDirSel},' units ',trialTypes{iTrialType}],['n = ',num2str(unitCount(iPrc))]});
        end
    end

    subplot(rows,cols,4);
    useMat = squeeze(entMat(3,:,:)) - squeeze(entMat(2,:,:));
    imagesc(useMat);
    set(gcf,'color','w');
    cb = formatAxes(freqList,pThresh);
    title('all units OUT - IN');
    colormap(gca,jupiter);
    ylabel(cb,'diff');

    subplot(rows,cols,8);
    useMat = squeeze(entMat(6,:,:)) - squeeze(entMat(5,:,:));
    imagesc(useMat);
    set(gcf,'color','w');
    cb = formatAxes(freqList,pThresh);
    title('dirSel units OUT - IN');
    colormap(gca,jupiter);
    ylabel(cb,'diff');

    subplot(rows,cols,12);
    useMat = squeeze(entMat(9,:,:)) - squeeze(entMat(8,:,:));
    imagesc(useMat);
    set(gcf,'color','w');
    cb = formatAxes(freqList,pThresh);
    title('~dirSel units OUT - IN');
    colormap(gca,jupiter);
    ylabel(cb,'diff');

    subplot(rows,cols,14);
    useMat = squeeze(entMat(9,:,:)) - squeeze(entMat(6,:,:));
    imagesc(useMat);
    set(gcf,'color','w');
    cb = formatAxes(freqList,pThresh);
    title('~dir - dirSel IN trial');
    colormap(gca,jupiter);
    ylabel(cb,'diff');

    subplot(rows,cols,15);
    useMat = squeeze(entMat(8,:,:)) - squeeze(entMat(5,:,:));
    imagesc(useMat);
    set(gcf,'color','w');
    cb = formatAxes(freqList,pThresh);
    title('~dir - dirSel OUT trial');
    colormap(gca,jupiter);
    ylabel(cb,'diff');

    set(gcf,'color','w');

    if doSave
        saveas(h,fullfile(savePath,'entrainmentMats_wDiff.png'));
        close(h);
    end
end

if doPlot_bars
    pThresh = 0.05;
    rows = 3;
    cols = 2;
    colors = lines(3);
    lineStyles = {'.','-','--'};
    h = ff(1400,800);
    for iTrialType = 1:3
        for iFreq = 1:numel(freqList)
            for iDirSel = 1:3
                use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
                unitCount(iFreq) = sum(use_pvals < pThresh);
                barData(iFreq,iDirSel) = unitCount(iFreq) / (numel(dirSelRanges{iDirSel}));
            end
        end
        subplot(rows,cols,prc(cols,[iTrialType,1]));
        if useLines
            plot(barData,'lineWidth',2);
        else
            bar(barData);
        end
        
        xticks(1:numel(freqList));
        xticklabels(compose('%2.1f',freqList));
        xtickangle(270);
        xlabel('Freq. (Hz)');
        ylim([0 0.8]);
        ylabel(['Entrained p < ',num2str(pThresh,'%1.2f')])
        title(trialTypes{iTrialType});
        legend(dirSelTypes{:});
    end

    for iDirSel = 1:3
        for iFreq = 1:numel(freqList)
            for iTrialType = 1:3
                use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
                unitCount(iFreq) = sum(use_pvals < pThresh);
                barData(iFreq,iTrialType) = unitCount(iFreq) / (numel(dirSelRanges{iDirSel}));
            end
        end
        subplot(rows,cols,prc(cols,[iDirSel,2]));
        if useLines
            for iLine = 1:3
                plot(barData(:,iLine),lineStyles{iLine},'color',colors(iDirSel,:),'lineWidth',2);
                hold on;
            end
        else
            bar(barData,'faceColor',colors(iDirSel,:));
        end
        xticks(1:numel(freqList));
        xticklabels(compose('%2.1f',freqList));
        xtickangle(270);
        xlabel('Freq. (Hz)');
        ylim([0 0.8]);
        ylabel(['Entrained p < ',num2str(pThresh,'%1.2f')]);
        if useLines
            legend(trialTypes);
        else
            legend(strjoin(trialTypes,', '));
        end
        title(dirSelTypes{iDirSel});
    end
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,'entrainmentBars.png'));
        close(h);
    end
end

function cb = formatAxes(freqList,pThresh)
    selYs = [closest(freqList,1) closest(freqList,4) closest(freqList,8) closest(freqList,13)...
        closest(freqList,20) closest(freqList,55) closest(freqList,200)];
    xticks([1,6.5,12.5,18.5,24]);
    xticklabels([0 180 360 540 720]);
    xtickangle(30);
    xlabel('Spike phase (deg)');
    yticks(selYs);
    yticklabels(compose('%2.0f',freqList(selYs)));
    ylabel('Freq. (Hz)');
    caxis([-0.5 0.5]);
    set(gca,'ydir','normal')
    colormap(gca,jet);
    cb = colorbar;
    ylabel(cb,['Z p < ',num2str(pThresh,'%1.2f')]);
    grid on;
end