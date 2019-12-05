% COMODULO, see: Canolty_Comodulogram_trialStitched.m
if ~exist('corrMatrix_rho')
    load('Canolt_comodulogram_20190122.mat')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
end
corrMatrix = squeeze(mean(corrMatrix_rho));
corrMatrix_shuf = squeeze(mean(shuff_corrMatrix_rho_mean));

close all

figPath = '/Users/matt/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .01];

doSave = false;

h = ff(1200,600);
cLims = [-.4 0.4];
rows = 4;
cols = numel(eventFieldnames_wFake);
xmarks = round(logFreqList([1 200],6),0);
usexticks = [];
for ii = 1:numel(xmarks)
    usexticks(ii) = closest(freqList,xmarks(ii));
end

for iEvent = 1:cols
    curMat = squeeze(corrMatrix(iEvent,:,:))';
    subplot_tight(rows,cols,prc(cols,[1 iEvent]),subplotMargins);
    imagesc(curMat,'AlphaData',~isnan(curMat));
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis(cLims);
    xticks(usexticks);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
    
    curMat = squeeze(median(corrMatrix_pval(:,iEvent,:,:)))';
    subplot_tight(rows,cols,prc(cols,[2 iEvent]),subplotMargins);
    imagesc(curMat,'AlphaData',~isnan(curMat));
    colormap(gca,gray);
    set(gca,'ydir','normal');
    caxis([0 1]);
    xticks(usexticks);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
    
    curMat = squeeze(corrMatrix_shuf(iEvent,:,:))';
    subplot_tight(rows,cols,prc(cols,[3 iEvent]),subplotMargins);
    imagesc(curMat,'AlphaData',~isnan(curMat));
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis(cLims);
    xticks(usexticks);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
    
    curMat = squeeze(median(shuff_corrMatrix_pval(:,iEvent,:,:)))';
    subplot_tight(rows,cols,prc(cols,[4 iEvent]),subplotMargins);
    imagesc(curMat,'AlphaData',~isnan(curMat));
    colormap(gca,gray);
    set(gca,'ydir','normal');
    caxis([0 1]);
    xticks(usexticks);
    xticklabels([]);
    yticks(usexticks);
    yticklabels([]);
end

tightfig;
set(gcf,'color','w');
if doSave
    setFig('','',[2,1.75]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'COMODULO.eps'));
    close(h);
end