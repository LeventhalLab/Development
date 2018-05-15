% use primSec_plot.m to set primSec (unit classes)
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Figures/MATLAB';
doSave = true;
% primary + secondary
keepUnitsArr = ones(1,366);
keepUnitsArr(removeUnits) = 0;
keepUnitsArr = logical(keepUnitsArr);
all_posRatios = [];
for iEvent = 1:7
    % how many units for this event are directionally selective?
    totalPrimSecUnitsForEvent = sum(any(ismember(primSec(keepUnitsArr,:),iEvent),2));
    primSecUnitsDirAtEvent = sum(any(ismember(primSec(dirSelNeuronsNO(keepUnitsArr),:),iEvent),2));
    
    posRatio = primSecUnitsDirAtEvent / sum(dirSelNeuronsNO(keepUnitsArr));
    all_posRatios(iEvent,:) = [posRatio 1-posRatio];
    
end
h = figuree(250,250);
b = bar(all_posRatios,'stacked');
b(1).FaceColor = [1 0 0];
b(2).FaceColor = [0 0 0];
ylim([0 0.5]);
yticks(ylim);
xlim([0 8]);
xticks([1:7]);
if ~doSave
    xticklabels(eventFieldlabels);
    yticklabels({'0','50'});
    xtickangle(90);
else
    xticklabels({});
    yticklabels({});
end


if doSave
    tightfig;
    setFig('','',[1,6]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'dirSelPrimaryBar.eps'));
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