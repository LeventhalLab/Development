doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseUnitTypes';
% rows = 3;
% cols = 2;
rows = 3;
cols = numel(freqList);

conds_pvals = {all_spikeHist_pvals,all_spikeHist_inTrial_pvals};
conds_angles = {all_spikeHist_angles,all_spikeHist_inTrial_angles};
titleLabels = {'ALL','IN TRIAL'};
useRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
plotLabels = {'All','dirSel','ndirSel'};

for iFreq = 1%:numel(freqList)
%     h = ff(600,800);
    h = ff(1600,800);
    iCond = 2;
    for iFreq = 1:numel(freqList)
%     for iCond = 1:2
%         subplot(rows,cols,prc(cols,[1,iCond]));
        subplot(rows,cols,prc(cols,[1,iFreq]));
        x = [];
        for iPlot = 1:3
            use_pvals = conds_pvals{iCond}(useRanges{iPlot},iFreq);
            use_angles = conds_angles{iCond}(useRanges{iPlot},:,iFreq);
            x(iPlot) = sum(use_pvals < 0.05) / numel(useRanges{iPlot});
        end
        b = bar(x,'stacked');
        b.FaceColor = 'flat';
        b.CData = lines(3);
        xticks([1:3]);
        xticklabels(plotLabels);
        xtickangle(270);
        ylim([0 1]);
        yticks(ylim);
        ylabel('fraction p < 0.05');
        title({[num2str(freqList(iFreq),'%2.1f'),' Hz'],titleLabels{iCond}});
        
%         subplot(rows,cols,prc(cols,[2,iCond]));
        subplot(rows,cols,prc(cols,[2,iFreq]));
        for iPlot = 1:3
            use_pvals = conds_pvals{iCond}(useRanges{iPlot},iFreq);
            use_angles = conds_angles{iCond}(useRanges{iPlot},:,iFreq);
            sigMat = use_angles(use_pvals < 0.05,:);
            sig_zMean = mean(sigMat,2);
            sig_zStd = std(sigMat,[],2);
            sigMatZ = (sigMat - sig_zMean) ./ sig_zStd;
            sigBinMax = [];
            for ii = 1:size(sigMat,1)
                [v,k] = max(sigMat(ii,:));
                sigBinMax(ii) = k;
            end
            counts = histcounts(sigBinMax,12) / size(sigMat,1); % !!assumes range(nSigBinMax) is 1:12
            plot([counts counts],'-','lineWidth',2);
            hold on;
            xticks([1,6.5,12.5,18.5,24]);
            xticklabels([0 180 360 540 720]);
            xtickangle(270);
            xlabel('Mean phase (deg)');
            ylim([0 0.5]);
            yticks(ylim);
            ylabel('Fraction of units');
            grid on;
        end
        title(titleLabels{iCond});
%         if iCond == 2
        if iFreq == numel(freqList)
            legend(plotLabels);
            legend boxoff;
        end
        
%         subplot(rows,cols,prc(cols,[3,iCond]));
        subplot(rows,cols,prc(cols,[3,iFreq]));
        for iPlot = 1:3
            use_pvals = conds_pvals{iCond}(useRanges{iPlot},iFreq);
            use_angles = conds_angles{iCond}(useRanges{iPlot},:,iFreq);
            sigMat = use_angles(use_pvals < 0.05,:);
            sig_zMean = mean(sigMat,2);
            sig_zStd = std(sigMat,[],2);
            sigMatZ = (sigMat - sig_zMean) ./ sig_zStd;
            sigBinMax = [];
            for ii = 1:size(sigMat,1)
                [v,k] = max(sigMat(ii,:));
                sigBinMax(ii) = k;
            end
            counts = histcounts(sigBinMax,12) / size(sigMat,1); % !!assumes range(nSigBinMax) is 1:12
            plot([mean(sigMatZ) mean(sigMatZ)],'-','lineWidth',2);
            hold on;
            xticks([1,6.5,12.5,18.5,24]);
            xticklabels([0 180 360 540 720]);
            xtickangle(270);
            xlabel('Spike phase (deg)');
            ylim([-1 1]);
            yticks(sort([ylim,0]));
            ylabel('Z bins');
            grid on;
        end
        title(titleLabels{iCond});
    end
    
    set(gcf,'color','w');
    if doSave
        saveFreq = strrep(num2str(freqList(iFreq),'%1.2f'),'.','-');
%         saveas(h,fullfile(savePath,['Leventhal2012_Fig6_spikeHist_dirSel_',saveFreq,'Hz.png']));
        saveas(h,fullfile(savePath,['Leventhal2012_Fig6_spikeHist_dirSel_AllFreq_',titleLabels{iCond},'.png']));
        close(h);
    end
end