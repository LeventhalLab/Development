eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
useEvents = [3,4];
firingTypes = {'Modulated','Sustained','None'};
if false
    all_AP = [];
    all_ML = [];
    all_DV = [];
    
    all_eventIds = [];
    neuronFiringType = [];

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
        ylim([-1 3]);
        grid on;
%         answer = inputdlg('modualtion class:');
%         neuronFiringType(iNeuron) = str2num(answer{1});
        button = questdlg('Select type...','corr tool',firingTypes{1},firingTypes{2},firingTypes{3},firingTypes{3});
        if strcmp(button,firingTypes{1})
            neuronFiringType(iNeuron) = 1;
        elseif strcmp(button,firingTypes{2})
            neuronFiringType(iNeuron) = 2;
        elseif strcmp(button,firingTypes{3})
            neuronFiringType(iNeuron) = 0;
        else
            neuronFiringType(iNeuron) = 4;
        end
        close(h1);
    end
end

colors = jet(7);
h1 = figure('position',[0 0 500 500]);
h2 = figure('position',[100 100 900 400]);
zLim = [-1 3];
atlas_ims = [];
for iNeuron = 1:size(all_tsPeths,2)
    switch neuronFiringType(iNeuron)
        case 0
            continue;
        case 1
            markerColor = colors(1,:);
        case 2
            markerColor = colors(3,:);
        case 3
            markerColor = colors(5,:);
        case 4
            markerColor = colors(7,:);
    end
    figure(h2);
    curPeth = squeeze(neuronPeth(iNeuron,event_id,:));
    subplot(1,3,neuronFiringType(iNeuron));
    plot(curPeth);
    ylim(zLim);
    title(firingTypes{neuronFiringType(iNeuron)});
    hold on;
    
    wiggle1 = (rand(1) - 0.5) * 0.1;
    wiggle2 = (rand(1) - 0.5) * 0.1;
    wiggle3 = (rand(1) - 0.5) * 0.1;
    figure(h1);
    lgd(neuronFiringType(iNeuron)) = scatter3(all_ML(iNeuron)+wiggle1,all_AP(iNeuron)+wiggle2,all_DV(iNeuron)+wiggle3,40,markerColor,'filled');
    hold on;
    
    [atlas_ims,k] = plotMthalElectrode(atlas_ims,all_AP(iNeuron)+wiggle1,all_ML(iNeuron)+wiggle2,all_DV(iNeuron)+wiggle3,nasPath,markerColor);
end
view(102,17);
grid on;
% legend(ax,eventFieldnames);
xlabel('ML');
ylabel('AP');
zlabel('DV');
set(gca,'zdir','reverse');
set(gca,'xdir','reverse');
set(gca,'ydir','reverse');
% legend(lgd,firingTypes);

figure('position',[0 0 1400 600]);
set(gcf,'color','w');
subplot(131);
imshow(atlas_ims{1});
title('Firing Type Class');
subplot(132);
imshow(atlas_ims{2});
subplot(133);
imshow(atlas_ims{3});
hold on;
