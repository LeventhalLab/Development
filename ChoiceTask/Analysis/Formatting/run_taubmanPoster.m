figure;
imagesc(t,freqList,log(squeeze(eventScalograms(3,:,:))));
set(gca,'YDir','normal');
xlim([-1 1]);
set(gca,'YScale','log');
set(gca,'Ytick',round(logFreqList(fpass,5)));
colormap(jet);
set(gca,'TickDir','out');

rasterData = tsPeths(:,3);
figure('position',[0 0 800 50]);
plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
xlim([-1 1]);