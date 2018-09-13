doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseUnitTypes';
% rows = 3;
% cols = 2;
rows = 3;
cols = numel(freqList);

conds_pvals = {all_spikeHist_pvals,all_spikeHist_inTrial_pvals};
conds_angles = {all_spikeHist_angles,all_spikeHist_inTrial_angles};
titleLabels = {'OUT TRIAL','IN TRIAL'};
plotLabels = {eventFieldnames{:} 'NaN'};
investigateCounts = [];
investigateFreq = 3;

for iFreq = 1%1:numel(freqList)
%     h = ff(400,800);
    h = ff(1600,800);
%     for iCond = 1:2 
    iCond = 1;
    for iFreq = 1:numel(freqList)
%         subplot(rows,cols,prc(cols,[1,iCond]));
        subplot(rows,cols,prc(cols,[1,iFreq]));
        x = [];
        for iEvent = 1:8
            if iEvent == 8
                useRange = isnan(primSec(:,1));
            else
                useRange = primSec(:,1) == iEvent;
            end
            use_pvals = conds_pvals{iCond}(useRange,iFreq);
            use_angles = conds_angles{iCond}(useRange,:,iFreq);
            x(iEvent) = sum(use_pvals < 0.05) / sum(useRange);
        end
        b = bar(x,'stacked');
        b.FaceColor = 'flat';
        b.CData = lines(8);
        xticks([1:8]);
        xticklabels(plotLabels);
        xtickangle(270);
        ylim([0 1]);
        yticks(ylim);
        ylabel('fraction p < 0.05');
        title({[num2str(freqList(iFreq),'%2.1f'),' Hz'],titleLabels{iCond}});
        
%         subplot(rows,cols,prc(cols,[2,iCond]));
        subplot(rows,cols,prc(cols,[2,iFreq]));
        for iEvent = 1:7
            if iEvent == 8
                useRange = isnan(primSec(:,1));
            else
                useRange = primSec(:,1) == iEvent;
            end
            use_pvals = conds_pvals{iCond}(useRange,iFreq);
            use_angles = conds_angles{iCond}(useRange,:,iFreq);
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
            plot([counts counts],'-','lineWidth',1);
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
        if iFreq == numel(freqList)
%         if iCond == 2
            legend(plotLabels{1:7});
            legend boxoff;
        end
        
%         subplot(rows,cols,prc(cols,[3,iCond]));
        subplot(rows,cols,prc(cols,[3,iFreq]));
        for iEvent = 1:7
            if iEvent == 8
                useRange = isnan(primSec(:,1));
            else
                useRange = primSec(:,1) == iEvent;
            end
            use_pvals = conds_pvals{iCond}(useRange,iFreq);
            use_angles = conds_angles{iCond}(useRange,:,iFreq);
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
            if iFreq == investigateFreq
                investigateCounts(iEvent,:) = [mean(sigMatZ) mean(sigMatZ)];
            end
            plot([mean(sigMatZ) mean(sigMatZ)],'-','lineWidth',1);
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
%         saveas(h,fullfile(savePath,['Leventhal2012_Fig6_spikeHist_events_',saveFreq,'Hz.png']));
        saveas(h,fullfile(savePath,['Leventhal2012_Fig6_spikeHist_events_AllFreqs_',titleLabels{iCond},'.png']));
        close(h);
    end
end