colors = jet(11);
atlas_ims = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(rows,:);
    event_id = eventIds_by_maxHistValues(iNeuron);
    if isempty(channelData)
        continue;
    end
    wiggle = (rand(1) - 0.5) * 0.2;
    AP = channelData{1,'ap'} + wiggle;
    ML = channelData{1,'ml'} + wiggle;
    DV = channelData{1,'dv'} + wiggle;
    
    ts = all_ts{iNeuron};
    sessionFR = 1 / mean(diff(ts));
    sessionCV = std(diff(ts)) / mean(diff(ts));
    
    if sessionCV < 0.5
        dotColor = colors(1,:);
    elseif sessionCV < 0.75
        dotColor = colors(2,:);
    elseif sessionCV < 1
        dotColor = colors(3,:);
    elseif sessionCV < 1.25
        dotColor = colors(4,:);
    elseif sessionCV < 1.5
        dotColor = colors(5,:);
    elseif sessionCV < 1.75
        dotColor = colors(6,:);
    elseif sessionCV < 2
        dotColor = colors(7,:);
    elseif sessionCV < 2.5
        dotColor = colors(8,:);
    elseif sessionCV < 3
        dotColor = colors(9,:);
    elseif sessionCV < 5
        dotColor = colors(10,:);
    else
        dotColor = colors(11,:);
    end
    
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,dotColor);
end

figure('position',[0 0 1400 600]);
subplot(131);
imshow(atlas_ims{1});
title('CV');
subplot(132);
imshow(atlas_ims{2});
subplot(133);
imshow(atlas_ims{3});
hold on;
ax = [];
xlims = xlim;
ylims = ylim;
for ii = 1:size(colors,1)
    ax(ii) = plot(xlims(1),ylims(1),'.','markerSize',20,'color',colors(ii,:));
    hold on;
end

legend(ax,{'<0.50','<0.75','<1.00','<1.25','<1.50','<1.75','<2.00','<2.50','<3','<5','>5'});
tightfig;