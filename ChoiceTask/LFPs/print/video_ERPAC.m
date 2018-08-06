M = squeeze(all_M(2,:,:,:,:));

h = figuree(1500,550);
rows = 3;
cols = 7;
for iRow = 1:rows
    for iEvent = 1:cols
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        hm = slice(squeeze(M(iEvent,:,:,:)),[],1:size(ERPAC_rho,2),[]);
% %             [xs,ys,zs] = ndgrid( 1:25 , 1:50 , 1:4 ) ;
        shading interp;
        colormap(jet);
        caxis([0 0.5]);
        set(hm,'FaceAlpha',0.05);
        view(views(iRow,:));
        xlabel('amp (Hz)');
        zlabel('phase (Hz)');
        ylabel('time (s)');
        xticks(freqIdx);
        xticklabels(freqLabels);
        zticks(freqIdx);
        zticklabels(freqLabels);
        yticks([1 round(size(ERPAC_rho,2)/2) size(ERPAC_rho,2)]);
        yticklabels([-tWindow,0,tWindow]);
        set(gca,'fontsize',7);
        if iRow == 1
            title(eventFieldnames{iEvent});
        end
        if iEvent == 7
            cb = cbAside(gca,['corr, p <',num2str(pvalThresh,'%1.2f')],'k');
        end
    end
end
set(gcf,'color','w');