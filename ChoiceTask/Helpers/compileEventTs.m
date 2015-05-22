function eventTs = compileEventTs(nexStruct,compiledEvents,eventFieldnames,iEvent)
eventTs = [];
for iSubFields=1:length(compiledEvents.(eventFieldnames{iEvent}))
    theEvent = nexStruct.events(compiledEvents.(eventFieldnames{iEvent}));
    eventTs = [eventTs;theEvent{iSubFields}.timestamps];
end