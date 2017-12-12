onlyPrimary = false;
show_primFate = false; % false = show_secOrigin
plotOpt = 2; % 1 = both sides of x-axis, 2 = mosaic
showMosaic = false;
plotTitle = 'Unit Classes';

doSetup = true;
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

figuree(500,500);
% cols = 7;
colors = parula(8);
% colors = colors(1:end,:);
colors(8,:) = [.8 .8 .8];

primBars = histcounts(primSec_wNC(:,1),0.5:8.5);
secBars = histcounts(primSec_wNC(:,2),0.5:8.5);

lns = [];
for iBar = 1:numel(secBars)
    if ~onlyPrimary
        lns(2) = bar(iBar,primBars(iBar) + secBars(iBar),'FaceColor',colors(iBar,:),'FaceAlpha',0.2,'EdgeColor','w','lineWidth',2);
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
else
    legend(lns,{'Primary Class','Secondary Class'},'location','northwest');
end

% formatting

for iText = 1:numel(primBars)
    text(iText,primBars(iText),num2str(primBars(iText)),'VerticalAlignment','bottom','HorizontalAlignment','center');
    if ~onlyPrimary
        text(iText,primBars(iText)+secBars(iText),num2str(secBars(iText)),'VerticalAlignment','bottom','HorizontalAlignment','center');
    end
end

set(gca,'fontsize',16);

xticks(1:8);
xticklabels({eventFieldlabels{:},'N.R.'});
ax = gca;
ax.XAxis.FontSize = 12;
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
ylabel('Units');
title(plotTitle);
box off;
set(gcf,'color','w');


% pie charts
pieData = primFate;
useEvents = [3,4]; % limit 2
figuree(500,500);

for iEvent = 1:2
    subplot(1,2,iEvent);
% %     p = pie(pieData(useEvent,:)+.001,{eventFieldlabels{:},'NR'});
    p = pie(pieData(useEvents(iEvent),:)+.001);
    legend({eventFieldlabels{:},'NR'},'location','southoutside');
    for ii = 2:2:numel(p)
% %         t = p(ii);
% %         t.FontSize = 16;
        p(ii).String = '';
    end
    title({eventFieldlabels{useEvents(iEvent)},'Primary Fate'});
% %     setFig;
    colormap(colors);
end
set(gcf,'color','w');

% then redo that for secOrigin if you want...
% % pieData = secOrigin(:,2:end);