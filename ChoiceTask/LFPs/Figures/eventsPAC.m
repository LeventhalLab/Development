% load('session_20181107_PACdata.mat');

doSave = true;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];

doMedian = true;

eventFieldnames_wFake = [eventFieldnames(:)' {'outTrial'}];
freqList_p = logFreqList([2 10],10);
freqList_a = logFreqList([10 200],10);
freqList = unique([freqList_p freqList_a]);

mean_MImatrix = [];
mean_MImatrix_shuff = [];
for iSession = 1:numel(all_MImatrix)
    MImatrix =  all_MImatrix{iSession};
    MImatrix_shuff =  all_shuff_MImatrix_mean{iSession};
    for iEvent = 1:numel(eventFieldnames_wFake)
        mean_MImatrix(iSession,iEvent,:,:) = MImatrix(iEvent,:,:);
        mean_MImatrix_shuff(iSession,iEvent,:,:) = MImatrix_shuff(iEvent,:,:);
    end
end

pLims = [0 0.001];
zLims = [0 50];
rows = 2;
cols = numel(eventFieldnames_wFake);
h = figuree(1200,350);
for iEvent = 1:numel(eventFieldnames_wFake)
    if doMedian
        curMat = squeeze(median(mean_MImatrix(:,iEvent,:,:)));
        medLabel = 'median';
    else
        curMat = squeeze(mean(mean_MImatrix(:,iEvent,:,:)));
        medLabel = 'mean';
    end
    
    subplot_tight(rows,cols,prc(cols,[1 iEvent]),subplotMargins);
    imagesc(abs(curMat)');
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis(zLims);
    xticks([]);
    xticklabels([]);
    yticks([]);
    yticklabels([]);

    if doMedian
        curMat = squeeze(median(mean_MImatrix_shuff(:,iEvent,:,:)));
    else
        curMat = squeeze(mean(mean_MImatrix_shuff(:,iEvent,:,:))); 
    end
    
    subplot_tight(rows,cols,prc(cols,[2 iEvent]),subplotMargins);
    imagesc(abs(curMat)');
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis(zLims);
    xticks([]);
    xticklabels([]);
    yticks([]);
    yticklabels([]);
end

tightfig;
setFig('','',[2,4]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'eventsPAC.eps'));
    close(h);
end