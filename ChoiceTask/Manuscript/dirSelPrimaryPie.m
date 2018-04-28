% use primSec_plot.m to set primSec (unit classes)
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';
doSave = false;
% primary + secondary
h = figuree(1200,200);
removeUnitsArr = ones(1,366);
removeUnitsArr(removeUnits) = 0;
removeUnitsArr = logical(removeUnitsArr);
rows = 1;
for iEvent = 1:7
    subplot_tight(rows,7,iEvent,subplotMargins);
    % how many units for this event are directionally selective?
    totalPrimSecUnitsForEvent = sum(any(ismember(primSec(removeUnitsArr,:),iEvent),2));
    primSecUnitsDirAtEvent = sum(any(ismember(primSec(dirSelNeuronsNO(removeUnitsArr),:),iEvent),2));
    if iEvent == 3
        a = primSecUnitsDirAtEvent;
        b = totalPrimSecUnitsForEvent;
    elseif iEvent == 4
        c = primSecUnitsDirAtEvent;
        d = totalPrimSecUnitsForEvent;
    end
    posRatio = primSecUnitsDirAtEvent / sum(dirSelNeuronsNO(removeUnitsArr));
% %     posRatio = primSecUnitsDirAtEvent / totalPrimSecUnitsForEvent;
    p = pie([posRatio 1-posRatio]);
%     hText = findobj(h,'Type','text'); % text object handles
%     percentValues = get(hText,'String'); % percent values
%     hText(1).String = '';
    
    if doSave
        for ii = 2:2:numel(p)
            p(ii).String = '';
        end
    end
    
    colormap([1 0 0;repmat(0.2,1,3)]);
    if ~doSave
        title([eventFieldlabels{iEvent}]);
        legend('dir','~dir','location','southoutside');
    end
end
% uses z text
[z,y,y2] = cat_zTest(a,c,sum(dirSelNeuronsNO),sum(dirSelNeuronsNO));

if doSave
    tightfig;
    setFig('','',[2,1]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'dirSelPie_supplemental.eps'));
    close(h);
end

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