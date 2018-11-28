savePath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
doSave = true;

h = ff(300,800);
data_source_labels = {'sessionRhos_byPower','sessionRhos_byEnvelope','sessionRhos_byPhase'};
bandLabels = {'\delta','\theta','\beta','\gamma','\gamma_h'};
data_sources = {data_source_noAlt,data_source_Alt};
colors = [0 0 0;lines(1)];
source_labels = {'noAlt','Alt'};
for iAlt = 1:2
    data_source = data_sources{iAlt};
    for iCorr = 1:3
        theseData = abs(data_source{iCorr});

        subplot(3,1,iCorr);
        errorbar(1:5,mean(theseData),std(theseData),'color',colors(iAlt,:),'lineWidth',2);
        hold on;
        ylim([-.05 .1]);
        ylabel('|rho|');
        title(data_source_labels{iCorr},'interpreter','none');
        ffp
        xticks([1:5]);
        xticklabels(bandLabels);
        xlim([0 6]);
    end
end
legend(source_labels);
if doSave
    saveas(h,fullfile(savePath,'highGammeSpikeCorr_byUnit_wAlt.png'));
    close(h);
end