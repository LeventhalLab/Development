colors = gray(3);

figuree(500,500);
dirPrimUnits = dirSelNeurons .* primSec(:,1);
dirPrimUnits(isnan(dirPrimUnits)) = 8;
dirPrimUnits(dirPrimUnits == 0) = [];
primDirSel = histcounts(dirPrimUnits,[0.5:8.5]);

dirSecUnits = dirSelNeurons .* primSec(:,2);
dirSecUnits(isnan(dirSecUnits)) = 8;
dirSecUnits(dirSecUnits == 0) = [];
secDirSel = histcounts(dirSecUnits,[0.5:8.5]);

b = bar([primDirSel' secDirSel'],'stacked','FaceColor','flat','EdgeColor','w','lineWidth',2);

for k = 1:2
    b(k).CData = colors(k,:);
end
legend('Primary Units','Secondary Units');
title('Directonally Selective Units by Event');
xticklabels({eventFieldlabels{:},'N.R.'});
xtickangle(30);
ylabel('Units');
setFig;