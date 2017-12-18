subplotMargins = [.00,.02];
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';

doLabels = true;
doTitle = true;
doSave = false;
% use primary + secondary classes
tWindow = 1;
binMs = 20;
binS = binMs / 1000;
trialTypes = {'correct'};
useEvents = 1:7;
useTiming = {};

% run together
% % [unitEvents,all_zscores,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
% % primSec = primSecClass(unitEvents,1);

rows = 2;
cols = 7;
nSmooth = 3;
colors = zeros(2,3);
lineWidth = 3;
set_ylims = [-1 4];
ylabelloc = 2.5;
% useNeuron = 188% (R142_1209_7b), 103, 147, 201 (R142_1210_36a)
useNeuron = 133;
sessionNames = unique(analysisConf.sessionNames);
sessionId = find(strcmp(sessionNames,analysisConf.sessionNames{useNeuron}) == 1,1);
session_rt = all_rt_c{sessionId};
session_mt = all_mt_c{sessionId};

h = figuree(1200,300);
lns = [];
for iEvent = 1:numel(eventFieldnames)
% %     plot(squeeze(all_zscores(useNeurons,iEvent,:))','LineWidth',0.5,'Color',repmat(.1,1,4));
% %     hold on;

    if rows > 1
        subplot_tight(rows,cols,iEvent,subplotMargins);

        curTrials = all_trials{useNeuron};
        trialIdInfo = organizeTrialsById(curTrials);
        tsPeths = eventsPeth(curTrials(trialIdInfo.correct),all_ts{useNeuron},tWindow,eventFieldnames);
        rasterData = tsPeths(:,useEvents(iEvent));
        for iTrial = 1:numel(rasterData)
            if isempty(rasterData{iTrial})
                rasterData{iTrial} = NaN;
            end
        end
        plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        yticks(ylim);
        setFig;
        if doLabels
            title(eventFieldlabels{iEvent});
            if iEvent == 1
                ylabel('Trials');
            else
                yticklabels([]);
            end
        else
            yticklabels([]);
        end
        xticks([0]);
        xticklabels({''});
        grid on;
        if doTitle
            title([eventFieldlabels{iEvent}],'interpreter','none');
        end
    end
    
    if rows > 1
        subplot_tight(rows,cols,iEvent+cols,subplotMargins);
    else
        subplot_tight(rows,cols,iEvent,subplotMargins);
    end
    
    if iEvent == 3
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
        hold on;
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
        medRT = median(session_rt);
        medRT_x = (size(all_zscores,3) / 2) + (medRT / binS);
        plot([medRT_x medRT_x],[-5 5],'k--');
        tx = text(medRT_x,ylabelloc,'RT','fontSize',14,'HorizontalAlignment','center','VerticalAlignment','top');
        set(tx,'Rotation',90);
    elseif iEvent == 4
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
        hold on;
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
        medMT = median(session_mt);
        medMT_x = (size(all_zscores,3) / 2) + (medMT / binS);
        plot([medMT_x medMT_x],[-5 5],'k--');
        tx = text(medMT_x,ylabelloc,'MT','fontSize',14,'HorizontalAlignment','center','VerticalAlignment','top');
        set(tx,'Rotation',90);
    else
        lns(iEvent) = plot(smooth(squeeze(all_zscores(useNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidth,'Color','k');
    end
  
    xlim([1 size(all_zscores,3)]);
    if doLabels
        xticks([1 size(all_zscores,3)/2 size(all_zscores,3)]);
        xticklabels({'-1','0','1'});
        if iEvent == 1
            ylabel('Z score');
            yticks([set_ylims(1) 0 set_ylims(2)]);
        else
            yticks([set_ylims(1) 0 set_ylims(2)]);
            yticklabels([]);
        end
        if iEvent == 4
            xlabel('Time (s)');
        end
    else
        xticks(size(all_zscores,3)/2);
        xticklabels([]);
        yticks([set_ylims(1) 0 set_ylims(2)]);
        yticklabels([]);
    end
    ylim(set_ylims);

    setFig;
    grid on;
end

tightfig;
setFig('','',[2,1]);

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'zscoresPlot_singleUnit.eps'));
    close(h);
end
subplotMargins = [.05,.02];