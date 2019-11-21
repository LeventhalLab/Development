if ~exist('entrain_hist')
    load('20190318_entrain.mat')
    load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
    load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
end

figPath = '/Users/matt/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
doSave = true;
doLabels = false;

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

lineStyle = ':';
lineWidth = 1;
fontSize = 16;
nBins = 20;
rlimVal = .14;
dirColor = lines(4);
edges = linspace(-pi,pi,13);
rows = 2;
cols = 2;
close all;
h = ff(1000,600);
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
    
    subplotMargins = [.02 .02];
    subtightplot(rows,cols,prc(cols,[1,1]),subplotMargins);
    polarhistogram('BinEdges',edges,'BinCounts',min_hist,'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',lineWidth);
    hold on;
    polarplot([mu_min,mu_min],[0 rlimVal],lineStyle,'color',dirColor(iCond+2,:),'linewidth',lineWidth);
    pax = gca;
    pax.ThetaZeroLocation = 'left';
    thetaticks([0,90,180,270]);
    rlim([0 rlimVal]);
    rticks(rlim);
    if ~doLabels
        rticklabels({});
        thetaticklabels({});
    end
    if iCond == 2 && doLabels
        title(sprintf('dirSel unit %i',k_min));
        legend({inLabels{1},'mean angle',inLabels{2},'mean angle'});
        set(gca,'fontSize',fontSize);
    end
    
    subtightplot(rows,cols,prc(cols,[1,2]),subplotMargins);
    polarhistogram('BinEdges',edges,'BinCounts',mid_hist,'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',lineWidth);
    hold on;
    polarplot([mu_mid,mu_mid],[0 rlimVal],lineStyle,'color',dirColor(iCond+2,:),'linewidth',lineWidth);
    pax.ThetaZeroLocation = 'left';
    thetaticks([0,90,180,270]);
    rlim([0 rlimVal]);
    rticks(rlim);
    if ~doLabels
        rticklabels({});
        thetaticklabels({});
    end
    if iCond == 2 && doLabels
        title(sprintf('dirSel unit %i',k_mid));
        legend({inLabels{1},'mean angle',inLabels{2},'mean angle'});
        set(gca,'fontSize',fontSize);
    end
    
    subplotMargins = [.3 .02];
    subtightplot(rows,cols,prc(cols,[2,1]),subplotMargins);
    histogram(all_p,linspace(0,1,nBins),'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',lineWidth);
    hold on;
    xticks(xlim);
    ylim([0 0.5]);
    yticks(ylim);
    if doLabels
        ylabel('Fraction of Units');
        xlabel('p-value');
        title('P-value Distribution');
    else
        yticklabels({});
        xticklabels({});
% %         box off;
    end
    if iCond == 2 && doLabels
        legend(inLabels);
        set(gca,'fontSize',fontSize);
    end
    
    subtightplot(rows,cols,prc(cols,[2,2]),subplotMargins);
    histogram(all_r,linspace(0,0.15,nBins),'DisplayStyle','stairs','EdgeColor',dirColor(iCond+2,:),...
        'Normalization','probability','LineWidth',lineWidth);
    hold on;
    xticks(xlim);
    ylim([0 0.5]);
    yticks(ylim);
    if doLabels
        ylabel('Fraction of Units');
        xlabel('MRL');
        title('MRL Distribution');
    else
        yticklabels({});
        xticklabels({});
% %         box off;
    end
    if iCond == 2 && doLabels
        legend(inLabels);
        set(gca,'fontSize',fontSize);
    end
end

set(gcf,'color','w');
if doSave
    setFig('','',[1.5,1.5]);
    print(gcf,'-painters','-depsc',fullfile(figPath,['MRLXFREQ_TOP.eps']));
    close(h);
end