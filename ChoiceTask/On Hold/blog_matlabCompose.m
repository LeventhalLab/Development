RTs = meanBinCenters;
Zscores = auc_max_z;

fixRTs = sort(all_rt(all_rt > .1));
counts = histcounts(1./fixRTs,50);
figure;
plot(counts);

histInt = .01;
xlimVals = [0 1];
figuree(800,300);
[counts,centers] = hist(all_rt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
bar(centers,counts,'faceColor','k','edgeColor','k');
xlabel('RT (s)');
xlim([0 1]);
xticks([0 1]);
ylim([0 200]);
yticks(ylim);
ylabel('trials');
set(gca,'fontSize',16);
qx = quantile(sort(all_rt),linspace(0,1,11));
hold on
for ii = 1:numel(qx)
    lns = plot([qx(ii) qx(ii)],ylim,'r','lineWidth',1);
end
title('Typical RT Distribution');
set(gcf,'color','w');
legend(lns,'10x Quantiles');

% RTs = reaction times
% Zscores = Z score of neuronal firing associated with RT
figure;
colors = cool(numel(Zscores));
markerSize = 50;
for iiRT = 1:numel(RTs)
    lns(iiRT) = plot(RTs(iiRT),Zscores(iiRT),'.','markerSize',markerSize,'color',colors(iiRT,:));
    hold on;
end

xticks(RTs);
xlabel('RT');
ylabel('Z score');
title('Z score vs. RT');
set(gca,'fontSize',16);
set(gcf,'color','w');

 % #2
figure;
colors = cool(numel(Zscores));
markerSize = 50;
for iiRT = 1:numel(RTs)
    lns(iiRT) = plot(iiRT,Zscores(iiRT),'.','markerSize',markerSize,'color',colors(iiRT,:));
    hold on;
end
xticks(1:numel(RTs));
xlabel('RT');
ylabel('Z score');
title('Z score vs. RT');
set(gca,'fontSize',16);
set(gcf,'color','w');

RTs_labels = compose('%1.3f',RTs);
xticklabels(RTs_labels);
xtickangle(90);
legend(lns,RTs_labels,'fontSize',10);

scatter(1:numel(auc_max_z),auc_max_z,markerSize,meanColors,'filled');
xlabel(timingField,'interpreter','none');
ylabel('auc_max_z','interpreter','none');
[f,gof] = fit([1:numel(auc_max_z)]',auc_max','poly1');
hold on;
plot(1:numel(auc_max_z),f(1:numel(auc_max_z)),'r','lineWidth',2);
title({['auc_max_z vs. ',timingField],['rsquare = ',num2str(gof.rsquare,3)]},'interpreter','none');
% %                 grid on;
xticks([1:numel(auc_max_z)]);
xticklabels(compose('%1.3f',meanBinCenters));