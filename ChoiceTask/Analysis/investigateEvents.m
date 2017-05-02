eventId = 4;
eventIds_sub = find(sorted_eventIds == eventId);
neuronIds = sorted_eventKeys(eventIds_sub);

% event 4
curatedIds = [6,8,9,12,14,16,17,19,21,26,27,28,29,31,36,37,44,46,48,49,51,56,57,58,59,66,70];
% curatedIds = [8,9,12,14,16,21,26,28,29];
% curatedIds = neuronIds;

for iStart = 1:16:numel(neuronIds)
    figure('position',[0 0 900 900]);
    iSubplot = 1;
    for iNeuron = iStart:min([iStart+15 numel(neuronIds)])
        curPeths = all_tsPeths{neuronIds(iNeuron)};
        subplot(4,4,iSubplot);
        plotSpikeRaster(curPeths(:,eventId));
%         title(analysisConf.neurons(neuronIds(iNeuron)),'interpreter','none');
        title(num2str(iNeuron));
        xlim([-1 1]);
        iSubplot = iSubplot + 1;
    end
    disp('hold');
end

all_ISIs = [];
all_rasters = [];
all_counts = [];
all_neuronCounts = [];
neuronCount = 1;
for iNeuron = curatedIds
    curPeths = all_tsPeths{iNeuron};
    curPeth = curPeths(:,eventId);
    neuronTs = [];
    for iRasterLine = 1:numel(curPeth)
        ts_raster = curPeth{iRasterLine};
        all_rasters = [all_rasters ts_raster];
        neuronTs = [neuronTs ts_raster];
        ts_sub = ts_raster(ts_raster > -.2 & ts_raster < 0.5);
        if ~isempty(ts_sub)
            all_ISIs = [all_ISIs diff(ts_sub)];
        end
    end
    [counts_neuronTs,~] = hist(neuronTs,linspace(-1,1,500));
    all_neuronCounts(neuronCount,:) = counts_neuronTs;
    neuronCount = neuronCount + 1;
end
nBins = 500;
[counts,centers] = hist(all_rasters,linspace(-1,1,500));
figure;
plot(centers,smooth(counts,20));
curxticks = xticks;
title('centetOut - curated');
ylabel('counts');
xlabel('time (s)');

calculateComplexScalograms_EnMasse(all_neuronCounts','fpass',[1 30],'numfreqs',100,'Fs',nBins/2,'doplot',true);
colorbar
caxis([0 18])
colormap(jet)
xticks(linspace(0,2,numel(curxticks)));
xticklabels({curxticks(:)});
title('centetOut - curated');
xlabel('time (s)')

% figure;
% hist(all_ISIs,linspace(.01,.1,100));
% xlim([.011 .09]);
