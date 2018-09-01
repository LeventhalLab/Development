doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseUnitTypes';

h = figuree(900,400);
ylimVals = [0 1;0 0.05;0 0.01];
rows = 1;
cols = 3;
usedIds = [];
subplot(rows,cols,1);
for iNeuron = 1:numel(all_spikeHist_pvals)
    if isnan(all_spikeHist_pvals(iNeuron))
        continue;
    end
    usedIds = [usedIds iNeuron];
    plotVals = [all_spikeHist_inTrial_pvals(iNeuron) all_spikeHist_outTrial_pvals(iNeuron)];
    plot([1,2],plotVals,'ko');
    hold on;
    plot([1,2],plotVals,'k-');
    set(gca,'yscale','log');
%         ylim(ylimVals(iiy,:));
%         yticks(ylim);
    ylabel('Rayleigh p-val');
    xlim([0.5 2.5]);
    xticks([1,2]);
    xticklabels({'IN','OUT'});
end

subplot(rows,cols,2);
IN_entrained = all_spikeHist_inTrial_pvals(usedIds) < all_spikeHist_outTrial_pvals(usedIds);
OUT_entrained = all_spikeHist_inTrial_pvals(usedIds) > all_spikeHist_outTrial_pvals(usedIds);
lns(1) = bar([sum(IN_entrained),sum(OUT_entrained)],'k');
hold on;
lns(2) = bar([sum(all_spikeHist_inTrial_pvals(usedIds) < 0.05 & IN_entrained),...
    sum(all_spikeHist_outTrial_pvals(usedIds) < 0.05 & OUT_entrained)],'r');
xticks([1,2]);
xticklabels({'IN entrained','OUT entrained'});
xtickangle(30);
ylim([0 100]);
ylabel('units');
yticks(ylim);
legend(lns,{'All','p < 0.05'});

subplot(rows,cols,3);
bar([sum((all_spikeHist_pvals(usedIds) < 0.05 & IN_entrained) & all_spikeHist_outTrial_pvals(usedIds) > 0.05),...
    sum((all_spikeHist_pvals(usedIds) < 0.05 & OUT_entrained) & all_spikeHist_inTrial_pvals(usedIds) > 0.05)],'k');
xticks([1,2]);
xticklabels({'p < 0.05 IN, ~out','p < 0.05 OUT, ~in'});
xtickangle(30);
ylim([0 25]);
yticks(ylim);
ylabel('units');

set(gcf,'color','w');

if doSave
    saveFile = ['entrainment_IN-OUTofTrial.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end