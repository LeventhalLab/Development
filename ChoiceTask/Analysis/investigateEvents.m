eventId = 4;
eventIds_sub = find(sorted_eventIds == eventId);
neuronIds = sorted_eventKeys(eventIds_sub);

% event 4
selectedIds = [6,8,9,12,14,16,17,19,21,26,27,28,29,31,36,37,44,46,48,49,51,56,57,58,59,66,70];
% curatedIds = [8,9,12,14,16,21,26,28,29];
% allPossibleIds =  [1:numel(neuronIds)];
% allPossibleIds(selectedIds) = [];
% curatedIds = selectedIds;
% curatedIds = [1:numel(neuronIds)];
% curatedIds = allPossibleIds;
% curatedIds = neuronIds';
% curatedIds = neuronIds(selectedIds)';
% curatedIds = neuronIds(allPossibleIds)';


for iStart = 1:16:numel(neuronIds)
    figure('position',[0 0 900 900]);
    iSubplot = 1;
    for iNeuron = iStart:min([iStart+15 numel(neuronIds)])
        curPeths = all_tsPeths{neuronIds(iNeuron)};
        subplot(4,4,iSubplot);
        plotSpikeRaster(curPeths(:,eventId));
%         title(analysisConf.neurons(neuronIds(iNeuron)),'interpreter','none');
        title(num2str(iNeuron));
%         xlim([-1 1]);
        iSubplot = iSubplot + 1;
    end
    disp('hold');
end

all_ISIs = [];
all_rasters = [];
all_counts = [];
all_neuronCounts = [];
neuronCount = 1;
nBins = tWindow*2000;
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
    [counts_neuronTs,~] = hist(neuronTs,linspace(-tWindow,tWindow,nBins));
    all_neuronCounts(neuronCount,:) = counts_neuronTs;
    neuronCount = neuronCount + 1;
end

[counts,centers] = hist(all_rasters,linspace(-tWindow,tWindow,nBins));
figure;
plot(centers,smooth(counts,20));
curxticks = xticks;
title('centerOut - curated');
ylabel('counts');
xlabel('time (s)');

fpass = [1 30];
freqList = logFreqList(fpass,100);

% calculateComplexScalograms_EnMasse(all_neuronCounts','freqList',[1:30],'Fs',nBins/(tWindow*2),'doplot',true);
% colormap(jet);
% xlim([1 5]);
% caxis auto;

[W,freqList] = calculateComplexScalograms_EnMasse(all_neuronCounts','freqList',freqList,'Fs',nBins/(tWindow*2));
figure;
Wscalo = squeeze(mean(abs(W).^2,2))';
t = linspace(-tWindow,tWindow,size(Wscalo,2));
imagesc(t,freqList,log(Wscalo));
colorbar
caxis([0 18])
colormap(jet)
xticks([-tWindow,0,tWindow]);
set(gca,'Ytick',round(logFreqList(fpass,5)));
set(gca,'TickDir','out');
set(gca,'YScale','log');
set(gca,'YDir','normal');
title('centetOut - curated');
xlabel('time (s)');
ylim(fpass);
xlim([-2 2]);
caxis auto;

% figure;
% hist(all_ISIs,linspace(.01,.1,100));
% xlim([.011 .09]);
