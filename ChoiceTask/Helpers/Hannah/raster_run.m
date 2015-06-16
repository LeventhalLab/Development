x = rand(1);
ts1Id = (ts1) >= x & (ts1) <= (x+8);
ts2Id = (ts2) >= x & (ts2) <= (x+8);
ts3Id = (ts3) >= x & (ts3) <= (x+8);

ts3Plot = {decimate(ts3(ts3Id),1)};
ts2Plot = {ts2(ts2Id)};
ts1Plot = {decimate(ts1(ts1Id),1)};
h = figure;
hold on
if ~isempty(ts1Plot{1})
    if ~isempty(ts2Plot{1})
        if ~isempty(ts3Plot{1})
            subplot(311);
            plotSpikeRaster(ts1Plot,'PlotType', 'vertline');
            subplot(312);
            plotSpikeRaster(ts2Plot,'PlotType', 'vertline');
            subplot(313);
            plotSpikeRaster(ts3Plot,'PlotType', 'vertline');
        end
    end
end
