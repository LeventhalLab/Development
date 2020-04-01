close all
for iTrial = 1:size(Wz_power,3)
    if find(squeeze(Wz_power(:,:,iTrial,:)) > 50)
        ff(1200,300);
        for iEvent = 1:8
            subplot(1,8,iEvent);
            theseData = squeeze(Wz_power(iEvent,:,iTrial,:));
            imagesc(theseData');
            colormap(jet);
            title(sprintf('%i %i',iTrial,iEvent));
            set(gca,'YDir','normal');
            caxis([1 30]);
        end
    end
end