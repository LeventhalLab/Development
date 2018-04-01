function report_zDist(all_zDist,powerList)

figure;
bar(all_zDist);
ylim([-1 2]);
xticklabels(compose('%1.2f',powerList));
xlabel('laser power (mW)');
ylabel('Z-scored distance traveled');
ylimVals = [-0.5 1.5];
ylim(ylimVals);
yticks(ylimVals(1):0.5:ylimVals(2));
legend({'0 Hz','20 Hz','50 Hz','100 Hz'},'location','northwest');
title('Distance Traveled vs. Opto Power and Freq');