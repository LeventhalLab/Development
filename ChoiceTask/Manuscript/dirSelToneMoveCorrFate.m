% dirSelNeuronsNO_type_correct
% dirSelNeuronsNO_type_incorrect

corr_contra_ids = find(dirSelNeuronsNO_type_correct == 1);
corr_ipsi_ids = find(dirSelNeuronsNO_type_correct == 2);
corr_contra_fate = dirSelNeuronsNO_type_incorrect(corr_contra_ids);
corr_ipsi_fate = dirSelNeuronsNO_type_incorrect(corr_ipsi_ids);

contra_fate_counts = histcounts(corr_contra_fate,[-.5:2.5]);
ipsi_fate_counts = histcounts(corr_ipsi_fate,[-.5:2.5]);

colors = [0 0 0;0 1 0;.5 .5 .5;];
legendText = {'NR','SAME','DIFF'};
h = figuree(800,400);
subplot(121);
pie(contra_fate_counts);
title('Correct Contra Fate');
legend(legendText,'location','southoutside');

subplot(122);
pie([ipsi_fate_counts(1) ipsi_fate_counts(3) ipsi_fate_counts(2)]);
title('Correct Ipsi Fate');
legend(legendText,'location','southoutside');

colormap(colors);

addNote(h,{'When the tone is opposite','is the directional selectivity','the SAME or DIFF?'});