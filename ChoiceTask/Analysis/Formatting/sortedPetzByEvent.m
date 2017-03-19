totalRows = 4; % sorted by: trial #, RT, MT, Z-score (w/ RT&MT markers)
% all_eventPetz{iNeuron} = allZs{iEvent,iTrial}
% => petz{iEvent} = {iNeuron,meanPetzAllTrials}
for iEvent = plotEventIds
    ax = subplot(totalRows,length(plotEventIds),iSubplot);
    eventPetz = 
end