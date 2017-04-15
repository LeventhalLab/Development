colors = jet(7);
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
    
    if sessionFR < 1
        dotColor = colors(1,:);
    elseif sessionFR < 2
        dotColor = colors(2,:);
    elseif sessionFR < 5
        dotColor = colors(3,:);
    elseif sessionFR < 10
        dotColor = colors(4,:);
    elseif sessionFR < 20
        dotColor = colors(5,:);
    elseif sessionFR < 40
        dotColor = colors(6,:);
    else
        dotColor = colors(7,:);
    end
    
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,dotColor);
end

figure('position',[0 0 1400 600]);
subplot(131);
imshow(atlas_ims{1});
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

legend(ax,{'<1 s/s','<2 s/s','<5 s/s','<10 s/s','<20 s/s','<40 s/s','>40 s/s'});
tightfig;