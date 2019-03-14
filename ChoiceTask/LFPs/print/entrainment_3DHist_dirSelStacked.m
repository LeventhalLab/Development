close all

doSave = false;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';

freqList = logFreqList([1 200],30);
dirSelRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
inOut_data_mus = {all_spikeHist_inTrial_mus,all_spikeHist_mus};
dirSelTypes = {'all','dirSel','ndirSel'};
trialTypes = {'shuffle','In-trial','Inter-trial'};
iFreq = 6;
rows = 4;
cols = 3;

zlimVals = [0.05 0.1];
caxisVals = [0.05 0.1];
flatylimVals = [0.075 0.09];
useylims = [0.5 24.5];
ytickVals = [1 24];

lineColors = [repmat(.8,[1,3]);lines(2)];
lineWidths = [1 3 3];

h = ff(1000,800);

for iTrialType = 1:3
    for iDirSel = 1:3
% % % %         use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
        sigMat = conds_angles{iTrialType}(dirSelRanges{iDirSel},:,iFreq);
        if iTrialType ~= 1
            use_mus = inOut_data_mus{iTrialType-1}(dirSelRanges{iDirSel},iFreq);
            use_mus(isnan(use_mus)) = [];
            mu_mean = circ_mean(use_mus);
            mu_pval = circ_rtest(use_mus);
        end
        
        Z = sigMat ./ sum(sigMat,2);
        Z = circshift(Z,6,2);
        meanZ = [nanmean(Z) nanmean(Z)];

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

        Zdata = Z';

        hs = subplot(rows,cols,prc(cols,[iTrialType,iDirSel]));
        imagesc([Zdata;Zdata]);
        if iTrialType == 1
            title({dirSelTypes{iDirSel},trialTypes{iTrialType}});
        else
            title(trialTypes{iTrialType});
        end
        ylim(useylims);
        caxis(caxisVals);
        yticks([0.5 12.5 24.5]);
        yticklabels([0 360 720]);
        xlim(usexlims);
        xticks(xtickVals);
        xlabel('units');
        grid on;
        
        subplot(rows,cols,prc(cols,[4,iDirSel]));
        plot(meanZ,'linewidth',3,'color',lineColors(iTrialType,:),'linewidth',lineWidths(iTrialType));
        hold on;
        xlim([1 numel(meanZ)]);
        xticks([1 12 24]);
        xticklabels([0 360 720]);
        ylabel('mean');
        ylim(flatylimVals);
        yticks(unique(sort([0 ylim])));
        grid on;
        if iTrialType == 3
            legend(trialTypes,'location','southeast');
            legend boxoff;
        end
        title('mean phase');
        
        colormap(jet);
    end
end
set(gcf,'color','w');
addNote(h,[num2str(freqList(iFreq),'%1.2f'),' Hz'],20);
if doSave
    saveas(h,fullfile(savePath,['3D_entrainment_stacked_f',num2str(iFreq,'%02d'),'_alt.png']));
    close(h);
end