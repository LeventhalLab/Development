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
rows = 4;
cols = 7;
alphaRed = [1 0 0 .05];
alphaGray = [0 0 0 .05];
alphaBlue = [lines(1) .05];
lineWidthLg = 2;
lineWidthSm = 0.25;
plotTimes = save_doesPhasePredictRT{1}.plotTimes;
bandLabels = {'\beta','\gamma'};

for iBand = 1:2
    h = figuree(1400,800);
    set(h,'defaultAxesColorOrder',[[0 0 0];[0 0 0]]);

    % pAngle
    ylabelText = 'pAngle';
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
        yticks(sort([ylim,0.05]));
        title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
        if iEvent == 1
            ylabel(ylabelText);
        end
        grid on;
    end

    ylabelText = 'pCorr RT';
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
        yticks(sort([ylim,0.05]));
        title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
        if iEvent == 1
            ylabel(ylabelText);
        end
        grid on;
    end

    ylabelText = 'rho RT';
    iRow = 3;
    neuronCount = 0;
    for iEvent = 1:cols
        data_arr = [];
        for iNeuron = ic'
            neuronCount = neuronCount + 1;
            data_arr(neuronCount,:) = save_doesPhasePredictRT{iNeuron}.all_rho{iEvent,iBand};
            subplot(rows,cols,prc(cols,[iRow,iEvent]));
            yyaxis left;
            plot(plotTimes,data_arr(neuronCount,:),'-','color',alphaGray,'lineWidth',lineWidthSm);
            hold on;
        end
        ylim([0 1]);
        yticks(ylim);
        if iEvent == 1
            ylabel(ylabelText);
        end
        yyaxis right;
        plot(plotTimes,mean(data_arr),'-k','lineWidth',lineWidthLg);
        xlim([plotTimes(1) plotTimes(end)]);
        xticks(sort([xlim 0]));
        ylim([0 0.1]);
        yticks(ylim);
        title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
        grid on;
    end

    ylabelText = 'power';
    iRow = 4;
    neuronCount = 0;
    for iEvent = 1:cols
        data_arr = [];
        for iNeuron = ic'
            neuronCount = neuronCount + 1;
            data_arr(neuronCount,:) = save_doesPhasePredictRT{iNeuron}.all_powerZ{iEvent,iBand};
            subplot(rows,cols,prc(cols,[iRow,iEvent]));
            yyaxis left;
            plot(plotTimes,data_arr(neuronCount,:),'-','color',alphaBlue,'lineWidth',lineWidthSm);
            hold on;
        end
        ylim([-1 5]);
        yticks(sort([ylim,0]));
        if iEvent == 1
            ylabel(ylabelText);
        end
        yyaxis right;
        plot(plotTimes,mean(data_arr),'-','color',lines(1),'lineWidth',lineWidthLg);
        xlim([plotTimes(1) plotTimes(end)]);
        xticks(sort([xlim 0]));
        ylim([-1 5]/10);
        yticks(sort([ylim,0]));
        title([bandLabels{iBand},' ',eventFieldnames{iEvent}]);
        grid on;
    end

    set(h,'color','w');
end