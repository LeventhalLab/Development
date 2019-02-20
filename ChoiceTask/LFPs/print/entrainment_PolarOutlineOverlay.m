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
iFreq = 6;
rows = 3;
cols = 3;

zlimVals = [0.05 0.1];
caxisVals = [0.05 0.1];
flatylimVals = [0.075 0.09];
zscoreLabel = 'binfrac';
 
useylims = [0.5 24.5];
ytickVals = [1 24];
for iDirSel = 1:3
    h = ff(1400,800);
    for iTrialType = 1:3
        use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
        use_angles = conds_angles{iTrialType}(dirSelRanges{iDirSel},:,iFreq);
        sigMat = use_angles(use_pvals < pThresh,:);
        
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
        if useZscore
            ylabel('mean Z');
        else
            ylabel('frac of bins');
        end
        ylim(flatylimVals);
        yticks(unique(sort([0 ylim])));
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
        saveas(h,fullfile(savePath,['3D_entrainment_',zscoreLabel,'_',trialTypes{iTrialType},'_',...
            dirSelTypes{iDirSel},'_f',num2str(iFreq,'%02d'),'.png']));
        close(h);
    end
end