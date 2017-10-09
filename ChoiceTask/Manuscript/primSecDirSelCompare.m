for iEvent = 1:numel(eventFieldnames)
    primary_class = 0;
    primary_dir = 0;
    secondary_class = 0;
    secondary_dir = 0;
    for iNeuron = 1:numel(analysisConf.neurons)
        if ~isempty(unitEvents{iNeuron}.class)
            if unitEvents{iNeuron}.class(1) == iEvent
                primary_class = primary_class + 1;
                if dirSelNeurons(iNeuron)
                    primary_dir = primary_dir + 1;
                end
            end
            if ~isempty(unitEvents{iNeuron}.class(2))
                if unitEvents{iNeuron}.class(2) == iEvent
                    secondary_class = secondary_class + 1;
                    if dirSelNeurons(iNeuron)
                        secondary_dir = secondary_dir + 1;
                    end
                end
            end
        end
    end
    bardata_class(iEvent,1) = primary_class;
    bardata_class(iEvent,2) = secondary_class;
    bardata_class(iEvent,3) = primary_class + secondary_class;
    bardata_dir(iEvent,1) = primary_dir;
    bardata_dir(iEvent,2) = secondary_dir;
    bardata_dir(iEvent,3) = primary_dir + secondary_dir;
end

figuree(1100,400);
bar(bardata_class);
hold on;
bar(bardata_dir,'k');
legend({'primary','secondary','together','dirSel'});
ylabel('units');
title('Unit Classes & Directional Selectivity Breakdown');
ylim([0 200]);
xticklabels(eventFieldlabels);