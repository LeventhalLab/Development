h = figure;

for iSubplot=[1,3]
    subplot(2,2,iSubplot);
    plotSpikeRaster(makeRasterReadable(rasterTs,100),'PlotType','scatter');
    xlabel('Time (s)');
    ylabel('low power <-- LFP Peaks --> high power');
    if iSubplot == 1
        title({[num2str(fpass),' Hz Bandpass Filtered'],'Centered on LFP peak'});
    else
        hold on;
        for iEvent=1:length(rasterEvents)
            if ~isempty(rasterEvents{iEvent})
                plot(rasterEvents{iEvent},iEvent,'*','Color','red');
            end
        end
        title(['Overlaying ',fieldname,' events']);
    end
end

histBins = 25;
subplot(222);
[counts,centers] = hist(allTs,histBins);
bar(centers,(counts-mean(counts))/std(counts),'k','EdgeColor','k');
title('Spike Timestamp Histogram');
xlabel('Time (s)');
ylabel('Z-score');

histBins = 7;
subplot(224);
[counts,centers] = hist(allEvents,histBins);
bar(centers,(counts-mean(counts))/std(counts),'k','EdgeColor','k');
title([fieldname, ' Time Histogram']);
xlabel('Time (s)');
ylabel('Z-score');

subFolder = 'lfpRasters';
docName = [subFolder,'_',neuronName];
savePDF(h,sessionConf.leventhalPaths,subFolder,docName);