% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
colors = lines(7);
dotSize_mm = .03;
atlas_ims = [];
useEvents = [3:4];
nasPath = '/Users/mattgaidica/Documents/Data/ChoiceTask';

for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows)',:);
    
    wiggle = (rand(1) - 0.5) * 0.2;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.2;
    ML = channelData{1,'ml'}; % no wiggle, this controls the image/slice
    wiggle = (rand(1) - 0.5) * 0.2;
    DV = channelData{1,'dv'} + wiggle;
    
    if ~isempty(unitEvents{iNeuron}.class)
        neuronClass = unitEvents{iNeuron}.class(1);
        dotColor = colors(neuronClass,:);
    else
        continue;
    end
    
    % override
    dotColor = colors(dirSelNeurons(iNeuron) + 1,:);

    if isempty(channelData) || ~ismember(neuronClass,useEvents) || sum(isnan([AP ML DV]))
        iNeuron
        continue;
    end
    
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,dotColor,dotSize_mm);
end

figure('position',[0 0 1400 600]);
set(gcf,'color','w');
subplot(131);
imshow(atlas_ims{1});
title('Event Class');
subplot(132);
imshow(atlas_ims{2});
subplot(133);
imshow(atlas_ims{3});
hold on;

ax = [];
xlims = xlim;
ylims = ylim;
for ii = 1:numel(useEvents)
    ax(ii) = plot(xlims(1),ylims(1),'.','markerSize',20,'color',colors(useEvents(ii),:));
    hold on;
end
legend(ax,eventFieldnames(useEvents));
drawnow;
delete(ax);