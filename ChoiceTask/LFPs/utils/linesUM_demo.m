h = ff(800,700);
t = 0:0.01:10;
lineWidth = 10;
legendLabels = {};

subplot(211);
colors = linesUM;
for ii = 1:8
    plot(t,sin(t*rand),'color',colors(ii,:),'lineWidth',lineWidth*rand);
    hold on;
    legendLabels{ii} = ['UM #',num2str(ii)];
end
legend(legendLabels,'location','southwest');
legend boxoff;
xticks('');
ylim([-1 1]);
yticks('');
title('Michigan Primary Colors');
set(gca,'fontSize',16);

subplot(212);
colors = linesUM(Inf,true);
for ii = 1:12
    plot(t,sin(t*rand),'color',colors(ii,:),'lineWidth',lineWidth*rand);
    hold on;
    legendLabels{ii} = ['UM #',num2str(ii)];
end
legend(legendLabels,'location','southwest');
legend boxoff;
xticks('');
ylim([-1 1]);
yticks('');
title('Michigan Secondary Colors');
set(gca,'fontSize',16);

set(gcf,'color','w');
saveas(h,'lines_demo.png');