% session R0142_20161208a has 8 dirSel units

all_z_x = [];
neuronCount = 1;
figure;
for iNeuron = 1:numel(analysisConf.neurons)
    if ~strcmp(analysisConf.sessionNames(iNeuron),'R0142_20161208a') || ~dirSelNeurons(iNeuron)
        continue;
    end
    ts_x = all_ts{iNeuron};
    trials_x = all_trials{iNeuron};
    trialIdInfo_x = organizeTrialsById(trials_x);

    binSize = 0.25; % seconds
%     binEdges = 0:binSize:max(ts_x);
    binEdges = linspace(0,max(ts_x),3600/binSize);

    counts_x = histcounts(ts_x,binEdges);
    plot(counts_x);
    hold on;
    z_x = (counts_x - mean(counts_x)) / std(counts_x);
    all_z_x(neuronCount,:) = z_x;
    neuronCount = neuronCount + 1;
end
mean_all_z_x = smooth(mean(all_z_x),4);
% figure;
% plot(all_z_x','color',[0 0 0 0.2]); hold on;
% plot(mean_all_z_x,'b');
% hold on;

plot_n = 2/binSize;
all_mean_centerIn_z = [];
all_centerInIdx = [];
for iTrial = 1:numel(trialIdInfo_x.correct)
    timing_x = trials_x(trialIdInfo_x.correct(iTrial)).timestamps;
    plotIdxs = find(binEdges >= timing_x.centerIn,plot_n);
    plot(plotIdxs,mean_all_z_x(plotIdxs),'r');
    all_mean_centerIn_z(iTrial,:) = mean_all_z_x(plotIdxs);
    all_centerInIdx(iTrial) = plotIdxs(1);
    plot(plotIdxs(1),0,'r*');
end

figure;
plot(all_mean_centerIn_z','color',[0 0 0 0.2]);
hold on;
plot(smooth(mean(all_mean_centerIn_z),4),'r');

neuronId = 67;
ts_x = all_ts{neuronId};
trials_x = all_trials{neuronId};
trialIdInfo_x = organizeTrialsById(trials_x);

binSize = 0.1; % seconds
binEdges = 0:binSize:max(ts_x);

counts_x = histcounts(ts_x,binEdges);
z_x = (counts_x - mean(counts_x)) / std(counts_x);

figure;
startFigureMinusT = 3;
plot_n = 100;
all_zx = NaN(numel(trialIdInfo_x.correct),plot_n);
eventColors = lines(7);
for iTrial = 1:numel(trialIdInfo_x.correct)
    timing_x = trials_x(trialIdInfo_x.correct(iTrial)).timestamps;
    plotIdxs = find(binEdges >= timing_x.centerIn - startFigureMinusT & binEdges < timing_x.foodRetrieval,plot_n);
    plot(counts_x(plotIdxs),'color',[0 0 0 0.2]);
    all_zx(iTrial,1:numel(plotIdxs)) = counts_x(plotIdxs);
    hold on;
    for iEvent = 3:7
        event_ts = getfield(timing_x,eventFieldnames{iEvent});
        event_ts_toIdx = round((event_ts - timing_x.centerIn) / binSize) + (startFigureMinusT / binSize);
        plot(event_ts_toIdx + rand(1) - 0.5,rand(1) - .5,'*','color',eventColors(iEvent,:));
    end
end
plot(nanmean(all_zx),'r')
xlim([1 plot_n]);