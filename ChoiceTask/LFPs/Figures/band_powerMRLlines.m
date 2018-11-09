% load('fig__spectrum_MRL_20181108');
% load('deltaRTcorr_norm.mat');

doSave = true;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];

scaloPower = squeeze(median(session_Wz_power(:,:,:,:)));
scaloPhase = squeeze(median(session_Wz_phase(:,:,:,:)));
scaloRayleigh = squeeze(median(session_Wz_rayleigh_pval(:,:,:,:)));

h = ff(600,900);
rows = 4;
cols = 2;

useFreqs = [1 4;4 7;13 30;30 70];
bandLabels = {'\delta','\theta','\beta','\gamma'};
colors = lines(10);
lineWidth = 1;
phaseMap = cmocean('phase');
for iEvent = 3:4
    subplot_tight(rows,cols,prc(cols,[1 iEvent-2]),subplotMargins);
    for iFreq = 1:size(useFreqs,1)
        useRange = closest(freqList,useFreqs(iFreq,1)):closest(freqList,useFreqs(iFreq,2));
        data = mean(squeeze(scaloPower(iEvent,:,useRange)),2);
        plot(linspace(-1,1,size(scaloPower,2)),data,'color',colors(iFreq,:),'lineWidth',lineWidth);
        hold on;
    end
    xticks(0);
    xticklabels([]);
    ylim([-0.75 0.75]);
    yticks(0);
    yticklabels([]);
    grid on;
    
    subplot_tight(rows,cols,prc(cols,[2 iEvent-2]),subplotMargins);
    for iFreq = 1:size(useFreqs,1)
        useRange = closest(freqList,useFreqs(iFreq,1)):closest(freqList,useFreqs(iFreq,2));
        data = mean(squeeze(scaloPhase(iEvent,:,useRange)),2);
        plot(linspace(-1,1,size(scaloPhase,2)),data,'color',colors(iFreq,:),'lineWidth',lineWidth);
        hold on;
    end
    xticks(0);
    xticklabels([]);
    ylim([0 1]);
    yticks(0);
    yticklabels([]);
    grid on;
    
% %     if iEvent == 3
% %         legend(bandLabels,'location','northeast','fontSize',6,'fontName','helvetica');
% %         legend boxoff;
% %     end
    
    subplot_tight(rows,cols,[iEvent+2 iEvent+4],[.1 .02]);
    [v,k] = sort(all_Times);
    phaseCorr = phaseCorrs_delta{iEvent};
    imagesc(linspace(-1,1,size(phaseCorr,2)),1:size(phaseCorr,1),phaseCorr(k,:));
    colormap(gca,parula);
    caxis([-pi pi]);
    xticks(0);
    xticklabels([]);
    yticks([]);
    ylim([1 size(phaseCorr,1)]);
    grid on;
    hold on;
    if iEvent == 3
        plot(v,1:numel(v),'k','lineWidth',1); % plot RT
    else
        plot(-v,1:numel(v),'k','lineWidth',1); % plot RT
    end
end

tightfig;
setFig('','',[1,1]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'band_powerMRLlines.eps'));
    close(h);
end

h = ff(200,400);
colormap(gca,parula);
cb = colorbar;
cb.Ticks = [];
set(cb,'YAxisLocation','bottom');
set(cb,'location','southoutside');
setFig('','',[1,1]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'band_powerMRLlines_colorbar.eps'));
    close(h);
end