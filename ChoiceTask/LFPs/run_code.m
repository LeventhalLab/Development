if ~exist('entrain_hist')
    load('20190318_entrain.mat')
    load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
    load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
end

inLabels = {'IN Trial','INTER Trial'};
freqList = logFreqList([1 200],30);
allUnits = 1:366;
allUnits = allUnits(~ismember(allUnits,[dirSelUnitIds,ndirSelUnitIds]));
dirUnits = {allUnits,dirSelUnitIds,ndirSelUnitIds};
dirLabels = {'allUnits','ndirSel','dirSel'};
surrLabels = {'Real Spikes','Poisson Spikes'};
iFreq = 6; % 2.5 Hz
all_p = squeeze(entrain_pvals(1,1,:,iFreq));
all_r = squeeze(entrain_rs(1,1,:,iFreq));

[p_min,k_min] = min(all_p);
[k_mid,p_mid] = closest(all_p,0.08);

fontSize = 16;
nBins = 20;
rlimVal = .14;
dirColor = lines(4);
edges = linspace(-pi,pi,13);
rows = 2;
cols = 2;
close all;
ff(1000,600);
for iCond = 1:2
    min_hist = squeeze(entrain_hist(1,iCond,k_min,:,iFreq));
    mid_hist = squeeze(entrain_hist(1,iCond,k_mid,:,iFreq));
    mu_min = squeeze(entrain_mus(1,iCond,k_min,iFreq));
    r_min = squeeze(entrain_rs(1,iCond,k_min,iFreq));
    mu_mid = squeeze(entrain_mus(1,iCond,k_mid,iFreq));
    r_mid = squeeze(entrain_rs(1,iCond,k_mid,iFreq));
    all_p = squeeze(entrain_pvals(1,iCond,:,iFreq));
    all_r = squeeze(entrain_rs(1,iCond,:,iFreq));
    p_min = all_p(k_min);
    p_mid = all_p(k_mid);
    
    disp(iCond);
    fprintf('MIN p = %d, MRL = %1.2f\n',p_min,r_min);
    fprintf('MID p = %d, MRL = %1.2f\n',p_mid,r_mid);
    
    subplot(rows,cols,prc(cols,[1,1]));
    polarhistogram('BinEdges',edges,'BinCounts',min_hist,'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',2);
    hold on;
    polarplot([mu_min,mu_min],[0 rlimVal],':','color',dirColor(iCond+2,:),'linewidth',2);
    pax = gca;
    pax.ThetaZeroLocation = 'left';
    thetaticks([0,90,180,270]);
    rlim([0 rlimVal]);
    rticks(rlim);
    if iCond == 2
% %         title({inLabels{iCond},sprintf('unit %i, p = %d, MRL = %1.3f',k_mid,p_mid,r_mid)});
        title(sprintf('dirSel unit %i',k_min));
        legend({inLabels{1},'mean angle',inLabels{2},'mean angle'});
        set(gca,'fontSize',fontSize);
    end

    subplot(rows,cols,prc(cols,[2,1]));
    polarhistogram('BinEdges',edges,'BinCounts',mid_hist,'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',2);
    hold on;
    polarplot([mu_mid,mu_mid],[0 rlimVal],':','color',dirColor(iCond+2,:),'linewidth',2);
    pax.ThetaZeroLocation = 'left';
    thetaticks([0,90,180,270]);
    rlim([0 rlimVal]);
    rticks(rlim);
    if iCond == 2
% %         title({inLabels{iCond},sprintf('unit %i, p = %d, MRL = %1.3f',k_mid,p_mid,r_mid)});
        title(sprintf('dirSel unit %i',k_mid));
        legend({inLabels{1},'mean angle',inLabels{2},'mean angle'});
        set(gca,'fontSize',fontSize);
    end
    
    subplot(rows,cols,prc(cols,[1,2]));
    histogram(all_p,linspace(0,1,nBins),'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',2);
    hold on;
    ylim([0 0.5]);
    ylabel('Fraction of Units');
    xlabel('p-value');
    title('P-value Distribution');
    if iCond == 2
        legend(inLabels);
        set(gca,'fontSize',fontSize);
    end
    
    subplot(rows,cols,prc(cols,[2,2]));
    histogram(all_r,linspace(0,0.15,nBins),'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',2);
    hold on;
    ylim([0 0.5]);
    ylabel('Fraction of Units');
    xlabel('MRL');
    title('MRL Distribution');
    if iCond == 2
        legend(inLabels);
        set(gca,'fontSize',fontSize);
    end
end