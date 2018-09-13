% load('session_20180516_FinishedResubmission.mat', 'ndirSelUnitIds')
% load('session_20180516_FinishedResubmission.mat', 'primSec')
% load('session_20180516_FinishedResubmission.mat', 'dirSelUnitIds')

%% run code
useCase = 1;
Leventhal2012_Fig6_analysisAllFreq

useCase = 2;
Leventhal2012_Fig6_analysisAllFreq

useCase = 3;
Leventhal2012_Fig6_analysisAllFreq

useCase = 4;
for iEvent = 1:7
    Leventhal2012_Fig6_analysisAllFreq
end

%% function
doSave = true;
% useCase = 3;
switch useCase
    case 1
        unitRange = 1:366;
        noteText = 'AllUnits';
        p_ylimVals = [0 300];
    case 2
        unitRange = dirSelUnitIds;
        noteText = 'dirSelUnits';
        p_ylimVals = [0 60];
    case 3
        unitRange = ndirSelUnitIds;
        noteText = 'ndirSelUnits';
        p_ylimVals = [0 60];
    case 4
        unitRange = primSec(:,1) == iEvent;
        noteText = [num2str(iEvent),'_',eventFieldnames{iEvent}];
        p_ylimVals = [0 40];
end

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseUnitTypes';

rows = 6;
cols = 10;

conds_pvals = {all_spikeHist_pvals,all_spikeHist_inTrial_pvals};
conds_angles = {all_spikeHist_angles,all_spikeHist_inTrial_angles};
titleLabels = {'OUT TRIAL','IN TRIAL'};
h = ff(1400,900);
for iCond = 1:2
    for iFreq = 1:size(all_spikeHist_pvals,2)
        use_pvals = conds_pvals{iCond}(unitRange,iFreq);
        use_angles = conds_angles{iCond}(unitRange,:,iFreq);

        subplot(rows,cols,prc(cols,[iCond*3-2 iFreq]));
        counts = histcounts(use_pvals,linspace(0,1,41));
        b = bar(counts,'k');
        % highlight above chance

        xticks([1 round(40/2) 40]);
        xticklabels({'0','0.5','1'});
        xlabel('p-value');
        ylim(p_ylimVals);
        yticks(ylim);
        if iFreq == 1
            ylabel('# Units');
        end
        title({[num2str(freqList(iFreq),'%2.1f'),' Hz'],titleLabels{iCond}});

        nSigMat = use_angles(use_pvals >= 0.05,:);
        nSig_zMean = mean(nSigMat,2);
        nSig_zStd = std(nSigMat,[],2);
        nSigMatZ = (nSigMat - nSig_zMean) ./ nSig_zStd;

        sigMat = use_angles(use_pvals < 0.05,:);
        sig_zMean = mean(sigMat,2);
        sig_zStd = std(sigMat,[],2);
        sigMatZ = (sigMat - sig_zMean) ./ sig_zStd;

        subplot(rows,cols,prc(cols,[iCond*3-1 iFreq]));
        nSigBinMax = [];
        for ii = 1:size(nSigMat,1)
            [v,k] = max(nSigMat(ii,:));
            nSigBinMax(ii) = k;
        end
        sigBinMax = [];
        for ii = 1:size(sigMat,1)
            [v,k] = max(sigMat(ii,:));
            sigBinMax(ii) = k;
        end
        counts = histcounts(nSigBinMax,12) / size(nSigMat,1); % !!assumes range(nSigBinMax) is 1:12
        plot([counts counts],'k-','lineWidth',0.5);
        hold on;
        counts = histcounts(sigBinMax,12) / size(sigMat,1); % !!assumes range(nSigBinMax) is 1:12
        plot([counts counts],'r-','lineWidth',2);
        xticks([1,6.5,12.5,18.5,24]);
        xticklabels([0 180 360 540 720]);
        xtickangle(270);
        xlabel('Mean phase (deg)');
        ylim([0 0.5]);
        yticks(ylim);
        if iFreq == 1
            ylabel('Fraction of units');
        end
        title(titleLabels{iCond});
        grid on;

        subplot(rows,cols,prc(cols,[iCond*3 iFreq]));
        lns(1) = plot([mean(nSigMatZ) mean(nSigMatZ)],'k','lineWidth',0.5);
        hold on;
        lns(2) = plot([mean(sigMatZ) mean(sigMatZ)],'r','lineWidth',2);
        xticks([1,6.5,12.5,18.5,24]);
        xticklabels([0 180 360 540 720]);
        xtickangle(270);
        xlabel('Spike phase (deg)');
        ylim([-1 1]);
        yticks(sort([ylim,0]));
        if iFreq == 1
            ylabel('Z bins');
        end
        title(titleLabels{iCond});
%         if iCond == 1
%             legend(lns,{'p >= 0.05','p < 0.05'});
%         end
        grid on;
    end
end
set(gcf,'color','w');
addNote(h,noteText);
if doSave
    saveas(h,fullfile(savePath,['Leventhal2012_Fig6_spikeHist_',noteText,'.png']));
    close(h);
end