sum(dirSelNeurons(find(primSec(:,1) == 4))); % nose out X dirSel
figure;
h = histogram(dirSelNeurons .* primSec(:,1),[0.5:7.5]);
text(1,8,['prim: ',num2str(h.Values)]);
hold on;
h = histogram(dirSelNeurons .* primSec(:,2),[0.5:7.5]);
text(1,5,['sec: ',num2str(h.Values)]);