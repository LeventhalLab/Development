% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
colors = jet(7);
atlas_ims = [];
useEvents = [1:7];
figure('position',[0 0 800 800]);
all_AP = [];
all_ML = [];
all_DV = [];
all_colors = [];
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows)',:);
    event_id = eventIds_by_maxHistValues(iNeuron);
    if ~ismember(event_id,useEvents)
        continue;
    end
    if isempty(channelData)
        continue;
    end
    wiggle = (rand(1) - 0.5) * 0.1;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    ML = channelData{1,'ml'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    DV = channelData{1,'dv'} + wiggle;
    all_AP = [all_AP;AP];
    all_ML = [all_ML;ML];
    all_DV = [all_DV;DV];
    
    if ismember(iNeuron,neuronIds(curatedIds))
        all_colors = [all_colors;colors(7,:)];
    else
        all_colors = [all_colors;colors(event_id,:)];
    end
end
% ax = bubbleplot3(all_ML,all_AP,all_DV,ones(1,numel(all_DV))*.04,all_colors,0.7);
% camlight right; lighting phong;
scatter3sph(all_ML,all_AP,all_DV,'size',.1,'color',all_colors,'transp',0.5);
set(gcf,'color','w');
light('Position',[1 1 1],'Style','local','Color',[1 1 1]);
lighting gouraud;
view(102,17);
grid on;
% legend(ax,eventFieldnames);
xlabel('ML');
ylabel('AP');
zlabel('DV');
set(gca,'zdir','reverse');
set(gca,'xdir','reverse');
set(gca,'ydir','reverse');

hold on;
xlims = xlim;
ylims = ylim;
ax = [];
for ii = 1:numel(useEvents)
    ax(ii) = plot(xlims(1),ylims(1),'.','markerSize',30,'color',colors(useEvents(ii),:));
end

legend(ax,eventFieldnames(useEvents));
drawnow;
delete(ax);