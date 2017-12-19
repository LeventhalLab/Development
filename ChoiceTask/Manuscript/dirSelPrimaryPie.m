% use primSec_plot.m to set primSec (unit classes)

colors = parula(8);
rows = 2;
figuree(1200,800);
for iiprimSec = 1:2
    for iEvent = 1:7
        subplot(rows,7,(iiprimSec * 7)-7+iEvent);
        curUnits = ismember(primSec(:,iiprimSec),iEvent);
        curUnits_dir = curUnits & dirSelNeuronsNO;
        pie([sum(curUnits_dir)/sum(curUnits) 1-sum(curUnits_dir)/sum(curUnits)]);
        colormap([1 0 0;repmat(0.2,1,3)]);
        title([eventFieldlabels{iEvent}]);
        legend('dir','~dir','location','southoutside');
        setFig;
    end
end

dirSelNeuronsNO_01