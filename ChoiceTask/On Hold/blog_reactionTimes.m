fixRTs = sort(all_rt(all_rt >= .1));


xlimVals = [0 1];
figuree(800,300);
binEdges = linspace(xlimVals(1),xlimVals(2),100);
counts = histcounts(fixRTs,binEdges);
bar(binEdges(2:end),counts);

rec_RTs = 1./fixRTs;
qx = quantile(rec_RTs,linspace(0,1,100));
n = numel(qx);
y = pa_probit((1:n)./n);
figure;
plot(qx,y);

hold on
for ii = 1:numel(qx)
    lns = plot([qx(ii) qx(ii)],ylim,'r','lineWidth',1);
end
%%%%%%%%%%%%%%

% #1
histInt = .01;
xlimVals = [0 1];
figuree(800,300);
[counts,centers] = hist(fixRTs,[xlimVals(1):histInt:xlimVals(2)]+histInt);
bar(centers,counts,'faceColor','k','edgeColor','k');
xlabel('RT (s)');
xlim([0 1]);
xticks([0 1]);
ylim([0 200]);
yticks(ylim);
ylabel('trials');
set(gca,'fontSize',16);

qx = quantile(fixRTs,linspace(0,1,11));
hold on
for ii = 1:numel(qx)
    lns = plot([qx(ii) qx(ii)],ylim,'r','lineWidth',1);
end
title('Typical RT Distribution');
set(gcf,'color','w');
legend(lns,'10x Quantiles');

qx_RTs = [];
for ii_qx = 1:numel(qx)-1
    qx_RTs(ii_qx) = mean(fixRTs(fixRTs >= qx(ii_qx) & fixRTs < qx(ii_qx + 1)));
end

% #2

xlimVals = [1 1/.1];
figuree(800,300);
[counts,centers] = hist(1./fixRTs,100);
bar(centers,counts,'faceColor','k','edgeColor','k');
xlabel('1/RT (s)');
xlim(xlimVals);
xticks(xlim);
yticks(ylim);
ylabel('trials');
set(gca,'fontSize',16);

title('RT Reciprocal');
set(gcf,'color','w');

rec_RTs = 1./fixRTs;
qx = quantile(rec_RTs,linspace(0,1,11));
hold on
for ii = 1:numel(qx)
    lns = plot([qx(ii) qx(ii)],ylim,'r','lineWidth',1);
end
legend(lns,'10x Quantiles');

qx_recRTs = [];
for ii_qx = 1:numel(qx)-1
    qx_recRTs(ii_qx) = mean(rec_RTs(rec_RTs >= qx(ii_qx) & rec_RTs < qx(ii_qx + 1)));
end

% #3
% % figure;
% % yyaxis left;
% % plot(qx_RTs,'lineWidth',3);
% % ylabel('RT (s)');
% % hold on;
% % 
% % yyaxis right;
% % lns = plot(qx_recRTs,'lineWidth',3);
% % [f,gof] = fit([1:10]',qx_recRTs','poly1');
% % title('Quantile Comparison');
% % ylabel('1/RT (s)');
% % 
% % xticks([1:10]);
% % xlim([1 10]);
% % xlabel('Quantile');
% % set(gca,'fontSize',16);
% % set(gcf,'color','w');


% #4
n = numel(rec_RTs);
y = pa_probit((1:n)./n);

figure;
plot(rec_RTs,y,'k.');

figure;
plot(qx_RTs,y);
