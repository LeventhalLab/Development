h = figure;

allCaxis = [];
densityLabels = {'all','low density','med density','high density'};
plotCount = 1;
for iRow=1:length(densityLabels)
    for iScalogram = 1:length(allTsScalograms)
        plotTitle = densityLabels{iRow};
        if iRow == 1
            plotTitle = {allScalogramTitles{iScalogram},plotTitle};
        end
        if plotCount == 1
            plotTitle = {neuronName,plotTitle{:}};
        end
        curScalograms = allTsScalograms{iScalogram};
        subplot(length(densityLabels),length(allTsScalograms),plotCount);
        if ~isempty(curScalograms)
            imagesc(t,freqList,squeeze(curScalograms(iRow,:,:)));
        end
        title(plotTitle,'interpreter','none');
        if iRow==length(densityLabels)
            xlabel('Time (s)');
        end
        ylabel('Freq (Hz)');
        set(gca,'YDir','normal');
        xlim([-1 1]);
        set(gca,'YScale','log');
        set(gca,'Ytick',round(logFreqList(fpass,5)));
        colormap(jet);
        allCaxis(plotCount,:) = caxis;
        colorbar;
        plotCount = plotCount + 1;
    end
end

% % caxisValues = upperLowerPrctile(allCaxis,25);
% % for iSubplot=1:plotCount-1
% %     subplot(length(densityLabels),length(allTsScalograms),iSubplot);
% %     caxis(caxisValues);
% % end

subFolder = 'tsPrctlScalos';
docName = [subFolder,'_',neuronName];
savePDF(h,sessionConf.leventhalPaths,subFolder,docName,true);