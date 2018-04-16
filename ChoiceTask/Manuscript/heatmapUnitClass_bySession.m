% % unitEvents = corr_unitEvents;
% % all_zscores = corr_all_zscores;
doLabels = true;
doSave = false;
doPrimSecArrows = false;
caxisVals = [-0.5 2];

doSetup = false;
% use primSec_plot.m to set primSec (unit classes)
if doSetup
    tWindow = 1;
    binMs = 20;
    trialTypes = {'correct'};
    useEvents = 1:7;
    useTiming = {};
    [~,all_zscores,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
% %     minZ = 1;
% %     [primSec,fractions] = primSecClass(unitEvents,minZ);
% %     minZ = 0;
% %     [primSec_minZ0,~] = primSecClass(unitEvents,minZ);
end

% setup sessions and neurons
sessionCount = 0;
sessionName = '';
sessionNeurons = {};
for iNeuron = 1:numel(analysisConf.neurons)
    if isnan(primSec(iNeuron,1))
        disp(['Skipping NaN neuron ',num2str(iNeuron)]);
        continue;
    end
    sessionConf = analysisConf.sessionConfs{iNeuron};
    if strcmp(sessionName,sessionConf.sessions__name)
        sessionNeurons{sessionCount} = [sessionNeurons{sessionCount} iNeuron];
    else
        sessionName = sessionConf.sessions__name;
        sessionCount = sessionCount + 1;
        sessionNeurons{sessionCount} = [iNeuron];
    end
end

% % useUnits = ~isnan(primSec(:,1));
cols = 7;
rows = numel(sessionNeurons);
h = figuree(1200,700);
b = 1;
ls = []; % lefts
for iSession = 1:numel(sessionNeurons)
    useUnits = sessionNeurons{iSession};
    % compile event classes
    neuronClasses = {};
    for iEvent = 1:numel(eventFieldnames)
        neuronClasses{iEvent} = [];
        for iNeuron = 1:numel(analysisConf.neurons)
            sessionConf = analysisConf.sessionConfs{iNeuron};
            if ~ismember(iNeuron,useUnits)
                disp(['Skipping useUnit neuron ',num2str(iNeuron)]);
                continue;
            end
            if unitEvents{iNeuron}.class(1) == iEvent
                neuronClasses{iEvent} = [neuronClasses{iEvent} iNeuron];
            end
        end
    end

    % sort those event classes
    sorted_neuronClasses = {};
    for iEvent = 1:numel(eventFieldnames)
        curEvent_maxbins = [];
        cur_neuronClasses = neuronClasses{iEvent};
        for iNeuron = 1:numel(cur_neuronClasses)
            neuronId = cur_neuronClasses(iNeuron);
            curEvent_maxbins(iNeuron) = unitEvents{neuronId}.maxbin(iEvent);
        end
        [v,k] = sort(curEvent_maxbins);
        sorted_neuronClasses{iEvent} = cur_neuronClasses(k);
    end

    % remap neuronIds
    sorted_neuronIds = [];
    % % markerLocs = [0];
    for iEvent = 1:numel(eventFieldnames)
        sorted_neuronIds = [sorted_neuronIds sorted_neuronClasses{iEvent}];
    % %     markerLocs = [markerLocs numel(sorted_neuronIds)];
    end

    gcas = [];
    for iEvent = 1:cols
% %         h = .005 * numel(sorted_neuronIds);
% %         if iEvent == 1
% %             b = b - h - .01;
% %         end
% %         if iSession == 1
% %             gcas(iEvent) = subplot(rows,cols,prc(cols,[iSession,iEvent]));
% %             curPos = get(gca,'position');
% %             ls(iEvent) = curPos(1);
% %             w = curPos(3);
% %             delete(gcas(iEvent));
% %         end
        gcas(iEvent) = subplot(rows,cols,prc(cols,[iSession,iEvent]));
        imagesc(squeeze(all_zscores(sorted_neuronIds,iEvent,:)));
        hold on;
    % % % %     plot([round(size(all_zscores,3)/2) round(size(all_zscores,3)/2)],[1 numel(analysisConf.neurons)],'k--'); % t=0
    %     imagesc(squeeze(all_zscores(:,iEvent,:))); % in session order
        caxis(caxisVals);
        xlim([1 size(all_zscores,3)]);

        xticks([1 round(size(all_zscores,3)/2) size(all_zscores,3)]);
        xticklabels({});
% %         xticklabels({'-1','0','1'});
% %         if iEvent ~= 1
% %             yticklabels({'',''});
% %         else
% %             ylabel('Units');
% %         end
% %         if iEvent == 4
% %             if doTitle
% %                 xlabel('Time (s)');
% %             end
% %         end
% %         yticks([1 numel(sorted_neuronIds)]);
        yticklabels({});

        colormap jet;
        grid on;
        set(gca,'fontSize',14);
    end
    if doPrimSecArrows
        for iNeuron = 1:numel(sorted_neuronIds)
            if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class)
                subplot(gcas(unitEvents{sorted_neuronIds(iNeuron)}.class(1)));
                plot(4,iNeuron,'>','MarkerFaceColor','k','MarkerEdgeColor','none','markerSize',5); % class 1
                if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class(2))
                    subplot(gcas(unitEvents{sorted_neuronIds(iNeuron)}.class(2)));
                    plot(size(all_zscores,3)-1,iNeuron,'<','MarkerFaceColor',ones(1,3),'MarkerEdgeColor','none','markerSize',5); % class 1
                end
            end
        end
    end
    
    box off;
end

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,['heatmapUnitClassBySession_',num2str(runMap),'.eps']));
    close(h);
end