colors = jet(numel(all_mt_c));
all_slopes = [];
all_rsquare = [];
for iSession = 1:numel(all_rt_c)
    x = all_rt_c{iSession};
    y = all_mt_c{iSession};
%     [param,stat] = sigm_fit(all_rt_c{iSession},all_mt_c{iSession},[],[],1);
%     hold on;
%     plot(all_rt_c{iSession},all_mt_c{iSession},'.','color',colors(iSession,:),'MarkerSize',10);
%     all_slopes(iSession,1) = param(4);
%     all_slopes(iSession,2) = mean(all_rt_c{iSession});
    [fitresult, gof] = sigmoidFit(x,y,false);
    all_rsquare(iSession,1) = gof.rsquare;
    if gof.rsquare < 0.8
        iSession
    end
    [xData, yData] = prepareCurveData(x,y);
    [fitresult, gof] = fit(xData,yData,'poly1');
    all_rsquare(iSession,2) = gof.rsquare;
end
figure;
plot([1 1;2 2]',[0 1;0 1]','--','color',[.5 .5 .5]);
hold on;
plot([1-.2 1+.2],[mean(all_rsquare(:,1)) mean(all_rsquare(:,1))],'r','LineWidth',3);
plot([2-.2 2+.2],[mean(all_rsquare(:,2)) mean(all_rsquare(:,2))],'r','LineWidth',3);
plotSpread(all_rsquare);
ylim([0 1]);
ylabel('R2');
xticks([1 2]);
xticklabels({'Sigmoid','Linear'});


% % grid on;
% % xlim(xlimVals);
% % ylim([.1 1]);
% % xlabel('RT (s)');
% % ylabel('MT (s)');
% % title(['by session, N = ',num2str(numel(all_mt_c))]);
% % 
% % figure;
% % plot(all_slopes(:,1),all_slopes(:,2),'k.');