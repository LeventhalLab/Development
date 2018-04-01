function zDist = report_openField(trialActograms,stimIDs,powerList,px2mm,zParams,freqLabel)

if numel(stimIDs) == 25
    allDistances = zeros(5,5);
    trialIdxs = ones(5,1);
else
    allDistances = zeros(1,numel(stimIDs));
    trialIdxs = ones(numel(stimIDs),1);
end

for iTrial = 1:size(trialActograms,1)
    allCenters = filter_allCenters(trialActograms{iTrial,3});
    z = smoothn({allCenters(:,1),allCenters(:,2)},'robust');
    D = getDist(z) * px2mm;
    if any(diff(stimIDs))
        stimID = stimIDs(trialActograms{iTrial,2});
    else
        stimID = 1;
    end
    allDistances(stimID,trialIdxs(stimID)) = sum(D) / numel(D); % distance per frame
    trialIdxs(stimID) = trialIdxs(stimID) + 1;
end

figuree(600,600);
subplot(211);
zDist = (mean(allDistances,2) - zParams(1)) / zParams(2);
bar(zDist); % just mean subtracted
% % hold on;
% % errorbar([1:5],mean(all_D,2),std(all_D,[],2),'o');
xticklabels(compose('%1.2f',powerList));
xlabel('laser power (mW)');
ylabel('Z-scored distance traveled');
ylimVals = [-0.5 1.5];
ylim(ylimVals);
yticks(ylimVals(1):0.5:ylimVals(2));
title(['Distance Traveled vs. Opto Power at ',num2str(freqLabel),' Hz']);
grid on;

subplot(212);
colors = lines(5);
for iStim = 1:5
    plot((allDistances(iStim,:) - zParams(1)) / zParams(2),'color',colors(iStim,:),'lineWidth',2);
    hold on;
end
xlabel('trials');
xticks(1:5);
ylabel('Z-scored distance traveled');
legend(compose('%1.2f',powerList));
ylimVals = [-1 3];
ylim(ylimVals);
yticks(ylimVals(1):0.5:ylimVals(2));
title(['Distance Traveled vs. Trial at ',num2str(freqLabel),' Hz']);
grid on;