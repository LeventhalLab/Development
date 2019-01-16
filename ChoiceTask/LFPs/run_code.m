iTrial = 51;
h = ff(1400,500);
rows = 2;
cols = 7;
for iEvent = 1:7
    subplot(rows,cols,prc(cols,[1,iEvent]));
    imagesc(squeeze(abs(W(iEvent,:,iTrial,:)).^2)');
    set(gca,'ydir','normal');
    colormap(gca,jet);
% %     caxis([-6 6]);
    
    subplot(rows,cols,prc(cols,[2,iEvent]));
    yyaxis left;
    imagesc(squeeze(Wz_power(iEvent,:,iTrial,:))');
    set(gca,'ydir','normal');
    colormap(gca,jet);
    caxis([-6 6]);
    
    yyaxis right;
    plot(squeeze(zSDE(iTrial,iEvent,:)),'r','lineWidth',2);
    ylim([-3 3]);
    yticks(sort([0 ylim]));
end