% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
eventNumber = 4;
maxSpikes = 20;
eventNeuronIds = find(eventIds_by_maxHistValues == eventNumber);
% sorted_eventNeuronIds = sorted_eventKeys(eventNeuronIds);
rasterData = {}; % M x 1 cell, M = trial, 1 x N vector spiketimes inside
rasterCount = 1;
sortArr = [];
for iNeuron = 1:numel(sorted_eventKeys)
    cur_tsPeths = all_tsPeths{sorted_eventKeys(iNeuron)};
    for iTrial = 1:size(cur_tsPeths,1)
        cur_ts = cur_tsPeths{iTrial,eventNumber};
        if numel(cur_ts) > 3
            if numel(cur_ts) > maxSpikes
                cur_ts = sort(randsample(cur_ts,maxSpikes));
            end
            rasterData{rasterCount,1} = cur_ts;
%             sortArr(rasterCount) = numel(cur_ts);
            ISI = diff(cur_ts);
            sortArr(rasterCount) = max(((ISI - mean(ISI)) / std(ISI)));
            rasterCount = rasterCount + 1;
        end
    end
end
[v,k] = sort(sortArr);
% data = makeRasterReadable(rasterData(k),50);
figure;
plotSpikeRaster(rasterData(k),'PlotType','scatter');
% xlim([-.25 .25]);