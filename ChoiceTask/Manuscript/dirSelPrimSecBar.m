colors = gray(3);

figuree(500,500);
primDirSel = histcounts(dirSelNeurons .* primSec(:,1),[0.5:7.5]);
secDirSel = histcounts(dirSelNeurons .* primSec(:,2),[0.5:7.5]);
b = bar([primDirSel' secDirSel'],'stacked','FaceColor','flat','EdgeColor','w','lineWidth',2);

for k = 1:2
    b(k).CData = colors(k,:);
end
legend('Primary Units','Secondary Units');
title('Directonally Selective Units by Event');
xticklabels(eventFieldlabels);
xtickangle(30);
ylabel('Units');
setFig;