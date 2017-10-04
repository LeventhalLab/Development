function qx_intercepts = ezReciprobit(rt,nquant)
rtMs = rt * 1000;
rtinv  = 1./rtMs;
% raw data
x = -1./sort((rtMs)); % multiply by -1 to mirror abscissa
n = numel(rtinv); % number of data points
y = pa_probit((1:n)./n); % cumulative probability for every data point converted to probit scale
% figure;
plot(x,y,'k.');
hold on

% quantiles
p = round(linspace(0,100,nquant+1))/100;
% p = [1 2 5 10 20 50 80 90 95 98 99]/100;
probit  = pa_probit(p);
q = quantile(rtMs,p);
q = -1./q;
xtickVals = -1./[50 100 1000];
xticks(xtickVals);
xlim([min(xtickVals) max(xtickVals)]);
xticklabels({'50','100','1000'});
plot(q,probit,'ko','Color','k','MarkerFaceColor','r','LineWidth',1);
yticks(probit);
yticklabels(p*100);
set(gca,'YTick',probit,'YTickLabel',p*100);
ylim([pa_probit(0.1/100) pa_probit(99.9/100)]);
axis square;
box off
xlabel('Latency (ms)');
ylabel('Cumulative probability');
title('Probit ordinate');
grid on;

qx_intercepts = (-1./q) / 1000;

% this should be a straight line
% % x = q;
% % y = probit;
% % b = regstats(y,x);
% % h = pa_regline(b.beta,'k-');
% % set(h,'Color','r','LineWidth',2);