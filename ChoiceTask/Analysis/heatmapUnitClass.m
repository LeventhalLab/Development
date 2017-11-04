% % unitEvents = corr_unitEvents;
% % all_zscores = corr_all_zscores;
plotSpecialArrows = false;
doSetup = false;
if doSetup
    tWindow = 1;
    binMs = 20;
    trialTypes = {'correct'};
    useEvents = 1:7;
    useTiming = {};
    [unitEvents,all_zscores,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
    minZ = 1;
    [primSec,fractions] = primSecClass(unitEvents,minZ);
end
doLegend = true;
imsc = [];
useSubjects = [88,117,137,142,154,182];
% useSubjects = [182];

% compile event classes
neuronClasses = {};
for iEvent = 1:numel(eventFieldnames)
    neuronClasses{iEvent} = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if isnan(primSec(iNeuron,1)) || ~ismember(sessionConf.subjects__id,useSubjects)
            disp(['Skipping neuron ',num2str(iNeuron)]);
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

caxisVals = [-0.5 2];
h = figuree(1200,400);
for iEvent = 1:numel(eventFieldnames)
    subplot(1,numel(eventFieldnames),iEvent);
    imagesc(squeeze(all_zscores(sorted_neuronIds,iEvent,:)));
    hold on;
    plot([round(size(all_zscores,3)/2) round(size(all_zscores,3)/2)],[1 numel(analysisConf.neurons)],'k--'); % t=0
%     imagesc(squeeze(all_zscores(:,iEvent,:))); % in session order
    caxis(caxisVals);
    xlim([1 size(all_zscores,3)]);
    xticks([1 round(size(all_zscores,3)/2) size(all_zscores,3)]);
    xticklabels({'-1','0','1'});
    yticks([1 numel(analysisConf.neurons)]);
    colormap jet;
    title([eventFieldlabels{iEvent}],'interpreter','none');
%     markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
%     plot(ones(numel(markerRange),1),markerRange,'k.','MarkerSize',20);
    if iEvent ~= 1
        yticklabels({'',''});
    else
        ylabel('Units');
    end
    if iEvent == 4
        xlabel('Time (s)');
    end

    set(gca,'fontSize',16);
end
for iNeuron = 1:numel(sorted_neuronIds)
    if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class)
        subplot(1,numel(eventFieldnames),unitEvents{sorted_neuronIds(iNeuron)}.class(1));
        plot(3,iNeuron,'>','MarkerFaceColor','k','MarkerEdgeColor','none','markerSize',5); % class 1
        if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class(2))
            subplot(1,numel(eventFieldnames),unitEvents{sorted_neuronIds(iNeuron)}.class(2));
            plot(size(all_zscores,3)-1,iNeuron,'<','MarkerFaceColor',repmat(1,1,3),'MarkerEdgeColor','none','markerSize',5); % class 1
        end
    end
end
if plotSpecialArrows
    for iEvent = 1:7
        % special unit
        subplot(1,numel(eventFieldnames),iEvent);
        plot(4,find(sorted_neuronIds == 188),'>','MarkerFaceColor','g','MarkerEdgeColor','w','markerSize',10);
        plot(4,find(sorted_neuronIds == 113),'>','MarkerFaceColor','r','MarkerEdgeColor','w','markerSize',10);
    end
end
% special unit
% % subplot(1,numel(eventFieldnames),4);
% % plot(4,find(sorted_neuronIds == 188),'>','MarkerFaceColor','g','MarkerEdgeColor','none','markerSize',10);
% % plot(4,find(sorted_neuronIds == 113),'>','MarkerFaceColor','r','MarkerEdgeColor','none','markerSize',10);

set(gcf,'color','w');
tightfig;

if doLegend
    figuree(300,400);
    set(gca,'Visible','Off')
    xticks([]);
    cb = colorbar('location','south');
    colormap(jet);
    caxis(caxisVals);
    title(cb,'Z score');
    set(cb,'XTick',[caxisVals(1),0,caxisVals(2)]);
    set(gcf,'color','w');
    set(gca,'fontSize',16);
end


    

% % if false
% %     % incorrect 
% %     figuree(1200,800);
% %     for iEvent = 1:numel(eventFieldnames)
% %         subplot(1,numel(eventFieldnames),iEvent);
% %         imagesc(squeeze(incorr_all_zscores(sorted_neuronIds,iEvent,:)));
% %         caxis([-3 8]);
% %         xlim([1 40]);
% %         xticks([1 20 40]);
% %         xticklabels({'-1','0','1'});
% %         yticks([1 numel(analysisConf.neurons)]);
% %         colormap jet;
% %         title(['incorr_',eventFieldnames{iEvent}],'interpreter','none');
% %         hold on;
% %         plot([20 20],[1 numel(analysisConf.neurons)],'k--');
% %         markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
% %         plot(ones(numel(markerRange),1),markerRange,'k.','MarkerSize',20);
% %     %     markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
% %     %     plot(ones(numel(markerRange),1),markerRange,'r.','MarkerSize',10);
% %     end
% % 
% %     % correct - incorrect 
% %     figuree(1200,800);
% %     for iEvent = 1:numel(eventFieldnames)
% %         subplot(1,numel(eventFieldnames),iEvent);
% %         imagesc(squeeze(all_zscores(sorted_neuronIds,iEvent,:)) - squeeze(incorr_all_zscores(sorted_neuronIds,iEvent,:)));
% %         caxis([-3 8]);
% %         xlim([1 40]);
% %         xticks([1 20 40]);
% %         xticklabels({'-1','0','1'});
% %         yticks([1 numel(analysisConf.neurons)]);
% %         colormap jet;
% %         title(['diff_',eventFieldnames{iEvent}],'interpreter','none');
% %         hold on;
% %         plot([20 20],[1 numel(analysisConf.neurons)],'k--');
% %         markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
% %         plot(ones(numel(markerRange),1),markerRange,'k.','MarkerSize',20);
% %     %     markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
% %     %     plot(ones(numel(markerRange),1),markerRange,'r.','MarkerSize',10);
% %     end
% % end