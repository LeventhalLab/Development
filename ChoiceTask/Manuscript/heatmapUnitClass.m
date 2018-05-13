figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';
% % unitEvents = corr_unitEvents;
% % all_zscores = corr_all_zscores;
specialUnit = 133;
doLegend = false;
doLabels = false;
doSave = false;
doPrimSecArrows = true;
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

runMap = 5;
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
    case 4 % all NAN
        useUnits = isnan(primSec(:,1));
        plotSpecialArrows = false;
        doPrimSecArrows = false;
    case 5
        useUnits = ones(size(primSec,1),1);
        plotSpecialArrows = false;
        doPrimSecArrows = false;
        doSave = false; % using case 5 to get sorted_neuronIds
end

imsc = [];
% % useSubjects = [88,117,142,154,182];

% compile event classes
neuronClasses = {};
for iEvent = 1:numel(eventFieldnames)
    neuronClasses{iEvent} = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if ~useUnits(iNeuron) || ismember(iNeuron,removeUnits)
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

h = figuree(1200,numel(sorted_neuronIds)/.75);
hs = [];
for iEvent = 1:numel(eventFieldnames)
    hs(iEvent) = subplot_tight(1,numel(eventFieldnames),iEvent,subplotMargins);
    imagesc(squeeze(all_zscores(sorted_neuronIds,iEvent,:)));
    hold on;
% % % %     plot([round(size(all_zscores,3)/2) round(size(all_zscores,3)/2)],[1 numel(analysisConf.neurons)],'k--'); % t=0
%     imagesc(squeeze(all_zscores(:,iEvent,:))); % in session order
    caxis(caxisVals);
    xlim([1 size(all_zscores,3)]);
    yticks([]);
    if doSave
        ylim([1 numel(sorted_neuronIds)-2]); % otherwise smears last unit
    end
    if doLabels
        xticks([1 round(size(all_zscores,3)/2) size(all_zscores,3)]);
        xticklabels({'-1','0','1'});
        if iEvent == 1
            ylabel('Units');
        end
        if iEvent == 4
            if doTitle
                xlabel('Time (s)');
            end
        end
    else
        xticks(round(size(all_zscores,3)/2));
        xticklabels([]);
    end
    colormap jet;
    grid on;
    set(gca,'fontSize',14);
end
if doPrimSecArrows
    markerSize = 4;
    for iNeuron = 1:numel(sorted_neuronIds)
        % should probably use primSec here?
        if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class)
            subplot(hs(unitEvents{sorted_neuronIds(iNeuron)}.class(1)));
            plot(markerSize-1,iNeuron,'>','MarkerFaceColor','k','MarkerEdgeColor','none','markerSize',markerSize); % class 1
            if ~isempty(unitEvents{sorted_neuronIds(iNeuron)}.class(2))
                subplot(hs(unitEvents{sorted_neuronIds(iNeuron)}.class(2)));
                plot(size(all_zscores,3)-1,iNeuron,'<','MarkerFaceColor',repmat(1,1,3),'MarkerEdgeColor','none','markerSize',markerSize); % class 1
            end
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
    print(gcf,'-painters','-depsc',fullfile(figPath,['heatmapUnitClass_',num2str(runMap),'.eps']));
    close(h);
end

if doLegend
    h = figuree(300,400);
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
    if doSave
        print(gcf,'-painters','-depsc',fullfile(figPath,'heatmapUnitClass_legend.eps'));
        close(h);
    end
end