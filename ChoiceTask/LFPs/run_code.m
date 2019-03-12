rows = 3;
cols = 4;
h = ff(1400,800);

for iFreq = 1:12
    subplot(rows,cols,iFreq);
    data_power = squeeze(all_powerCorrs(1,3,:,iFreq));
    data_power_pval = squeeze(all_powerPvals(1,3,:,iFreq));
    data_phase = squeeze(all_phaseCorrs(1,3,:,iFreq));
    data_phase_pval = squeeze(all_phasePvals(1,3,:,iFreq));

    colors = lines(2);


    t = linspace(-1,1,size(all_powerCorrs,3));

    timePeriod = 2;
    Fs = 1000;
    oscillationFreq = [freqList(iFreq)];
    oscillationOnOff = [1.1 2];
    [lfp,~] = groundTruthLFP(timePeriod,Fs,oscillationFreq,oscillationOnOff);
    W = calculateComplexScalograms_EnMasse(lfp,'Fs',Fs,'freqList',freqList(iFreq));
    tW = linspace(-1,1,size(W,1));

    yyaxis left;
    plot(t,data_power,'-','color',colors(1,:));
    hold on;
    plot(t,data_phase,'-','color',colors(2,:));
    plot(tW,real(W),'k-');
    ylabel('rho');
    ylim([-.2 .4]);
    yticks(sort([ylim,0]));

    yyaxis right;
    plot(t,data_power_pval,':','color',colors(1,:));
    hold on;
    plot(t,data_phase_pval,':','color',colors(2,:));
    plot([-1 1],[0.05 0.05],'r-');
    ylabel('p-value');
    ylim([0 1]);
    yticks(ylim);

    xlim([-1 1]);
    xticks([-1 0 1]);
    legend({'\delta-power','\delta-phase'});
    title(sprintf('%1.2f Hz',freqList(iFreq)));
end