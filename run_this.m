beeswarm1 = [];
beeswarm2 = [];
beeCount = 1;
figure;
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
    
    if DV == 0
        neuronName
        continue;
    end
    
    if ~isempty(unitEvents{iNeuron}.class) && unitEvents{iNeuron}.class(1) == 3 % centerOut
        plot3(AP,ML,DV,'r.','MarkerSize',15);
        hold on;
        beeswarm1 = [beeswarm1 AP];
    end
    
    if ~isempty(unitEvents{iNeuron}.class) && unitEvents{iNeuron}.class(1) == 4 % centerOut
        plot3(AP,ML,DV,'k.','MarkerSize',15);
        hold on;
        beeswarm2 = [beeswarm2 AP];
    end
end
xlabel('AP'); 
ylabel('ML');
zlabel('DV');
% lims_ml = [.5 2.5]; yticks(lims_ml); yticklabels({'lateral','medial'}); ylim(lims_ml);
% lims_ap = [-4 1.5]; xticks(lims_ap); xticklabels({'posterior','anterior'}); xlim(lims_ap);
% lims_dv = [-8 -5.5]; zticks(lims_dv); zticklabels({'dorsal','ventral'}); zlim(lims_dv);

% figure;
% plotSpread({beeswarm1 beeswarm2});