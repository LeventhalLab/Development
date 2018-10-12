%%
targetFreqIdx = 24;
tlim = [-0.3,0.3];

meanPSD_expanded = repmat(mean_psd,[1,size(toPlot,2)]);
stdPSD_expanded = repmat(std_psd,[1,size(toPlot,2)]);
toPlot = log10(squeeze(allTsScalograms{3}(1,7:36,:)));

toPlot2 = (squeeze(allTsScalograms{3}(1,7:36,:)) - meanPSD_expanded(7:36,:)) ./ stdPSD_expanded(7:36,:);
cmin = min(toPlot(targetFreqIdx,:));
cmax = max(toPlot(targetFreqIdx,:));

figure(1)
h_pcolor = pcolor(t,f(7:36),toPlot);
h_pcolor.EdgeColor = 'none';
set(gca,'ydir','normal','yscale','log','ytick',[10 20 50 100 200],'xlim',tlim)
% set(gca,'clim',[cmin-0.5,cmax])
colormap('jet')
colorbar

cmin = min(toPlot2(targetFreqIdx,:));
cmax = max(toPlot2(targetFreqIdx,:));
figure(2)
h_pcolor = pcolor(t,f(7:36),toPlot2);
h_pcolor.EdgeColor = 'none';
set(gca,'ydir','normal','yscale','log','ytick',[10 20 50 100 200],'xlim',tlim)
% set(gca,'clim',[cmin-0.5,cmax])
colormap('jet')
colorbar
