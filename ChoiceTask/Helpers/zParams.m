function z = zParams(ts,trials)
% --- find MEAN & STD from random trials
% trialIdInfo = organizeTrialsById(trials);

dodebug = false;

eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
binMs = 20;
tWindow = 2;
nSmooth = 5;
tsPeths = eventsPeth(trials,ts,tWindow,eventFieldnames);

binS = binMs / 1000;
histEdges = [-tWindow:binS:0];

if dodebug
    figuree(300,800);
end

histogramBins = [];
for iTrial = 1:size(tsPeths,1)
    curTs = tsPeths{iTrial,1}; % use cueOn
    histogramBins(iTrial,:) = smooth(histcounts(curTs,histEdges),nSmooth);
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
z.CV = z.FRmean / z.FRstd;

if dodebug
    z
    subplot(7,1,iEvent);
    errorbar(z.FRMeanWindow,z.FRStdWindow);
    ylim([0 70]);
end
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