FRs = [];
for iNeuron = 1:numel(all_ts)
    curTs = all_ts{iNeuron};
    FRs(iNeuron) = numel(curTs) / curTs(end);
end

figure;
histogram(FRs,linspace(0,100,20),'FaceColor','k','EdgeColor','k','FaceAlpha',1);
xlim([0 100]);
xlabel('Firing Rate (spikes/sec)');
ylabel('Units');
title(['Firing Rate (FR) distribution of ',num2str(numel(all_ts)),' units']);
set(gca,'fontSize',16);
set(gcf,'color','w');