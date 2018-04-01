function report_extinguishTrials(trialActograms,px2mm,zParams,freqLabel,powerLabel)
nSmooth = 100;

figuree(600,600);
subplot(211);
colors = lines(size(trialActograms,1));
allDistances = [];
for iTrial = 1:size(trialActograms,1)
    allCenters = filter_allCenters(trialActograms{iTrial,3});
    z = smoothn({allCenters(:,1),allCenters(:,2)},'robust');
    D = smooth((getDist(z) * px2mm - zParams(1)) / zParams(2),nSmooth);
    plot(D,'lineWidth',2,'color',colors(iTrial,:));
    allDistances(iTrial,1:numel(D)) = D;
    hold on;
end

% use for both plots
xlimVals = [1 60*30*2];
xticklabelVals = [1 30];

ylimVals = [-1 3];
xlim(xlimVals);
xticks(xlimVals);
xticklabels(xticklabelVals);
ylim(ylimVals);
yticks(ylimVals(1):ylimVals(2));
xlabel('time (s)');
ylabel('Z-scored distance traveled');
title(['Distance Traveled vs. Time at ',num2str(freqLabel),' Hz, ',powerLabel,' mW, All Trials']);
grid on;


subplot(212);
shadedErrorBar(1:size(allDistances,2),mean(allDistances),std(allDistances),{},true);

xlim(xlimVals);
xticks(xlimVals);
xticklabels(xticklabelVals);
ylim(ylimVals);
yticks(ylimVals(1):ylimVals(2));
xlabel('time (s)');
ylabel('Z-scored distance traveled');
title(['Mean, Distance Traveled vs. Time at ',num2str(freqLabel),' Hz, ',num2str(powerLabel),' mW, Mean']);
grid on;