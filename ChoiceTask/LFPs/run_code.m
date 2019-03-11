% load('201903_RTMTcorr_iSession30_nSessions30.mat')
% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
freqList = logFreqList([1 200],30);
% % % % showFreqs = [2,6,18.6,55,120];
iTiming = 1;
iFreq = 17;

% close all

h = ff(1400,400);
rows = 2;
cols = 2;
colors = cool(nRT);
nSmooth = 10;
useEvents = 3:4;
for iRT = 1:nRT
    all_powerCorrs = all_RT_powerCorrs{iRT};
    all_powerPvals = all_RT_powerPvals{iRT};
    all_phaseCorrs = all_RT_phaseCorrs{iRT};
    all_phasePvals = all_RT_phasePvals{iRT};
    
    timeCorrs_power_rho = squeeze((all_powerCorrs(iTiming,:,:,:)));
    timeCorrs_power_pval = squeeze((all_powerPvals(iTiming,:,:,:)));%*30;
    timeCorrs_phase_rho = squeeze((all_phaseCorrs(iTiming,:,:,:)));
    timeCorrs_phase_pval = squeeze((all_phasePvals(iTiming,:,:,:)));%*30;
    t = linspace(-1,1,size(timeCorrs_phase_pval,2));
    iSubplot = 1;
    for iEvent = useEvents
        data_rho = squeeze(timeCorrs_power_rho(iEvent,:,iFreq));
        subplot(rows,cols,prc(cols,[1,iSubplot]));
        plot(t,smooth(data_rho,nSmooth),'color',colors(iRT,:),'linewidth',2);
        hold on;
        ylabel('rho');
        ylim([-0.5 0.5]);
        yticks(sort([0,ylim]));
        xlim([-1 1]);
        xticks([-1 0 1]);
        title(eventFieldnames{iEvent});
        colorbar;
        grid on;

        data_pval = pval_adjust(squeeze(timeCorrs_power_pval(iEvent,:,iFreq)),'bonferroni');
        subplot(rows,cols,prc(cols,[2,iSubplot]));
        plot(t,smooth(data_pval,nSmooth),'color',colors(iRT,:),'linewidth',1);
        hold on;
        ylabel('p-value');
        ylim([0 1]);
        yticks(ylim);
        xlim([-1 1]);
        xticks([-1 0 1]);
        colorbar;
        colormap(colors);
        grid on;
        
        iSubplot = iSubplot + 1;
    end
end
set(gcf,'color','w');