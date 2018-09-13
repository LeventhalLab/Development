
h = ff(600,600);
xtickVals = [];
colors = lines(7);
for iEvent = 1:7
    x = investigateCounts(iEvent,8:17);
    x = smooth(interp(x,10),50);
    plot(x,'color',colors(iEvent,:),'lineWidth',2);
    hold on;
    [v,k] = max(x);
    plot([k k],[-1 1],'-','color',colors(iEvent,:),'lineWidth',0.5);
    xtickVals(iEvent) = k + rand(1)/100; % force unique
end
ylim([-1 1]);
[xtickVals_sorted,k] = sort(xtickVals);
xticks(xtickVals_sorted);
xticklabels({eventFieldnames{k}});
xtickangle(270);

