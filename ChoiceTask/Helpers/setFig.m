% init:
% % subplotMargins = [.05,.02];
% % figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';

function setFig(xlabelVal,ylabelVal,cols)

set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'});
set(gcf,'color','w');
if exist('xlabelVal','var') && ~isempty(xlabelVal)
    xlab = xlabel(xlabelVal,'color','k');
    xlab.VerticalAlignment = 'bottom';
end
if exist('ylabelVal','var') && ~isempty(ylabelVal)
    ylab = ylabel(ylabelVal,'color','k');
    ylab.VerticalAlignment = 'top';
end

% jneuro formatting
set(gcf, 'PaperUnits','centimeters');

if exist('cols','var')
    curPaperSize = get(gcf, 'PaperSize');
    minusCm = 0;
    if numel(cols) > 1
        minusCm = cols(2);
    end
    cols = cols(1);
    if cols == 0.5
        figwidth = (8.5/2) - minusCm;
    elseif cols == 1
        figwidth = 8.5 - minusCm;
    elseif cols == 1.5
        figwidth = 11.6 - minusCm;
    elseif cols == 2
        figwidth = 17.6 - minusCm;
    else
        figwidth = cols - minusCm; % manual
    end
    % scale height
    figheight = (figwidth / curPaperSize(1)) * curPaperSize(2);
    set(gcf, 'PaperSize', [figwidth, figheight]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition',[0 0 figwidth figheight]);
end

set(findall(gcf,'-property','FontSize'),'FontSize',14);
box off;