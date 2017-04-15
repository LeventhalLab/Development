colors = jet(125);
atlas_ims = [];

all_trialCV = [];
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
    tsPeths = all_tsPeths{iNeuron};
    tsPethTrials = tsPeths(:,event_id);
    sessionFR = 1 / mean(diff(ts));
    sessionCV = std(diff(ts)) / mean(diff(ts));
    allTrialCV = [];
    for iTrial = 1:size(tsPethTrials)
        curPeth = tsPethTrials{iTrial};
        if numel(curPeth) > 2
            curCV = std(diff(curPeth)) / mean(diff(curPeth));
            allTrialCV = [allTrialCV curCV];
        end
    end
    trialCV = nanmean(allTrialCV)/sessionCV;
    if ~isnan(trialCV)
        dotColor = colors(round(trialCV*100),:); % scale: 0-1.25
        all_trialCV = [all_trialCV trialCV];
        [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,dotColor);
    end
end

figure('position',[0 0 1400 600]);
subplot(131);
imshow(atlas_ims{1});
title('CV - by trial/class');
subplot(132);
imshow(atlas_ims{2});
subplot(133);
imshow(atlas_ims{3});
hold on;
ax = [];
xlims = xlim;
ylims = ylim;
for ii = 1:size(colors,1)
    ax(ii) = plot(xlims(1),ylims(1),'.','markerSize',20,'color',[colors(ii,:) 0]);
    hold on;
end

colorbar;
caxis([0 1.25]);
colormap(jet);
% tightfig;