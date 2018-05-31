% % save_doesPhasePredictRT{71}
% % ans = 
% %   struct with fields:
% % 
% %          plotTimes: [1×100 double]
% %         all_powerZ: {7×2 cell}
% %      all_pval_corr: {7×2 cell}
% %     all_pval_angle: {7×2 cell}
% %            all_rho: {7×2 cell}


[uniqueLFPs,ic,ia] = unique(LFPfiles);
iBand = 1;
rows = 4;
cols = 7;
alphaRed = [1 0 0 .25];
alphaGray = [1 1 1 .25];
alphaBlue = [lines(1) .25];
lineWidthLg = 2;
lineWidthSm = 0.5;
plotTimes = save_doesPhasePredictRT{1}.plotTimes;
bandLabels = {'\beta','\gamma'};

figuree(1400,800);

% pAngle
xlabelText = 'pAngle';
iRow = 1;
neuronCount = 0;
for iEvent = 1:cols
    data_arr = [];
    for iNeuron = ic'
        neuronCount = neuronCount + 1;
        data_arr(neuronCount,:) = save_doesPhasePredictRT{iNeuron}.all_pval_angle{iEvent,iBand};
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        plot(plotTimes,data_arr(neuronCount,:),'color',alphaRed,'lineWidth',lineWidthSm);
        hold on;
    end
    plot(plotTimes,mean(data_arr),':r','lineWidth',lineWidthLg);
    xlim([plotTimes(1) plotTimes(end)]);
    xticks(sort([xlim 0]));
    ylim([0 1]);
    yticks(sort([ylim,0.5]));
    title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
    if iEvent == 1
        xlabel(xlabelText);
    end
    grid on;
end

xlabelText = 'pCorr RT';
iRow = 2;
neuronCount = 0;
for iEvent = 1:cols
    data_arr = [];
    for iNeuron = ic'
        neuronCount = neuronCount + 1;
        data_arr(neuronCount,:) = save_doesPhasePredictRT{iNeuron}.all_pval_corr{iEvent,iBand};
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        plot(plotTimes,data_arr(neuronCount,:),'color',alphaRed,'lineWidth',lineWidthSm);
        hold on;
    end
    plot(plotTimes,mean(data_arr),'-r','lineWidth',lineWidthLg);
    xlim([plotTimes(1) plotTimes(end)]);
    xticks(sort([xlim 0]));
    ylim([0 1]);
    yticks(sort([ylim,0.5]));
    title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
    if iEvent == 1
        xlabel(xlabelText);
    end
    grid on;
end

xlabelText = 'rho RT';
iRow = 3;
neuronCount = 0;
for iEvent = 1:cols
    data_arr = [];
    for iNeuron = ic'
        neuronCount = neuronCount + 1;
        data_arr(neuronCount,:) = save_doesPhasePredictRT{iNeuron}.all_rho{iEvent,iBand};
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        plot(plotTimes,data_arr(neuronCount,:),'color',alphaGray,'lineWidth',lineWidthSm);
        hold on;
    end
    plot(plotTimes,mean(data_arr),'-k','lineWidth',lineWidthLg);
    xlim([plotTimes(1) plotTimes(end)]);
    xticks(sort([xlim 0]));
    ylim([0 1]);
    yticks(ylim);
    title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
    if iEvent == 1
        xlabel(xlabelText);
    end
    grid on;
end

xlabelText = 'power';
iRow = 4;
neuronCount = 0;
for iEvent = 1:cols
    data_arr = [];
    for iNeuron = ic'
        neuronCount = neuronCount + 1;
        data_arr(neuronCount,:) = save_doesPhasePredictRT{iNeuron}.all_rho{iEvent,iBand};
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        plot(plotTimes,data_arr(neuronCount,:),'color',alphaBlue,'lineWidth',lineWidthSm);
        hold on;
    end
    plot(plotTimes,mean(data_arr),'-','color',lines(1),'lineWidth',lineWidthLg);
    xlim([plotTimes(1) plotTimes(end)]);
    xticks(sort([xlim 0]));
    ylim([-1 5]);
    yticks(sort([ylim,0.5]));
    title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
    if iEvent == 1
        xlabel(xlabelText);
    end
    grid on;
end