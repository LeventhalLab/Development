close all
h = ff(600,800);
data_source_labels = {'sessionRhos_byPower','sessionRhos_byEnvelope','sessionRhos_byPhase'};
data_source = {sessionRhos_byPower,sessionRhos_byEnvelope,sessionRhos_byPhase};
for ii = 1:3
    theseData = abs(data_source{ii});
    
    subplot(3,1,ii);
    errorbar(1:5,mean(theseData),std(theseData),'color','k','lineWidth',2);
    ylim([-.05 .15]);
    xlabel('freq');
    ylabel('|rho|');
    title(data_source_labels{ii},'interpreter','none');
    ffp
    xticks([1:5]);
    xlim([0 6]);
end
