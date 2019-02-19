close all

doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';

freqList = logFreqList([1 200],30);
pThresh = 1; % 0.05;
dirSelRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
dirSelTypes = {'all','dirSel','ndirSel'};
trialTypes = {'shuffle','In-trial','Inter-trial'};
barData = [];
meanZ = [];
unitCount = [];
iFreq = 7;
rows = 3;
cols = 3;

zlimVals = [0 5];
caxisVals = [0 6];
useylims = [0.5 24.5];
ytickVals = [1 24];
for iDirSel = 1:3
    h = ff(1400,800);
    for iTrialType = 1:3
        use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
        use_angles = conds_angles{iTrialType}(dirSelRanges{iDirSel},:,iFreq);
        sigMat = use_angles(use_pvals < pThresh,:);
        
        % [ ] how to standardize mean/std for Z-scores?
        sig_zMean = mean(sigMat,2);
        sig_zStd = std(sigMat,[],2);

        Z = (sigMat - sig_zMean) ./ sig_zStd;
        Z = circshift(Z,6,2);
        meanZ = [mean(Z) mean(Z)];

        [~,kZ] = sort(max(Z'));
        Z = Z(kZ,:);
        kBins = [];
        for iNeuron = 1:size(Z,1)
            [~,k] = max(Z(iNeuron,:));
            kBins(iNeuron) = k;
        end
        [~,k] = sort(kBins);
        Z = Z(k,:);
        maxHist = histcounts(kBins,[0.5:12.5]) ./ numel(kBins);
        
        usexlims = [0.5 numel(dirSelRanges{iDirSel}) + 0.5];
        xtickVals = [1 numel(dirSelRanges{iDirSel})];
        Zdata = Z' - min(min(Z));
%         Zdata = circshift(Zdata,6); % phase shift -> 0-360
        
        subplot(rows,cols,prc(cols,[1,iTrialType]));
        bar3color([Zdata;Zdata]);
        view(140,50);
        zlim(zlimVals);
        title([dirSelTypes{iDirSel},', ',trialTypes{iTrialType}]);
        ylim(useylims);
        caxis(caxisVals);
        yticks([0.5 12.5 24.5]);
        yticklabels([0 360 720]);
        xlim(usexlims);
        xticks(xtickVals);
        xlabel('units');
        
        subplot(rows,cols,prc(cols,[2,iTrialType]));
        bar3color([Zdata;Zdata]);
        view(0,90);
        zlim(zlimVals);
        title([dirSelTypes{iDirSel},', ',trialTypes{iTrialType}]);
        ylim(useylims);
        caxis(caxisVals);
        yticks([0.5 12.5 24.5]);
        yticklabels([0 360 720]);
        xlim(usexlims);
        xticks(xtickVals);
        xlabel('units');
        
        subplot(rows,cols,prc(cols,[3,iTrialType]));
        yyaxis left;
        plot(meanZ,'linewidth',3);
        ylabel('mean Z');
        ylim([-0.5 0.5]);
        yticks(sort([0 ylim]));
        yyaxis right;
        plot([maxHist maxHist],'linewidth',3);
        ylabel('frac of units');
        xlim([1 24]);
        xticks([1 12.5 24]);
        xticklabels([0 360 720]);
        title('flattened');
        ylim([0 0.3]);
        yticks(ylim);
        grid on;
        
        colormap(jet);
    end
    set(gcf,'color','w');
    addNote(h,[num2str(freqList(iFreq),'%1.2f'),' Hz'],20);
    if doSave
        saveas(h,fullfile(savePath,['3D_entrainment_',trialTypes{iTrialType},'_',dirSelTypes{iDirSel},'_f',num2str(iFreq,'%02d'),'.png']));
        close(h);
    end
end