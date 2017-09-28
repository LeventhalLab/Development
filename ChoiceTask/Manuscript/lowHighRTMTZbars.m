colors = lines(2);
meanIdx = [20:21];
figure;
bar1 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byRT_binIncMs10_binMs50LRTHMT(:,meanIdx);
bar2 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byRT_binIncMs10_binMs50HRTLMT(:,meanIdx);
bar3 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byMT_binIncMs10_binMs50LRTHMT(:,meanIdx);
bar4 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byMT_binIncMs10_binMs50HRTLMT(:,meanIdx);

[h12,p12] = ttest2(nanmean(bar1),nanmean(bar2));
[h34,p34] = ttest2(nanmean(bar3),nanmean(bar4));
errorbar([1:4],[nanmean(nanmean(bar1)),nanmean(nanmean(bar2)),nanmean(nanmean(bar3)),nanmean(nanmean(bar4))],[],...
    [nanmean(nanstd(bar1)),nanmean(nanstd(bar2)),nanmean(nanstd(bar3)),nanmean(nanstd(bar4))],'.','color',colors(1,:));
hold on;
bar([1:4],[nanmean(nanmean(bar1)),nanmean(nanmean(bar2)),nanmean(nanmean(bar3)),nanmean(nanmean(bar4))],'faceColor',colors(1,:),'edgeColor','none');
if h12
    sigstar({[1,2]},[p12]);
else
    sigstar({[1,2]},[nan]);
end
if h34
    sigstar({[3,4]},[p34]);
else
    sigstar({[3,4]},[nan]);
end

ylabel('mean Z @ t = 0');
xlim([0 5]);
ylim([0 2.5]);
xticks([1:4]);
xticklabels({'low RT (high MT)','high RT (low MT)','high MT (low RT)','low MT (high RT)'});
xtickangle(45);
title('low RT conditions show higher FR at nose out');

set(gcf,'color','w');



figure;
bar1 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byRT_binIncMs10_binMs50LRTLMT(:,meanIdx);
bar2 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byRT_binIncMs10_binMs50HRTHMT(:,meanIdx);
bar3 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byMT_binIncMs10_binMs50LRTLMT(:,meanIdx);
bar4 = all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byMT_binIncMs10_binMs50HRTHMT(:,meanIdx);

[h12,p12] = ttest2(nanmean(bar1),nanmean(bar2));
[h34,p34] = ttest2(nanmean(bar3),nanmean(bar4));
errorbar([1:4],[nanmean(nanmean(bar1)),nanmean(nanmean(bar2)),nanmean(nanmean(bar3)),nanmean(nanmean(bar4))],[],...
    [nanmean(nanstd(bar1)),nanmean(nanstd(bar2)),nanmean(nanstd(bar3)),nanmean(nanstd(bar4))],'.','color',colors(2,:));
hold on;
bar([1:4],[nanmean(nanmean(bar1)),nanmean(nanmean(bar2)),nanmean(nanmean(bar3)),nanmean(nanmean(bar4))],'faceColor',colors(2,:),'edgeColor','none');
if h12
    sigstar({[1,2]},[p12]);
else
    sigstar({[1,2]},[nan]);
end
if h34
    sigstar({[3,4]},[p34]);
else
    sigstar({[3,4]},[nan]);
end

ylabel('mean Z @ t = 0');
xlim([0 5]);
ylim([0 2.5]);
xticks([1:4]);
xticklabels({'low RT/MT','high RT/MT','low MT/RT','high MT/RT'});
xtickangle(45);
title('low RT/MT conditions are always associated with higher FR');

set(gcf,'color','w');