h = figure;

allCaxis = [];
adjSubplots = [];
for iSubplot=1:3
    subplot(3,1,iSubplot);
    imagesc(t,freqList,log(squeeze(allScalograms(iSubplot,:,:))));
    ylabel('Freq (Hz)');
    set(gca,'YDir','normal');
    xlim([-1 1]);
    set(gca,'YScale','log');
    set(gca,'Ytick',round(logFreqList(fpass,5)));
    colormap(jet);
    allCaxis(iSubplot,:) = caxis;
    adjSubplots = [adjSubplots iSubplot];
end
% set all caxis to 25% full range
caxisValues = upperLowerPrctile(allCaxis,25);
for iSubplot=1:3
    subplot(3,1,iSubplot);
    caxis(caxisValues);
end