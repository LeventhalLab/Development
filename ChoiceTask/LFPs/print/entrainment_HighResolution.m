close all;
doSave = true;

doPlot_pvalDist = false;
doPlot_MRLs = false;
doPlot_kuiper = false;
doPlot_MRLmontage = false;
doPlot_mats = true;
doPlot_bars = false;

useLines = true; % for doPlot_bars

conds_pvals = {squeeze(all_spikeHist_pvals_surr(1,:,:,:)),all_spikeHist_inTrial_pvals,all_spikeHist_pvals};
conds_angles = {squeeze(all_spikeHist_angles_surr(1,:,:,:)),all_spikeHist_inTrial_angles,all_spikeHist_angles};
conds_rs = {squeeze(all_spikeHist_rs_surr(1,:,:,:)),all_spikeHist_inTrial_rs,all_spikeHist_rs};
conds_mus = {squeeze(all_spikeHist_mus_surr(1,:,:,:)),all_spikeHist_inTrial_mus,all_spikeHist_mus};

freqList = logFreqList([1 200],30);
dirSelRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
dirSelTypes = {'all','dirSel','~dirSel'};
trialTypes = {'shuffle','IN trial','OUT trial'};

if doPlot_pvalDist
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure/pvals';
    rows = 3;
    cols = 3;
    nBins = 20;
    binEdges = [0 logFreqList([1 1000],nBins)/1000];
    useTicks = [2,closest(binEdges,0.05),nBins];
    for iFreq = 1:numel(freqList)
        h = ff(600,600);
        for iTrialType = 1:3
            for iDirSel = 1:3
                use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
                ax(iTrialType,iDirSel) = subplot(rows,cols,prc(cols,[iTrialType iDirSel]));
                counts = histcounts(use_pvals,binEdges);
                bar(counts);
                title({[num2str(freqList(iFreq),'%2.1f'),' Hz'],[trialTypes{iTrialType},': ',dirSelTypes{iDirSel}]});
                xticks(useTicks);
                xticklabels({'0.01','0.05','1'});
                xtickangle(30);
                xlim([0 nBins+1]);
                if iTrialType == 3
                    xlabel('p-value');
                end
                if iDirSel == 1
                    ylabel('count');
                end
            end
        end
        for iDirSel = 1:3
            linkaxes(ax(:,iDirSel),'y');
            for iTrialType = 1:3
                subplot(rows,cols,prc(cols,[iTrialType iDirSel]));
                yticks(ylim);
                grid on;
            end
        end
        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,['pvalDist_f',num2str(iFreq),'.png']));
            close(h);
        end
    end
end

if doPlot_MRLs
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure/MRLs';
    pThresh = 1;
    rows = 1;
    cols = 3;
    rlimVals = [0 0.1];
    colors = lines(3);
    fontSize = 12;
    kuiper_pvals = [];
    for iFreq = 1:numel(freqList)
        h = ff(1200,300);
        lns = [];
        for iTrialType = 1:3
            for iDirSel = 1:3
                subplot(rows,cols,iTrialType);
                use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
                thetas = conds_mus{iTrialType}(dirSelRanges{iDirSel},iFreq);
                rhos = conds_rs{iTrialType}(dirSelRanges{iDirSel},iFreq);
                
                thetas = thetas(use_pvals < pThresh);
                rhos = rhos(use_pvals < pThresh);
                
                polar_thetas = [thetas thetas]';
                polar_rhos = [zeros(size(rhos)) rhos]';
                usePolarIdxs = polar_rhos(2,:) > rlimVals(2) / 10;
                polarplot(polar_thetas(:,usePolarIdxs),polar_rhos(:,usePolarIdxs),'lineWidth',0.5,'color',[colors(iDirSel,:) 0.1]);
                hold on;
                thetaMean = circ_mean(thetas(~isnan(thetas)));
                rhoMean = nanmean(rhos);
                lns(iDirSel) = polarplot([thetaMean thetaMean],[0 rhoMean],'lineWidth',2,'color',colors(iDirSel,:));
                polarplot(thetaMean,rhoMean,'.','markerSize',15,'color',colors(iDirSel,:));
                ax = gca;
                ax.ThetaDir = 'counterclockwise';
                ax.ThetaZeroLocation = 'top';
                ax.ThetaTick = [0 90 180 270];
                rlim(rlimVals);
                rticks(rlimVals);
                if iDirSel == 2
                    thetas_dir = thetas;
                elseif iDirSel == 3
                    kuiper_pvals(iFreq,iTrialType) = circ_kuipertest(thetas,thetas_dir);
                    title({[num2str(freqList(iFreq),'%2.1f'),' Hz'],trialTypes{iTrialType},...
                        ['kuiper p = ',num2str(kuiper_pvals(iFreq,iTrialType,iDirSel),2)]});
                end
                ax.ThetaTickLabels = [];
                set(gca,'fontsize',fontSize);
                drawnow;
            end
        end
        ax = get(gca,'Position');
        legend(lns,dirSelTypes,'Location','NorthEastOutside','fontSize',fontSize);
        set(gca,'Position',ax);
        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,['entrainmentMRLs_f',num2str(iFreq),'_p',strrep(num2str(pThresh,'%1.2f'),'.','-'),'.png']));
            close(h);
        end
    end
end

if doPlot_kuiper % kuiper pval plot
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure/MRLs';
    h = ff(1200,300);
    plotColors = {'','r','k'};
    for iTrialType = 2:3 % all shuffles == 1
        plot(kuiper_pvals(:,iTrialType),'color',plotColors{iTrialType},'lineWidth',2);
        hold on;
        xticks(1:numel(freqList));
        xticklabels(compose('%2.1f',freqList));
        ylim([0 1.2]);
        yticks([0 0.05 1]);
    end
    xtickangle(270);
    xlabel('freq (Hz)');
    ylabel('p-value');
    title('Kuiper test between dirSel & ~dirSel units');
    legend('IN trial','OUT trial','location','eastoutside');
    set(gcf,'color','w');
    set(gca,'fontsize',16);
    grid on;
    if doSave
        saveas(h,fullfile(savePath,'all_entrainmentMRLs_kuiperPvals.png'));
        close(h);
    end
end

if doPlot_MRLmontage
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure/MRLs';
    pThresh = 0.05;
    file = uigetfile(fullfile(savePath,'*.png'),'Create Montage','MultiSelect','on');
    filenames = {};
    for iFile = 1:numel(file)
        filenames{iFile} = fullfile(savePath,file{iFile});
    end
    im = imtile(filenames,'GridSize',[numel(file) 1]);
    if doSave
        imwrite(im,fullfile(savePath,['all_entrainmentMRLs_p',strrep(num2str(pThresh,'%1.2f'),'.','-'),'.png']));
    end
end

if doPlot_mats
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';
    pThresh = 1;%0.05;
    barData = [];
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
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';
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