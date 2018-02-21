eventDVs = {};
eventAPs = {};
for ii = 1:2
    eventDVs{ii} = [];
    eventAPs{ii} = [];
end

% % figure;
for iNeuron = 1:numel(unitEvents)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows)',:);
    
    wiggle = (rand(1) - 0.5) * 0.1;
    ML = channelData{1,'ml'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    DV = channelData{1,'dv'} * -1 + wiggle;
    
    if dirSelNeurons(iNeuron)
        eventDVs{1} = [eventDVs{1} DV];
        eventAPs{1} = [eventAPs{1} AP];
    else
        eventDVs{2} = [eventDVs{2} DV];
        eventAPs{2} = [eventAPs{2} AP];
    end
    
% %     if ~isempty(unitEvents{iNeuron}.class) && unitEvents{iNeuron}.class(1) == 3 % centerOut
% %         plot3(AP,ML,DV,'r.','MarkerSize',15);
% %         hold on;
% %     end
% %     
% %     if ~isempty(unitEvents{iNeuron}.class) && unitEvents{iNeuron}.class(1) == 4 % centerOut
% %         plot3(AP,ML,DV,'k.','MarkerSize',15);
% %         hold on;
% %     end
end
% % xlabel('AP'); 
% % ylabel('ML');
% % zlabel('DV');

figuree(500,400);
subplot(211);
plotSpread(eventAPs);
xticklabels({'DirSel','NOT DirSel'});
grid on;
title('AP Coordinate');
subplot(212);
plotSpread(eventDVs);
xticklabels({'DirSel','NOT DirSel'});
grid on;
title('DV Coordinate');
