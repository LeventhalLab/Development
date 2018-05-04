figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';
onlyPrimary = false;
show_primFate = false; % false = show_secOrigin
plotOpt = 2; % 1 = both sides of x-axis, 2 = mosaic
showMosaic = false;
plotTitle = 'Unit Classes';
doLabels = true;
doSave = false;
fontSize = 8;

doSetup = false;
if doSetup
    tWindow = 0.2;
    binMs = 20;
    trialTypes = {'correct'};
    useEvent = 1:7;
    useTiming = {};

    [unitEvents,~,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvent,useTiming);
    
    minZ = 1;
    [primSec,fractions] = primSecClass(unitEvents,minZ);
end

primSec_wNC = primSec;
primSec_wNC(isnan(primSec_wNC)) = 8;
removeArr = ones(size(primSec,1),1);
removeArr(removeUnits) = 0;
removeArr = logical(removeArr);
primSec_wNC = primSec_wNC(removeArr,:);

h = figuree(600,500);
% cols = 7;
colors = parula(8);
% colors = colors(1:end,:);
colors(8,:) = [.7 .7 .7];

primBars = histcounts(primSec_wNC(:,1),0.5:8.5);
secBars = histcounts(primSec_wNC(:,2),0.5:8.5);

lns = [];
for iBar = 1:numel(secBars)
    if ~onlyPrimary
        lns(2) = bar(iBar,primBars(iBar) + secBars(iBar),'FaceColor',colors(iBar,:),'FaceAlpha',0.25,'EdgeColor','w','lineWidth',2);
        hold on;
    end
    lns(1) = bar(iBar,primBars(iBar),'FaceColor',colors(iBar,:),'EdgeColor','w','lineWidth',2);
    hold on;
end

if plotOpt == 1
    barMult = -1;
    barWidth = 0.8;
else
    barMult = 1;
    barWidth = 0.4;
end

primFate = [];
secOrigin = [];
for iEvent = 1:8
    primFate(iEvent,:) =  histcounts(primSec_wNC(primSec_wNC(:,1) == iEvent,2),0.5:8.5);
    secOrigin(iEvent,:) = [primBars(iEvent) histcounts(primSec_wNC(primSec_wNC(:,2) == iEvent,1),0.5:8.5)];
end

if showMosaic
    if show_primFate
        b = bar(primFate*barMult,'stacked','FaceColor','flat','EdgeColor','w','lineWidth',2,'BarWidth',barWidth);
        for k = 1:size(primFate,2)
            b(k).CData = colors(k,:);
        end
    else
        b = bar(secOrigin*barMult,'stacked','FaceColor','flat','EdgeColor','w','lineWidth',2,'BarWidth',barWidth);
        for iBar = 1:numel(secBars) % replot this
            bar(iBar,primBars(iBar),'FaceColor',colors(iBar,:),'EdgeColor','w','lineWidth',2);
        end
        for k = 1:size(primFate,2) % ignore bottom-most bar (where primaries are)
            b(k+1).CData = colors(k,:);
        end
    end
end
if onlyPrimary
    legend(lns,{'Primary Class'},'location','northwest');
    legend boxoff;
else
    legend(lns,{'Primary Class','Secondary Class'},'location','northwest');
    legend boxoff;
end

% formatting

xticks(1:8);
xticklabels({eventFieldlabels{:},'N.R.'});
ax = gca;
ax.XAxis.FontSize = 8;
xtickangle(45);

if plotOpt == 1
    ylimVals = [-150 200];
    ylim(ylimVals);
    yticks([ylimVals(1) 0 ylimVals(2)]);
    yticklabels({num2str(ylimVals(1)*-1),'0',num2str(ylimVals(2))});
else
    ylimVals = [0 200];
    ylim(ylimVals);
    yticks(ylimVals);
end
if doLabels
    ylabel('Units');
    title(plotTitle);
else
    yticklabels([]);
end

set(findall(gcf,'-property','FontSize'),'FontSize',26); % trick to get tightfig to work
tightfig;
setFig('','',[1,0.5]);
for iText = 1:numel(primBars)
    text(iText,primBars(iText),num2str(primBars(iText)),'VerticalAlignment','bottom','HorizontalAlignment','center','fontSize',fontSize);
    if ~onlyPrimary
        text(iText,primBars(iText)+secBars(iText),num2str(secBars(iText)),'VerticalAlignment','bottom','HorizontalAlignment','center','fontSize',fontSize);
    end
end

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'primSec_plot_unitClasses.eps'));
    close(h);
end


% pie charts
pieData = primFate;
useEvents = [3,4]; % limit 2
h = figuree(500,200);

for iEvent = 1:2
    subplot(1,2,iEvent);
% %     p = pie(pieData(useEvent,:)+.001,{eventFieldlabels{:},'NR'});
    p = pie(pieData(useEvents(iEvent),:)+.001);
    hText = findobj(h,'Type','text'); % text object handles
    percentValues = get(hText,'String'); % percent values
    oldExtents_cell = get(hText,'Extent'); % cell array
    oldExtents = cell2mat(oldExtents_cell); % numeric array
    disp('Counter-clockwise values left -> right subplot');
    disp(flip(percentValues));
    
    % labels are a pain in MATLAB, do them in illustrator
    if doLabels
        title(eventFieldlabels{useEvents(iEvent)});
        legend({eventFieldlabels{:},'NR'},'location','southoutside');
    else
        for ii = 2:2:numel(p)
            p(ii).String = '';
        end
    end
% %     setFig;
    colormap(colors);
end
tightfig;
setFig('','',[1,0.5]);

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'primSec_plot_primaryFate.eps'));
    close(h);
end

% then redo that for secOrigin if you want...
% % pieData = secOrigin(:,2:end);