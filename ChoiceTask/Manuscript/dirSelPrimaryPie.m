% use primSec_plot.m to set primSec (unit classes)

% primary + secondary
figuree(900,400);
rows = 1;
for iEvent = 1:7
    subplot(rows,7,iEvent);
    % how many units for this event are directionally selective?
    totalPrimSecUnitsForEvent = sum(any(ismember(primSec(:,:),iEvent),2));
    primSecUnitsDirAtEvent = sum(any(ismember(primSec(dirSelNeuronsNO_01,:),iEvent),2));
    if iEvent == 3
        a = primSecUnitsDirAtEvent;
        b = totalPrimSecUnitsForEvent;
    elseif iEvent == 4
        c = primSecUnitsDirAtEvent;
        d = totalPrimSecUnitsForEvent;
    end
    posRatio = primSecUnitsDirAtEvent / sum(dirSelNeuronsNO_01);
% %     posRatio = primSecUnitsDirAtEvent / totalPrimSecUnitsForEvent;
    pie([posRatio 1-posRatio]);
    colormap([1 0 0;repmat(0.2,1,3)]);
    title([eventFieldlabels{iEvent}]);
    legend('dir','~dir','location','southoutside');
    setFig;
end

[x2,p] = chiSquare(a,c,sum(dirSelNeuronsNO_01),sum(dirSelNeuronsNO_01))


% % colors = parula(8);
% % rows = 2;
% % figuree(1200,800);
% % for iiprimSec = 1:2
% %     for iEvent = 1:7
% %         subplot(rows,7,(iiprimSec * 7)-7+iEvent);
% %         curUnits = ismember(primSec(:,iiprimSec),iEvent);
% %         curUnits_dir = curUnits & dirSelNeuronsNO_01;
% %         pie([sum(curUnits_dir)/sum(curUnits) 1-sum(curUnits_dir)/sum(curUnits)]);
% %         colormap([1 0 0;repmat(0.2,1,3)]);
% %         title([eventFieldlabels{iEvent}]);
% %         legend('dir','~dir','location','southoutside');
% %         setFig;
% %     end
% % end