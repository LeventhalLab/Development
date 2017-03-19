powerScalo_clim = [2 3.5];
plot_t_limits = [-1,1];
z_clim = [-2 2];

allCaxis = [];
densityLabels = {'all','low density','med density','high density'};
allScalogramTitles = {'ts','tsISI','tsLTS','tsPoisson'};

rootDir = '/Volumes/Tbolt_02/VM thal analysis';
cd(rootDir);

ratDirs = dir;

numRowsPerPage = 3;

plot_freqLim = [10, 50];
for i_ratDir = 1 : length(ratDirs)
    
    cd(rootDir);
    
    cur_ratDir = ratDirs(i_ratDir).name;
    if ~isdir(cur_ratDir) || any(strcmp(cur_ratDir,{'.','..'}))
        continue;
    end
    
    cur_ratDir = fullfile(rootDir,cur_ratDir);
    cd(cur_ratDir);
    sessionDirs = dir;
    
    for i_sessionDir = 1 : length(sessionDirs)
        cur_sessionDir = sessionDirs(i_sessionDir).name;
        cd(cur_ratDir);
        if ~isdir(cur_sessionDir) || any(strcmp(cur_sessionDir,{'.','..'}))
            continue;
        end
        
        cur_sessionDir = fullfile(cur_ratDir,cur_sessionDir);
        cd(cur_sessionDir);
        unitFiles = dir;
        
        plotCount = 1;
        h = figure;
        h_z = figure;
            
        for iUnit = 1 : length(unitFiles)
            cur_unitFile = unitFiles(iUnit).name;
            if length(cur_unitFile) < 4;continue;end
            if strcmpi(cur_unitFile(1:2),'._'); continue; end
            if ~strcmpi(cur_unitFile(end-3:end),'.mat'); continue; end
            
            ratID = cur_unitFile(1:5);
            switch ratID
                case 'R0088'
                    powerScalo_clim = [2 3.5];
                case 'R0117'
                    powerScalo_clim = [0 2];
            end
            load(cur_unitFile);
            suffixStart = strfind(cur_unitFile,'_scalos');
            neuronName = cur_unitFile(1:suffixStart-1);
            t = scaloMetadata.t;
            f = scaloMetadata.f;
            
            if exist('mean_logpsd','var')
                meanScalo = repmat(mean_logpsd,[1,length(t)]);
                stdScalo = repmat(std_logpsd,[1,length(t)]);
            end
            

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
                    
                    figure(h);
                    subplot(length(densityLabels),length(allTsScalograms),plotCount);
                    toPlot = log10(squeeze(curScalograms(iRow,:,:)));
                    if ~isempty(curScalograms)
            %             h_pcolor = pcolor(t,freqList,squeeze(curScalograms(iRow,:,:)));
                        h_pcolor = pcolor(t,f,toPlot);
                    end
                    h_pcolor.EdgeColor = 'none';
                    title(plotTitle,'interpreter','none');
                    if iRow==length(densityLabels)
                        xlabel('Time (s)');
                    end
                    ylabel('Freq (Hz)');
                    set(gca,'YDir','normal',...º
                            'clim',powerScalo_clim,...
                            'ylim',plot_freqLim);
                    xlim(plot_t_limits);
                    set(gca,'YScale','log');
%                     set(gca,'Ytick',round(logFreqList(fpass,5)));
                    set(gca,'Ytick',round(logFreqList(plot_freqLim,5)));
                    colormap(jet);
                    allCaxis(plotCount,:) = caxis;
            %         colorbar;
                    
                    if exist('mean_logpsd','var')
                        curScalograms = all_logTsScalograms{iScalogram};
                        figure(h_z);
                        subplot(length(densityLabels),length(allTsScalograms),plotCount);
%                         toPlot = log10(squeeze(curScalograms(iRow,:,:)));
                        toPlot = (squeeze(curScalograms(iRow,:,:)) - meanScalo) ./ stdScalo;

                        if ~isempty(curScalograms)
                %             h_pcolor = pcolor(t,freqList,squeeze(curScalograms(iRow,:,:)));
                            h_pcolor = pcolor(t,f,toPlot);
                        end
                        h_pcolor.EdgeColor = 'none';
                        title(plotTitle,'interpreter','none');
                        if iRow==length(densityLabels)
                            xlabel('Time (s)');
                        end
                        ylabel('Freq (Hz)');
                        set(gca,'YDir','normal',...º
                                'clim',z_clim,...
                                'ylim',plot_freqLim);
                        xlim(plot_t_limits);
                        set(gca,'YScale','log');
    %                     set(gca,'Ytick',round(logFreqList(fpass,5)));
                        set(gca,'Ytick',round(logFreqList(plot_freqLim,5)));
                        colormap(jet);
                        allCaxis(plotCount,:) = caxis;
                %         colorbar;
                    end
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
            fp = fillPage(h,'margins',[0 0 2 0],'papersize',[11 9.5]);
            print(h,'-opengl','-dpdf','-r200',fullfile(cur_sessionDir,['tsPrctlScalos_' scaloMetadata.neuron]))
            savefig(h,fullfile(cur_sessionDir,['tsPrctlScalos_' scaloMetadata.neuron]),'compact')
            close(h);
            
            if exist('mean_logpsd','var')
                print(h_z,'-opengl','-dpdf','-r200',fullfile(cur_sessionDir,['tsPrctlScalos_z_' scaloMetadata.neuron]))
                savefig(h_z,fullfile(cur_sessionDir,['tsPrctlScalos_z_' scaloMetadata.neuron]),'compact')
                
                close(h_z);
            end

        end
    end
end