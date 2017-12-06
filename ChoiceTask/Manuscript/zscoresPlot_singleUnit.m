doTitle = false;
% use primary + secondary classes
tWindow = 1;
binMs = 20;
binS = binMs / 1000;
trialTypes = {'correct'};
useEvents = 1:7;
useTiming = {};

session15_rt = all_rt_c{15};
session15_mt = all_mt_c{15};

% run together
% % [unitEvents,all_zscores,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
% % primSec = primSecClass(unitEvents,1);

rows = 2;
cols = 7;
nSmooth = 3;
colors = zeros(2,3);
lineWidth = 3;
set_ylims = [-1 3];
ylabelloc = 2.5;
useNeuron = 188% (R142_1209_7b), 103, 147, 201 (R142_1210_36a)
useNeuron = 133

figuree(1200,350);
lns = [];
for iEvent = 1:numel(eventFieldnames)
% %     plot(squeeze(all_zscores(useNeurons,iEvent,:))','LineWidth',0.5,'Color',repmat(.1,1,4));
% %     hold on;

    if rows > 1
        subplot(rows,cols,iEvent);

        curTrials = all_trials{useNeuron};
        trialIdInfo = organizeTrialsById(curTrials);
        tsPeths = eventsPeth(curTrials(trialIdInfo.incorrect),all_ts{useNeuron},tWindow,eventFieldnames);
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
            if doTitle
                title({['unit ',num2str(useNeuron)],[eventFieldnames{iEvent}]});
            end
        else
            yticklabels({'',''});
            if doTitle
                title({'',[eventFieldlabels{iEvent}]});
            end
        end
        xticks([0]);
        xticklabels({''});
        grid on;
    end
    
    if rows > 1
        subplot(rows,cols,iEvent+cols);
    else
        subplot(rows,cols,iEvent);
    end
    
    if iEvent == 3
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
        hold on;
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
        medRT = median(session15_rt);
        medRT_x = (size(all_zscores,3) / 2) + (medRT / binS);
        plot([medRT_x medRT_x],[-5 5],'k--');
        tx = text(medRT_x,ylabelloc,'RT','fontSize',16,'HorizontalAlignment','center','VerticalAlignment','top');
        set(tx,'Rotation',90);
    elseif iEvent == 4
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
        hold on;
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
        medMT = median(session15_mt);
        medMT_x = (size(all_zscores,3) / 2) + (medMT / binS);
        plot([medMT_x medMT_x],[-5 5],'k--');
        tx = text(medMT_x,ylabelloc,'MT','fontSize',16,'HorizontalAlignment','center','VerticalAlignment','top');
        set(tx,'Rotation',90);
    else
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color','k');
    end
  
    xlim([1 size(all_zscores,3)]);
    xticks([1 size(all_zscores,3)/2 size(all_zscores,3)]);
    xticklabels({'-1','0','1'});
    ylim(set_ylims);
    
    if doTitle
        title({'',[eventFieldlabels{iEvent}]});
    end
    if iEvent == 1
        ylabel('Z score');
        yticks([set_ylims(1) 0 set_ylims(2)]);
    else
        yticks([set_ylims(1) 0 set_ylims(2)]);
        yticklabels({'','',''});
    end
    if iEvent == 4
        xlabel('Time (s)');
    end
    set(gca,'fontSize',16);
    grid on;
end
set(gcf,'color','white');

tightfig;