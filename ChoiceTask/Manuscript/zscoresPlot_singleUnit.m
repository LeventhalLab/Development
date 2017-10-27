% use primary + secondary classes
tWindow = 1;
binMs = 20;
binS = binMs / 1000;
trialTypes = {'correctContra','correctIpsi'};
useEvents = 1:7;
useTiming = {};

% run together
% % [unitEvents,all_zscores,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
% % primSec = primSecClass(unitEvents,0.5);

rows = 2;
cols = 7;
nSmooth = 3;
colors = zeros(2,3);
lineWidth = 3;
set_ylims = [-1 2];
ylabelloc = 1.3;
useNeuron = 201; % 188 (R142_1209_7b), 103, 147, 201 (R142_1210_36a)

figuree(1200,600);
lns = [];
for iEvent = 1:numel(eventFieldnames)
% %     plot(squeeze(all_zscores(useNeurons,iEvent,:))','LineWidth',0.5,'Color',repmat(.1,1,4));
% %     hold on;

    subplot(rows,cols,iEvent);
    rasterData = tsPeths(:,useEvents(iEvent));
    for iTrial = 1:numel(rasterData)
        if isempty(rasterData{iTrial})
            rasterData{iTrial} = NaN;
        end
    end
    plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
    yticks(ylim);
    set(gca,'fontSize',16);
    if iEvent == 1
        ylabel('Trials');
        title({['unit ',num2str(useNeuron)],[eventFieldnames{iEvent}]});
    else
        title({'',[eventFieldnames{iEvent}]});
    end

    subplot(rows,cols,iEvent+cols);
    if iEvent == 3
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
        hold on;
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
        medRT = median(all_rt);
        medRT_x = (size(all_zscores,3) / 2) + (medRT / binS);
        plot([medRT_x medRT_x],[-5 5],'k--');
        tx = text(medRT_x,ylabelloc,'median RT','fontSize',16,'HorizontalAlignment','center','VerticalAlignment','top');
        set(tx,'Rotation',90);
    elseif iEvent == 4
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
        hold on;
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
        medMT = median(all_mt);
        medMT_x = (size(all_zscores,3) / 2) + (medMT / binS);
        plot([medMT_x medMT_x],[-5 5],'k--');
        tx = text(medMT_x,ylabelloc,'median MT','fontSize',16,'HorizontalAlignment','center','VerticalAlignment','top');
        set(tx,'Rotation',90);
    else
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color','k');
    end
  
    xlim([1 size(all_zscores,3)]);
    xticks([1 size(all_zscores,3)/2 size(all_zscores,3)]);
    xticklabels({'-1','0','1'});
    ylim(set_ylims);
    yticks([set_ylims(1) 0 set_ylims(2)]);
    
    if iEvent == 1
        ylabel('Z score');
    end
    if iEvent == 4
        xlabel('Time (s)');
    end
    set(gca,'fontSize',16);
    grid on;
end
set(gcf,'color','white');

tightfig;