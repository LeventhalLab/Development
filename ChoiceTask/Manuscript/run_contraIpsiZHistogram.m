% save('/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Resubmission/20180513/contraIpsiZHistogramVars',...
%     'dirSelUnitIds','ndirSelUnitIds','analyzeRange','all_matrixDiffZ');

doSave = false;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';

% get max magnitude Z within analyzeRange
iEvent = 4;
maxVals_dir = [];
for iUnit = 1:numel(dirSelUnitIds)
    unitData = squeeze(all_matrixDiffZ(dirSelUnitIds(iUnit),iEvent,analyzeRange));
    [~,k] = max(abs(unitData));
    maxVals_dir(iUnit) = unitData(k);
end

maxVals_ndir = [];
for iUnit = 1:numel(ndirSelUnitIds)
    unitData = squeeze(all_matrixDiffZ(ndirSelUnitIds(iUnit),iEvent,analyzeRange));
    [~,k] = max(abs(unitData));
    maxVals_ndir(iUnit) = unitData(k);
end

binEdges = -6:0.5:6;
counts_dir = histcounts(maxVals_dir,binEdges);
counts_ndir = histcounts(maxVals_ndir,binEdges);

nInterp = 1; % no smoothing right now
lineWidth = 2;
x = linspace(binEdges(1),binEdges(end),numel(interp(counts_dir,nInterp)));

h = figuree(400,150);
plot(x,interp(counts_dir,nInterp),'r','lineWidth',lineWidth);
hold on;
plot(x,interp(counts_ndir,nInterp),'k','lineWidth',lineWidth);

xlim([binEdges(1),binEdges(end)]);
xticks(sort([xlim,0]));
ylim([0 max([counts_ndir counts_dir])+7]);
yticks(ylim);

if doSave
    yticklabels({});
    xticklabels({});
    box off;
    tightfig;
    setFig('','',[1,1]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'contraIpsiZHistogram.eps'));
    close(h);
end