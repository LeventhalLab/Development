% % unitEvents = corr_unitEvents;
% % all_zscores = corr_all_zscores;
specialUnit = 133;
doLegend = true;
doLabels = true;
doSave = false;

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
end

runMap = 3;
switch runMap
    case 1 % dirSel
        use_dirSelNeurons = dirSelNeuronsNO;
        useUnits = (ismember(primSec(:,1),[3,4]) == 1) & use_dirSelNeurons;
        plotSpecialArrows = false;
        noteText = 'dirSel units';
    case 2 % ~dirSel
        use_dirSelNeurons = ~dirSelNeurons;
        useUnits = (ismember(primSec(:,1),[3,4]) == 1) & use_dirSelNeurons;
        plotSpecialArrows = false;
        noteText = '~dirSel units';
    case 3 % all non-NAN
        useUnits = ~isnan(primSec(:,1));
        plotSpecialArrows = true;
end

imsc = [];
% % useSubjects = [88,117,142,154,182];

% compile event classes
neuronClasses = {};
for iEvent = 1:numel(eventFieldnames)
    neuronClasses{iEvent} = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if ~useUnits(iNeuron)
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
hs = [];
for iEvent = 1:numel(eventFieldnames)
    hs(iEvent) = subplot_tight(1,numel(eventFieldnames),iEvent,subplotMargins);
    imagesc(squeeze(all_zscores(sorted_neuronIds,iEvent,:)));
    hold on;
% % % %     plot([round(size(all_zscores,3)/2) round(size(all_zscores,3)/2)],[1 numel(analysisConf.neurons)],'k--'); % t=0
%     imagesc(squeeze(all_zscores(:,iEvent,:))); % in session order
    caxis(caxisVals);
    xlim([1 size(all_zscores,3)]);
    if doLabels
        xticks([1 round(size(all_zscores,3)/2) size(all_zscores,3)]);
        xticklabels({'-1','0','1'});
        if iEvent ~= 1
            yticklabels({'',''});
        else
            ylabel('Units');
        end
        if iEvent == 4
            if doTitle
                xlabel('Time (s)');
            end
        end
        yticks([1 numel(sorted_neuronIds)]);
    else
        xticks(round(size(all_zscores,3)/2));
        xticklabels([]);
        yticks([1 numel(sorted_neuronIds)]);
        yticklabels([]);
    end
    colormap jet;
    grid on;
    set(gca,'fontSize',14);
end
for iNeuron = 1:numel(sorted_neuronIds)
    if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class)
        subplot(hs(unitEvents{sorted_neuronIds(iNeuron)}.class(1)));
        plot(4,iNeuron,'>','MarkerFaceColor','k','MarkerEdgeColor','none','markerSize',5); % class 1
        if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class(2))
            subplot(hs(unitEvents{sorted_neuronIds(iNeuron)}.class(2)));
            plot(size(all_zscores,3)-1,iNeuron,'<','MarkerFaceColor',repmat(1,1,3),'MarkerEdgeColor','none','markerSize',5); % class 1
        end
    end
end
if plotSpecialArrows
    for iEvent = 1:7
        % special unit
        subplot(hs(iEvent));
        plot(7,find(sorted_neuronIds == specialUnit),'>','MarkerFaceColor','g','MarkerEdgeColor','none','markerSize',10);
%         plot(4,find(sorted_neuronIds == 113),'>','MarkerFaceColor','r','MarkerEdgeColor','w','markerSize',10);
    end
end

if ismember(runMap,[1,2])
    addNote(h,noteText);
end

tightfig;
setFig('','',[2,1]);
box on;

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'heatmapUnitClass.eps'));
end

if doLegend
    figuree(300,400);
    set(gca,'Visible','Off')
    xticks([]);
    cb = colorbar('location','south','Orientation','horizontal');
%     cb = colorbar('location','east','Orientation','vertical');
    colormap(jet);
    caxis(caxisVals);
    set(cb,'XTick',[caxisVals(1),0,caxisVals(2)]);
    if doLabels
        title(cb,'Z score');
    end
    setFig('','',1);
end

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'heatmapUnitClass_legend.eps'));
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