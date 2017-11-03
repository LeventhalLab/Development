function setFig(xlabelVal,ylabelVal)
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'});
set(gca,'fontSize',16);
set(gcf,'color','w');
if exist('xlabelVal')
    xlab = xlabel(xlabelVal,'color','k');
    xlab.VerticalAlignment = 'bottom';
end
if exist('ylabelVal')
    ylab = ylabel(ylabelVal,'color','k');
    ylab.VerticalAlignment = 'top';
end
box off;