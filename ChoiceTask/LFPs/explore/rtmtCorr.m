%  load('RTMTpowerCorr_20181108');
% based on crossFrequencyRTMTPowerCorr.m
% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')

close all

doSave = false;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];
tWindow = 1;

timingFields = {'RT','MT'};
climVals_rho = [-0.5 0.5];
climVals_pval = [0 0.5];
iTiming = 1;
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);

h = ff(1200,800);
rows = 4;
cols = 7;
timeCorrs_power_rho = squeeze(mean(all_timeCorrs_power_rho(:,iTiming,:,:,:)));
timeCorrs_power_pval = squeeze(mean(all_timeCorrs_power_pval(:,iTiming,:,:,:)));
timeCorrs_phase_rho = squeeze(mean(all_timeCorrs_phase_rho(:,iTiming,:,:,:)));
timeCorrs_phase_pval = squeeze(mean(all_timeCorrs_phase_pval(:,iTiming,:,:,:)));
t = linspace(-tWindow,tWindow,size(timeCorrs_power_rho,2));
for iEvent = 1:7
    subplot_tight(rows,cols,prc(cols,[1,iEvent]),subplotMargins);
    imagesc(t,1:numel(freqList),squeeze(timeCorrs_power_rho(iEvent,:,:))');
    hold on;
    colormap(gca,cmap);
    set(gca,'ydir','normal');
    caxis(climVals_rho);
    xlim([-tWindow tWindow]);
    xticks([]);
    yticks([]);
    yticklabels([]);
    

    subplot_tight(rows,cols,prc(cols,[2,iEvent]),subplotMargins);
    imagesc(t,1:numel(freqList),squeeze(timeCorrs_phase_rho(iEvent,:,:))');
    hold on;
    colormap(gca,cmap);
    set(gca,'ydir','normal');
    caxis(climVals_rho);
    xlim([-tWindow tWindow]);
    xticks([]);
    yticks([]);
    yticklabels([]);
    
    nSmooth = 10;
    showFreqs = [2,20,55,120];
    colors = lines(4);
    lineWidth = 3;
    subplot_tight(rows,cols,prc(cols,[3,iEvent]),subplotMargins);
    for iFreq = 1:numel(showFreqs)
        plot(t,smooth(squeeze(timeCorrs_power_rho(iEvent,:,closest(freqList,showFreqs(iFreq)))),nSmooth),...
            'linewidth',lineWidth,'color',colors(iFreq,:));
        hold on;
    end
    ylim([-.35 .35]);
    yticks(sort([0,ylim]));
    if iEvent == 7
        legend({'\delta power','\beta power','\gamma_L power','\gamma_h power'});
        legend boxoff;
    end
    set(gca,'fontsize',10);
    
    subplot_tight(rows,cols,prc(cols,[4,iEvent]),subplotMargins);
    for iFreq = 1:numel(showFreqs)
        plot(t,smooth(squeeze(timeCorrs_phase_rho(iEvent,:,closest(freqList,showFreqs(iFreq)))),nSmooth),...
            'linewidth',lineWidth,'color',colors(iFreq,:));
        hold on;
    end
    ylim([0 .5]);
    yticks(ylim);
    if iEvent == 7
        legend({'\delta phase','\beta phase','\gamma_L phase','\gamma_h phase'});
        legend boxoff;
    end
    set(gca,'fontsize',10);
end

tightfig;
setFig('','',[2,4]);
set(gcf,'color','w');
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'rtmtCorr.eps'));
    close(h);
end

if false
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
end