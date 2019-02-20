close all

doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';

freqList = logFreqList([1 200],30);
pThresh = 1; % 0.05;
dirSelRanges = {[1:366],dirSelUnitIds,ndirSelUnitIds};
dirSelTypes = {'all','dirSel','ndirSel'};
trialTypes = {'shuffle','In-trial','Inter-trial'};
iFreq = 6;
rows = 1;
cols = 3;
nBins = 12;
binEdges = linspace(-pi,pi,nBins + 1);

condLabels_wCount = {['allUnits (n = ',num2str(numel(dirSelRanges{1})),')'],...
    ['dirSel (n = ',num2str(numel(dirSelRanges{2})),')'],...
    ['ndirSel (n = ',num2str(numel(dirSelRanges{3})),')']};
 
h = ff(1400,500);
for iTrialType = 1:3
    for iDirSel = 1:3
        use_pvals = conds_pvals{iTrialType}(dirSelRanges{iDirSel},iFreq);
        use_angles = conds_angles{iTrialType}(dirSelRanges{iDirSel},:,iFreq);
        sigMat = use_angles(use_pvals < pThresh,:);
        subplot(rows,cols,prc(cols,[1,iTrialType]));
        
        % order, sort
        Z = sigMat ./ sum(sigMat,2);
        [~,kZ] = sort(max(Z'));
        Z = Z(kZ,:);
        kBins = [];
        for iNeuron = 1:size(Z,1)
            [~,k] = max(Z(iNeuron,:));
            kBins(iNeuron) = k;
        end
        [~,k] = sort(kBins);
        Z = Z(k,:);
        
        colors = [0 0 0;lines(2)];
        hp = polarhistogram('BinEdges',binEdges,'BinCounts',mean(Z));
        hp.DisplayStyle = 'stairs';
        hold on;
        rlim([0.09 .101]);
        hp.LineWidth = 4;
        rticks(rlim);
        hp.EdgeColor = colors(iDirSel,:);
        
% %         colors = jet(size(sigMat,1));
% %         for iNeuron = 1:size(sigMat,1)
% %             hp = polarhistogram('BinEdges',binEdges,'BinCounts',Z(iNeuron,:));
% %             hp.DisplayStyle = 'stairs';
% %             hp.EdgeColor = colors(iNeuron,:);
% %             hold on;
% %             drawnow;
% %         end
        title([trialTypes{iTrialType}]);
    end
    legend(condLabels_wCount,'location','southoutside');
end
set(gcf,'color','w');
addNote(h,[num2str(freqList(iFreq),'%1.2f'),' Hz'],20);
if doSave
    saveas(h,fullfile(savePath,['polarOverlay_entrainment_f',num2str(iFreq,'%02d'),'.png']));
    close(h);
end