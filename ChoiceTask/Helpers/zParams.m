function z = zParams(ts,binMs,trials,eventFieldnames)
% --- find MEAN & STD from random trials
trialIdInfo = organizeTrialsById(trials);
tWindow = 1;
tsPeths = eventsPeth(trials,ts,tWindow,eventFieldnames);

tWindow = 1;
binS = binMs / 1000;
histEdges = [-tWindow:binS:tWindow];

histogramBins = [];
for iTrial = 1:size(tsPeths,1)
    curTs = tsPeths{iTrial,1};
    histogramBins(iTrial,:) = histcounts(curTs,histEdges);
end

z = struct;
z.FRsession = numel(ts) / (max(ts) - min(ts));
z.binMeanWindow = mean(histogramBins);
z.binStdWindow = std(histogramBins);
z.FRMeanWindow = z.binMeanWindow / binS;
z.FRStdWindow = z.binStdWindow / binS;
z.binMean = mean(z.binMeanWindow);
z.binStd = mean(z.binStdWindow);
z.FRmean = z.binMean / binS;
z.FRstd = z.binStd / binS;

% randon sample method
% % nSamples = 500;
% % tsPeths = {};
% % a = tWindow;
% % b = max(ts) - tWindow;
% % r = (b-a).*rand(nSamples,1) + a;
% % for iir = 1:numel(r)
% %     tsPeths{iir,1} = tsPeth(ts,r(iir),tWindow);
% % end
% % all_hValues = [];
% % for iTrial = 1:size(tsPeths,1)
% %     ts_event1 = tsPeths{iTrial,1};
% %     hCounts = histcounts(ts_event1,histEdges);
% %     all_hValues(iTrial,:) = hCounts;
% % end
% % zStd = mean(std(all_hValues));
% % zMean = mean(mean(all_hValues));