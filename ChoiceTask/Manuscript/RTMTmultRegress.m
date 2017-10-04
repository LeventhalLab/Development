if false
    validIdx = allTrial_useTime > .05;
    x1 = allTrial_useTime(validIdx)'; % RT
    x2 = allTrial_useTime2(validIdx)'; % MT
    y = mean(allTrial_z(validIdx,20:21),2);
    X = [ones(size(x1)) x1 x2 x1.*x2];
    [b,bint,r,rint,stats] = regress(y,X)

    figure;
    scatter3(x1,x2,y,'filled')
    hold on
    x1fit = 0:.01:1;
    x2fit = 0:.01:1;
    [X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
    YFIT = b(1) + b(2)*X1FIT + b(3)*X2FIT + b(4)*X1FIT.*X2FIT;
    mesh(X1FIT,X2FIT,YFIT)
    xlabel('RT')
    ylabel('MT')
    zlabel('Z @ t=0')
    view(50,10)
end

figure;
qx_intercepts = ezReciprobit(all_rt,10);
figure;
ezReciprobit(all_rt(all_rt <= qx_intercepts(2)),10);
ezReciprobit(all_rt(all_rt > qx_intercepts(2) & all_rt <= qx_intercepts(11)),10);
% ezReciprobit(all_rt(all_rt > qx_intercepts(10)),10);

figure;
ezReciprobit(all_mt(all_mt <= .450),10);
ezReciprobit(all_mt(all_mt > .450),10);
xlim([-1/100 0])

figure;
loglog(-1./all_rt/1000,-1./all_mt/1000,'k.')
xtickVals = -1./[10 1000];
xticks(xtickVals);
ytickVals = -1./[150 1000];
yticks(ytickVals);
xlim([min(xtickVals) max(xtickVals)]);
ylim([min(ytickVals) max(ytickVals)]);
xticklabels({'10','1000'});
yticklabels({'150','1000'});
xlabel('RT (ms^-1)');
ylabel('MT (ms^-1)');
title('MT vs. RT log scale');


% % X = [-1./all_rt(all_rt>0)'/1000,-1./all_mt(all_rt>0)'/1000];
% % opts = statset('Display','final');
% % [idx,C] = kmeans(X,2,'Distance','cityblock',...
% %     'Replicates',5,'Options',opts);
% % 
% % figure;
% % plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
% % hold on
% % plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
% % plot(C(:,1),C(:,2),'kx',...
% %      'MarkerSize',15,'LineWidth',3)
% % legend('Cluster 1','Cluster 2','Centroids',...
% %        'Location','NW')
% % title 'Cluster Assignments and Centroids'
% % hold off

% figure;
% mesh(x1,x2,y);
% xlabel('RT')
% ylabel('MT')
% zlabel('Z @ t=0')