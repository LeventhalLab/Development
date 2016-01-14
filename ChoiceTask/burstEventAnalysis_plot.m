function burstEventAnalysis_plot(sessionConf)
    % any session conf from the rat of interest will work
    
    saveRows = 4;
    burstFiles = rdir(fullfile(sessionConf.nasPath,sessionConf.ratID,[sessionConf.ratID,'-graphs'],'*','burstEventAnalysis','*burstEvents.mat'));
    plotEventIdx = [1 2 4 3 5 6 8]; % removed foodClick becaue it mirrors SideIn

    fileNames = {burstFiles.name};
    fileIds = listdlg('PromptString','Select neurons:',...
                    'SelectionMode','multiple','ListSize',[900 700],...
                    'ListString',fileNames);

    for iFile=1:length(fileIds)
        disp([burstFiles(fileIds(iFile)).name]);
        load(burstFiles(fileIds(iFile)).name);
        
        if ~exist('zTs','var')
            error('Missing vars, update mat file by running burstEventAnalysis on the sessionConf');
        end
        
        fontSize = 6;
        if mod(iFile,saveRows) == 1
            if exist('fig','var')
                saveFigure(sessionConf,fig);
                clear fig;
            end
            fig = formatSheet();
            iSubplot = 1;
        end

        for iEvent=1:length(plotEventIdx)
            iField = plotEventIdx(iEvent);
            subplot(saveRows,7,iSubplot);

            % anaylsis on zscores
            ax = plotyy(tsCenters,zTs(:,plotEventIdx(iEvent)),tsCenters,zBurstTs(:,plotEventIdx(iEvent)));
            set(ax,'FontSize',fontSize);
            xlabel('Time (s)','FontSize',fontSize);
            ylabel('Z','FontSize',fontSize);
            set(ax(1),'ylim',[floor(min(min(zTs))) ceil(max(max(zTs)))]);
            set(ax(1),'ytick',[floor(min(min(zTs))):ceil(max(max(zTs)))])
            set(ax(2),'ylim',[floor(min(min(zBurstTs))) ceil(max(max(zBurstTs)))]);
            set(ax(2),'ytick',[floor(min(min(zBurstTs))):ceil(max(max(zBurstTs)))]);
            if iFile==1 && iEvent==1
                legend('all spikes','burst spikes','location','northwest','FontSize',fontSize);
            end
            
            title({strrep(neuronName,'_','-'),eventFieldnames{iField}},'FontSize',fontSize);
            iSubplot = iSubplot + 1;
        end
    end
    
    if exist('fig','var')
        saveFigure(sessionConf,fig);
        clear fig;
    end
end

function saveFigure(sessionConf,fig)
    disp('Saving...');
    saveas(fig,fullfile(sessionConf.nasPath,sessionConf.ratID,[sessionConf.ratID,'-graphs'],...
                ['burstEventAnalysis_',datestr(now,'yyyymmdd-HHMMSS')]),'pdf');
    close(fig);
end