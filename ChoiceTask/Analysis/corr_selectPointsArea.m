eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
useEvents = [3,4];
if false
    all_AP = [];
    all_ML = [];
    all_DV = [];
    
    all_eventIds = [];
    neuronFiringType = zeros(1,size(all_tsPeths,2));
    modFiringArea = zeros(1,size(all_tsPeths,2));

    for iNeuron = 1:size(all_tsPeths,2)
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
        AP = channelData{1,'ap'};
        all_AP(iNeuron) = AP;
        ML = channelData{1,'ml'};
        all_ML(iNeuron) = ML;
        DV = channelData{1,'dv'};
        all_DV(iNeuron) = DV;
        
        curPeth = squeeze(neuronPeth(iNeuron,event_id,:));
        h1 = figure('position',[0 0 500 500]);
        plot(curPeth);
        grid on;
        [xs,ys] = ginput(2);
        if diff(xs) > 1
            neuronFiringType = 1;
        end
        modFiringArea(iNeuron) = diff(xs);

% %         selArea = curPeth(round(xs(1)):round(xs(2)));
% %         selArea = normalize(selArea - min(selArea));
        
        close(h1);
        
%         modFiringArea(iNeuron) = max((curPeth));

    end
end

figure('position',[0 0 900 400]);
markerSize = 30;
atlas_ims = [];
for iNeuron = 1:size(all_tsPeths,2)
    if modFiringArea(iNeuron) == 0
        continue;
    end
    subplot(131);
    hold on;
    wiggle = (rand(1) - 0.5) * 0.1;
    plot(all_AP(iNeuron)+wiggle,modFiringArea(iNeuron),'k.','markerSize',markerSize);
    title('AP');
    xlabel('mm');
    ylabel('z width');
    grid on;
    
    subplot(132);
    hold on;
    wiggle = (rand(1) - 0.5) * 0.1;
    plot(all_ML(iNeuron)+wiggle,modFiringArea(iNeuron),'k.','markerSize',markerSize);
    title('ML');
    xlabel('mm');
    ylabel('z width');
    grid on;
    
    subplot(133);
    hold on;
    wiggle = (rand(1) - 0.5) * 0.1;
    plot(all_DV(iNeuron)+wiggle,modFiringArea(iNeuron),'k.','markerSize',markerSize);
    title('DV');
    xlabel('mm');
    ylabel('z width');
    grid on;
    
    colors = jet(round(max(modFiringArea)));
    wiggle1 = (rand(1) - 0.5) * 0.2;
    wiggle2 = (rand(1) - 0.5) * 0.2;
    wiggle3 = (rand(1) - 0.5) * 0.2;
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,all_AP(iNeuron)+wiggle1,all_ML(iNeuron)+wiggle2,all_DV(iNeuron)+wiggle3,nasPath,...
        colors(round(modFiringArea(iNeuron)),:));
end

figure('position',[0 0 1200 500]);
set(gcf,'color','w');
subplot(131);
imshow(atlas_ims{1});
title('Firing Type Class');
subplot(132);
imshow(atlas_ims{2});
subplot(133);
imshow(atlas_ims{3});
hcb = colorbar;
colormap(jet);
caxis([0 1]);
title(hcb,'t_m_o_d (s)');

modFiringBins = [0:2:20];
figure;
[counts,centers] = hist(modFiringArea(find(modFiringArea ~= 0)),modFiringBins);
bar(centers,counts,'k');
ylabel('units');
xlim([min(modFiringBins) - 2 max(modFiringBins)] + 1);
xtickVals = modFiringBins / 20;
xticks(modFiringBins);
xticklabels(num2str(modFiringBins(:)));
xlabel('t_m_o_d (s)');