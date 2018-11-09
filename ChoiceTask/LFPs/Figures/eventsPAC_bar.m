doSave = true;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';

compiled_pvals_beta = [];
compiled_pvals_gamma = [];
ifp_1 = closest(freqList_p,2);
ifp_2 = closest(freqList_p,4);
ifA_beta = closest(freqList_a,20);
ifA_gamma = closest(freqList_a,50);
for iSession = 1:size(mean_MImatrix,1)
    for iEvent = 1:numel(eventFieldnames_wFake)
        curMat = squeeze(mean_MImatrix(iSession,iEvent,:,:));
        pMat = normcdf(curMat,'upper')*numel(freqList).^2;
        compiled_pvals_beta(iSession,iEvent) = mean(pMat(ifp_1:ifp_2,ifA_beta));
        compiled_pvals_gamma(iSession,iEvent) = mean(pMat(ifp_1:ifp_2,ifA_gamma));
    end
end

colors = lines(4);
h = ff(400,300);
pThresh = 0.001;
pval_bar_beta = sum(compiled_pvals_beta < pThresh) ./ size(mean_MImatrix,1);
pval_bar_gamma = sum(compiled_pvals_gamma < pThresh) ./ size(mean_MImatrix,1);
hb = bar([pval_bar_beta' pval_bar_gamma'],1,'EdgeColor','none');
hb(1).FaceColor = colors(3,:);
hb(2).FaceColor = colors(4,:);
xticks([]);
ylim([0 1]);
yticks([]);

hold on;
plot(xlim,[pval_bar_beta(end) pval_bar_beta(end)],':','color',colors(3,:));
plot(xlim,[pval_bar_gamma(end) pval_bar_gamma(end)],':','color',colors(4,:));

tightfig;
setFig('','',[1,1]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'eventsPAC_bar.eps'));
    close(h);
end