savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/allSessions';

mean_MImatrix_noMix = [];
mean_MImatrix_mix = [];
for iSession = 1:numel(all_MImatrix_noMix)
    MImatrix_noMix =  all_MImatrix_noMix{iSession};
    MImatrix_mix =  all_MImatrix_mix{iSession};
    for iEvent = 1:7
        mean_MImatrix_noMix(iSession,iEvent,:,:) = MImatrix_noMix(iEvent,:,:);
        mean_MImatrix_mix(iSession,iEvent,:,:) = MImatrix_mix(iEvent,:,:);
    end
end
rows = 4;
cols = 7;
h = ff(1300,750);
for iEvent = 1:7
    subplot(rows,cols,prc(cols,[1 iEvent]));
    smean_MImatrix_noMix = squeeze(mean(mean_MImatrix_noMix(:,iEvent,:,:)));
    imagesc(smean_MImatrix_noMix');
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis([-10 10]);
    xticks(1:numel(freqList));
    xticklabels(freqLabels);
    xtickangle(270);
    yticks(1:numel(freqList));
    yticklabels(freqLabels);
    if iEvent == 1
        ylabel('amp (Hz)');
    end
    title({'mean','real',eventFieldnames{iEvent}});
    if iEvent == 7
        cbAside(gca,'Z-MI','k');
    end
    
    pMat = normcdf(smean_MImatrix_noMix,'upper')*numel(freqList).^2;
    subplot(rows,cols,prc(cols,[2 iEvent]));
    imagesc(pMat');
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis([0 .001]);
    xticks(1:numel(freqList));
    xticklabels(freqLabels);
    xtickangle(270);
    yticks(1:numel(freqList));
    yticklabels(freqLabels);
    if iEvent == 1
        ylabel('amp (Hz)');
    end
    if iEvent == 7
        cbAside(gca,'p-value','k');
    end
    
    subplot(rows,cols,prc(cols,[3 iEvent]));
    smean_MImatrix_mix = squeeze(mean(mean_MImatrix_mix(:,iEvent,:,:)));
    imagesc(smean_MImatrix_mix');
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis([-10 10]);
    xticks(1:numel(freqList));
    xticklabels(freqLabels);
    xtickangle(270);
    yticks(1:numel(freqList));
    yticklabels(freqLabels);
    if iEvent == 1
        ylabel('amp (Hz)');
    end
    title({'trial mix'});
    if iEvent == 7
        cbAside(gca,'Z-MI','k');
    end
    
    pMat = normcdf(smean_MImatrix_mix,'upper')*numel(freqList).^2;
    subplot(rows,cols,prc(cols,[4 iEvent]));
    imagesc(pMat');
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis([0 .001]);
    xticks(1:numel(freqList));
    xticklabels(freqLabels);
    xtickangle(270);
    yticks(1:numel(freqList));
    yticklabels(freqLabels);
    xlabel('phase (Hz)');
    if iEvent == 1
        ylabel('amp (Hz)');
    end
    if iEvent == 7
        cbAside(gca,'p-value','k');
    end
end
set(gcf,'color','w');
saveFile = 'allSessions_zscoreTrialwMixed_mean.png';
saveas(h,fullfile(savePath,saveFile));
close(h);

if false
    zs = linspace(3,5,100);
    ys = normcdf(zs,'upper')*numel(freqList).^2;
    ff(400,400);
    plot(zs,ys);
    ylabel('p-value');
    xlabel('Z-score');
    grid on;
end