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
selectIds = find(modFiringArea ~= 0);
modFiringArea_select = modFiringArea(selectIds);
all_AP_select = all_AP(selectIds);
all_ML_select = all_ML(selectIds);
all_DV_select = all_DV(selectIds);

figure('position',[0 0 900 400]);
markerSize = 30;
atlas_ims = [];
select_mthalIds = [3:5 7 9 11:16 71:86 88 89 91:94 97 99:108];
allIds = [1:numel(modFiringArea_select)];
select_nonmthalIds = allIds(~ismember(allIds,select_mthalIds));

all_mthalPeths = [];
all_nonmthalPeths = [];

for iNeuron = 1:numel(modFiringArea_select)
    wiggle = (rand(1) - 0.5) * 0.2;
    this_AP = all_AP_select(iNeuron) + wiggle;
    wiggle = (rand(1) - 0.5) * 0.2;
    this_ML = all_ML_select(iNeuron) + wiggle;
    wiggle = (rand(1) - 0.5) * 0.2;
    this_DV = all_DV_select(iNeuron) + wiggle;
    this_modFiringArea = modFiringArea_select(iNeuron);
    
    subplot(131);
    hold on;
    
    plot(this_AP,this_modFiringArea,'.','markerSize',markerSize,'color',colors(round(this_modFiringArea),:));
    title('AP');
    xlabel('mm');
    ylabel('z width ticks (20/s)');
    grid on;
    
    subplot(132);
    hold on;
    plot(this_DV,this_modFiringArea,'.','markerSize',markerSize,'color',colors(round(this_modFiringArea),:));
    title('ML');
    xlabel('mm');
    ylabel('z width ticks (20/s)');
    grid on;
    
    subplot(133);
    hold on;
    plot(this_DV,this_modFiringArea,'.','markerSize',markerSize,'color',colors(round(this_modFiringArea),:));
    title('DV');
    xlabel('mm');
    ylabel('z width ticks (20/s)');
    grid on;
    
    colors = jet(round(max(modFiringArea_select)));
%     [atlas_ims,k] = plotMthalElectrode(atlas_ims,this_AP,this_ML,this_DV,nasPath,...
%         colors(round(this_modFiringArea),:));
    
    if ismember(iNeuron,select_mthalIds)
        useColor = [1 0 0];
        all_mthalPeths = [all_mthalPeths squeeze(neuronPeth(selectIds(iNeuron),4,:))];
    else
        useColor = [0 0 1];
        all_nonmthalPeths = [all_nonmthalPeths squeeze(neuronPeth(selectIds(iNeuron),4,:))];
    end
    
    if this_modFiringArea < (.2 * 20)
        useColor = [1 0 0];
    else
        useColor = [0 0 1];
    end
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,this_AP,this_ML,this_DV,nasPath,useColor);
%     [atlas_ims,k] = plotMthalElectrodeLabels(atlas_ims,this_AP,this_ML,this_DV,nasPath,num2str(iNeuron));
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
[counts,centers] = hist(modFiringArea_select,modFiringBins);
bar(centers,counts,'k');
ylabel('unit count');
xlim([min(modFiringBins) - 2 max(modFiringBins)] + 1);
xtickVals = modFiringBins / 20;
xticks(modFiringBins);
xticklabels(num2str(modFiringBins(:)/20));
xlabel('t_m_o_d (s)');

figure;
[counts_mthal,centers_mthal] = hist(modFiringArea_select(select_mthalIds),modFiringBins);
[counts_nonmthal,centers_nonmthal] = hist(modFiringArea_select(select_nonmthalIds),modFiringBins);
ylim_max = max([counts_mthal counts_nonmthal]);
subplot(211);
bar(centers_mthal,counts_mthal,'k');
ylabel('unit count');
ylim([0 ylim_max+2]);
xlim([min(modFiringBins) - 2 max(modFiringBins)] + 1);
xtickVals = modFiringBins / 20;
xticks(modFiringBins);
xticklabels(num2str(modFiringBins(:)/20));
xlabel('t_m_o_d (s)');
title('VM Units');
grid on;

subplot(212);
bar(centers_nonmthal,counts_nonmthal,'k');
ylabel('unit count');
ylim([0 ylim_max+2]);
xlim([min(modFiringBins) - 2 max(modFiringBins)] + 1);
xtickVals = modFiringBins / 20;
xticks(modFiringBins);
xticklabels(num2str(modFiringBins(:)/20));
xlabel('t_m_o_d (s)');
title('Not VM Units');
grid on;

figure('position',[0 0 400 900]);
subplot(211);
nSmooth = 3;
grayColor = [.7 .7 .7 .7];
for ii = 1:size(all_mthalPeths,2)
    plot(smooth(all_mthalPeths(:,ii),nSmooth),'color',grayColor);
    hold on;
end
plot(smooth(mean(all_mthalPeths,2),nSmooth),'color','red','lineWidth',1.5);
xlim([1 40]);
ylim([-1 2]);
title('VM Units');
grid on;

subplot(212);
for ii = 1:size(all_mthalPeths,2)
    plot(smooth(all_mthalPeths(:,ii),nSmooth),'color',grayColor);
    hold on;
end
plot(smooth(mean(all_nonmthalPeths,2),nSmooth),'color','red','lineWidth',1.5);
xlim([1 40]);
ylim([-1 2]);
title('Not VM Units');
grid on;