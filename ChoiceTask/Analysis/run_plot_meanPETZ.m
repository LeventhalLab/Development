close all;
figure('position',[0 0 1100 800]);

subplot(221);
hold on;
xLin = linspace(-tWindow,tWindow,size(all_zMean,2));
x = repmat(xLin,size(all_zMean,1),1)';
yLin = [1:size(all_zMean,1)];
y = repmat(yLin,size(all_zMean,2),1);
plot(x,all_zMean','color',[.5 .5 .5 .5]);
% plot3(x,y,all_zMean','color',[.5 .5 .5 .5]);

ZLims = [-3 3];
xlim([-tWindow tWindow]);
xlabel('time (s)');
ylim(ZLims);
ylabel('Z-score');
title('R0142 center out, FR Z');
grid on;

edgeErr = 500;
xs = -2;
ys = 0;
initLoop = true;
while(true)
    if initLoop
        initLoop = false;
    else
        [xs,ys] = ginput(1);
        delete(l1);
        delete(l2);
    end
    if(ys > 1.7)
        break;
    end

    threshCrossings = [];
    for iNeuron = 1:size(all_zMean,1)
        if y >= 0
            idxToEnd = find(xLin > xs);
            threshIdxs = find(all_zMean(iNeuron,idxToEnd(1):end) > ys);
            if isempty(threshIdxs)
                threshCrossings(iNeuron) = size(all_zMean,2);
            else
                threshCrossings(iNeuron) = threshIdxs(1) + idxToEnd(1);
            end
        else
            idxToEnd = find(xLin < xs);
            threshIdxs = find(all_zMean(iNeuron,idxToEnd(1):end) < ys);
            if isempty(threshIdxs)
                threshCrossings(iNeuron) = size(all_zMean,2);
            else
                threshCrossings(iNeuron) = threshIdxs(1) + idxToEnd(1);
            end
        end
    end

    [v,k] = sort(threshCrossings);
    sorted_all_zMean = all_zMean(k,:);
    
    subplot(221);
    l1 = plot([min(xLin) max(xLin)],[ys ys],'r--');
    l2 = plot([xs xs],[ZLims],'r--');

    subplot(222);
    imagesc(sorted_all_zMean);
    colormap(jet);
    colorbar;
    caxis([-2 2]);
    xtickVals = linspace(0,size(all_zMean,2),11);
    xTickLabelVals = linspace(-tWindow,tWindow,11);
    xticks(xtickVals);
    xticklabels(xTickLabelVals);
    xlim([0 size(all_zMean,2)]);
    xlabel('time (s)');
    ylabel('unit #');
    title('R0142 center out, sorted by FR Z');
    
    subplot(224);
    plot3(x,y,sorted_all_zMean','color',[.5 .5 .5 .5]);
    xlim([-tWindow tWindow]);
    xlabel('time (s)');
    ylabel('unit #');
    zlabel('Z-score');
    title('R0142 center out, FR Z');
    grid on;
%     view(0,0);
    
end