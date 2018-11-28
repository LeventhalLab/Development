savePath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
doSave = true;

h = ff(300,800);
data_source_labels = {'sessionRhos_byPower','sessionRhos_byEnvelope','sessionRhos_byPhase'};
bandLabels = {'\delta','\theta','\beta','\gamma','\gamma_h'};
data_source = {sessionRhos_byPower,sessionRhos_byEnvelope,sessionRhos_byPhase};
for ii = 1:3
    theseData = abs(data_source{ii});
    
    subplot(3,1,ii);
    errorbar(1:5,mean(theseData),std(theseData),'color','k','lineWidth',2);
    ylim([-.05 .1]);
    ylabel('|rho|');
    title(data_source_labels{ii},'interpreter','none');
    ffp
    xticks([1:5]);
    xticklabels(bandLabels);
    xlim([0 6]);
end

if doSave
    saveas(h,fullfile(savePath,'highGammeSpikeCorr.png'));
    close(h);
end