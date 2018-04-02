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
    plot(linspace(1,numel(D)/60/2,numel(D)),D,'lineWidth',2,'color',colors(iTrial,:));
    allDistances(iTrial,1:numel(D)) = D;
    hold on;
end

% use for both plots
xlimVals = [1 30];
ylimVals = [-1 3];
xlim(xlimVals);
xticks(xlimVals);
ylim(ylimVals);
yticks(ylimVals(1):ylimVals(2));
xlabel('time (s)');
ylabel('Z-scored distance traveled');
title(['Distance Traveled vs. Time at ',num2str(freqLabel),' Hz, ',num2str(powerLabel),' mW, All Trials']);
grid on;


subplot(212);
t = linspace(1,size(allDistances,2)/60/2,size(allDistances,2));
meanD = mean(allDistances);
shadedErrorBar(t,meanD,std(allDistances),{},true);
startIdx = 100;
[v,k] = max(meanD(startIdx:end));
tMax = round(t(k+100),2);
hold on;
plot([tMax tMax],[-5 5],'r-');

xlim(xlimVals);
xticks(sort([tMax,xlimVals]));
ylim(ylimVals);
yticks(ylimVals(1):ylimVals(2));
xlabel('time (s)');
ylabel('Z-scored distance traveled');
title(['Mean, Distance Traveled vs. Time at ',num2str(freqLabel),' Hz, ',num2str(powerLabel),' mW, Mean']);
grid on;