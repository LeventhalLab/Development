%  load('RTMTpowerCorr_20181108');
% based on crossFrequencyRTMTPowerCorr.m
doSave = true;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];
tWindow = 1;

timingFields = {'RT','MT'};
climVals_rho = [-0.5 0.5];
climVals_pval = [0 0.5];
iTiming = 1;
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);

h = figuree(1200,450);
rows = 2;
cols = 7;
timeCorrs_power_rho = squeeze(mean(all_timeCorrs_power_rho(:,iTiming,:,:,:)));
timeCorrs_power_pval = squeeze(mean(all_timeCorrs_power_pval(:,iTiming,:,:,:)));
timeCorrs_phase_rho = squeeze(mean(all_timeCorrs_phase_rho(:,iTiming,:,:,:)));
timeCorrs_phase_pval = squeeze(mean(all_timeCorrs_phase_pval(:,iTiming,:,:,:)));
for iEvent = 1:7
    subplot_tight(rows,cols,prc(cols,[1,iEvent]),subplotMargins);
    imagesc(linspace(-tWindow,tWindow,size(timeCorrs_power_rho,2)),1:numel(freqList),squeeze(timeCorrs_power_rho(iEvent,:,:))');
    colormap(gca,cmap);
    set(gca,'ydir','normal');
    caxis(climVals_rho);
    xlim([-tWindow tWindow]);
    xticks([]);
    yticks([]);
    yticklabels([]);

    subplot_tight(rows,cols,prc(cols,[2,iEvent]),subplotMargins);
    imagesc(linspace(-tWindow,tWindow,size(timeCorrs_power_rho,2)),1:numel(freqList),squeeze(timeCorrs_phase_rho(iEvent,:,:))');
    colormap(gca,cmap);
    set(gca,'ydir','normal');
    caxis(climVals_rho);
    xlim([-tWindow tWindow]);
    xticks([]);
    yticks([]);
    yticklabels([]);
end
tightfig;
setFig('','',[2,4]);
set(gcf,'color','w');
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'rtmtCorr.eps'));
    close(h);
end

h = ff(1200,250);
subplot_tight(1,cols,7,subplotMargins);
colormap(gca,cmap);
cb = colorbar;
cb.Ticks = [];
cb = colorbar;
cb.Ticks = [];
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'rtmtCorr_colorbar.eps'));
    close(h);
end