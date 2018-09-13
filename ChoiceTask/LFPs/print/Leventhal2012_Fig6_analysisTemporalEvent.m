doSave = true;
h = ff(600,600);
xtickVals = [];
colors = cool(7);
for iEvent = 1:7
    x = investigateCounts(iEvent,8:16);
    x = smooth(interp(x,10),50);
    area(x,'FaceAlpha',0.4,'FaceColor',colors(iEvent,:));
    hold on;
    lns(iEvent) = plot(x,'color',colors(iEvent,:),'lineWidth',2);
    [v,k] = max(x);
    plot([k k],[-1 1],'-','color',colors(iEvent,:),'lineWidth',1);
    plot(k,v,'x','color',colors(iEvent,:));
    xtickVals(iEvent) = k + rand(1)/100; % force unique
end
legend(lns,eventFieldnames);
ylim([-1 1]);
yticks(sort([ylim 0]));
ylabel('Z bins');
xlim([1 numel(x)]);
[xtickVals_sorted,k] = sort(xtickVals);
xticks(xtickVals_sorted);
xticklabels({eventFieldnames{k}});
xtickangle(270);
xlabel('Spike phase (deg)');

title({[num2str(freqList(investigateFreq),'%1.2f'),' Hz'],titleLabels{iCond}});

set(gcf,'color','w');
if doSave
    saveFreq = strrep(num2str(freqList(investigateFreq),'%1.2f'),'.','-');
    saveas(h,fullfile(savePath,['Leventhal2012_Fig6_spikeHist_events_AllFreqs_',...
        titleLabels{iCond},'_',saveFreq,'Hz.png']));
    close(h);
end