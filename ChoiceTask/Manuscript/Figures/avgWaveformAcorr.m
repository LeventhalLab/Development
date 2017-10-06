% load nexStruct: /Volumes/RecordingsLeventhal2/ChoiceTask/R0088/R0088-processed/R0088_20151102a/R0088_20151102a_finished/R0088_20151102a.nex.mat
doSetup = false;

if doSetup
    % set ts
    ts = nexStruct.neurons{8, 1}.timestamps;
    % set SEV file
    SEVfilename = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch40.sev';
    [meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, SEVfilename);
end

% plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize, 'color',[0 0 0]);

color = [0 0 0];
figuree(500,250);
subplot(121);
t = linspace(-windowSize/2, windowSize/2, length(meanWaveform));
fill([t fliplr(t)], [upperStd fliplr(lowerStd)], color, 'edgeColor', color);
alpha(.25);
hold on
plot(t, meanWaveform, 'color', color, 'lineWidth', 2);
xlimVals = [-.001 .001];
xlim(xlimVals);
xticks([xlimVals(1) 0 xlimVals(2)]);
xticklabels({'-1','0','1'});
ytickVals = [-150 100];
ylim(ytickVals);
yticks([ytickVals(1) 0 ytickVals(2)]);
xlabel('time (ms)');
ylabel('uV');
set(gca,'fontSize',16);

subplot(122);
ISI = diff(ts);
ISI = ISI(ISI~=0); % fix weird issue in one data set where ISI=0
% bins = exp(linspace(log(min(ISI)),log(max(ISI)),100));
xlimVals = [0,0.05];
binEdges = linspace(xlimVals(1),xlimVals(2),70);
[counts,centers] = histcounts(ISI,binEdges);
bar(centers(2:end),counts,'faceColor','k','edgeColor','k');
xlim(xlimVals);
xticks(xlimVals);
xticklabels(xlimVals * 1000);
ylimVals = ylim;
yticks(ylimVals);
xlabel('time (ms)');
ylabel('spikes');
set(gca,'fontSize',16);
set(gcf,'color','w');