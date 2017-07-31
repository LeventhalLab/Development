function unitEventsHistogram(unitEvents,eventFieldnames)

compiledEvents = [];
for iNeuron = 1:numel(unitEvents)
    if isempty(unitEvents{iNeuron}.class)
        continue;
    end
    compiledEvents = [compiledEvents unitEvents{iNeuron}.class(1)];
end

useEvents = 1:numel(eventFieldnames);
% % colors = lines(1);
figure;
[counts,centers] = hist(compiledEvents,useEvents);
bar(centers,counts,'FaceColor','k','EdgeColor','none');
xlim([0 numel(useEvents) + 1]);
ylim([0 max(counts) + 10]);
xticklabels(eventFieldnames);
xtickangle(60);
ylabel('Classified units');

for iEvent = useEvents
    text(iEvent,counts(iEvent)+3,num2str(counts(iEvent)),'HorizontalAlignment','center');
end