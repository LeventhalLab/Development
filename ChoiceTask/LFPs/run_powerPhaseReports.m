savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PACreports';
doSave = true;
for iSubject = 2:4
    % setup (load one data set)
    if true
        run_loadData; % size(allW) = (7,9766,94,18)
    end

    cols = 7;
    rows = 4;
    vis_tWindow = 1;
    t1Idx = closest(t,-vis_tWindow);
    t2Idx = closest(t,vis_tWindow);
    t_vis = linspace(-vis_tWindow,vis_tWindow,numel(t1Idx:t2Idx));
    colors = lines(2);

    % run one report per frequency band
    for iFreq = 1:numel(freqList)
        curFreq = freqList(iFreq);
        disp(['Working on ',num2str(curFreq),' Hz']);

        h = figuree(1200,rows*200);

        curData = squeeze(allW(:,:,:,iFreq));
        curPower = abs(curData);
        curPhase = angle(curData);

        % POWER
        for iRow = 1:2
            if iRow == 1
                vis_tWindow = 1;
                all_ylims = [];
            else
                vis_tWindow = 0.1;
            end
            subplot_ps = [];
            for iEvent = 1:7
                iSubplot = prc(cols,[iRow iEvent]);
                subplot_ps(iEvent) = iSubplot;
                subplot(rows,cols,iSubplot);
                eventPower = squeeze(curPower(iEvent,:,:));
                eventPhase = squeeze(curPhase(iEvent,:,:));

                yyaxis left;
                shadedErrorBar(t,mean(eventPower,2)',std(eventPower,0,2)',{'-','color',colors(1,:)},1);
                xlim([-vis_tWindow vis_tWindow]);
                xticks([-vis_tWindow 0 vis_tWindow]);
                xlabel('time (s)');
                if iRow == 1
                    all_ylims(iEvent,:) = ylim;
                end
                ylabel('power');

                yyaxis right;
                all_rs = [];
                for ti = 1:size(eventPhase,1)
                     r = circ_r(eventPhase(ti,:)');
                    all_rs(ti) = r;
                end
                plot(t,all_rs);
                ylabel('MRL');
                ylimVals = [0 1];
                ylim(ylimVals);
                yticks(ylimVals);

                grid on;

                if iEvent == 1 && iRow == 1
                    title({[num2str(curFreq),' Hz'],eventFieldnames{iEvent}});
                elseif iRow == 1
                    title(eventFieldnames{iEvent});
                end

                drawnow;
            end
            rescale_y(rows,cols,subplot_ps,all_ylims);
        end

        % PHASE
        for iRow = 3:4
            if iRow == 3
                vis_tWindow = 1;
            else
                vis_tWindow = 0.1;
            end
            for iEvent = 1:7
                iSubplot = prc(cols,[iRow iEvent]);
                subplot(rows,cols,iSubplot);
                eventPhase = squeeze(curPhase(iEvent,:,:));

                yyaxis left;
                shadedErrorBar(t,circ_mean(eventPhase')',circ_std(eventPhase')',{'-','color',colors(1,:)},1);
                xlim([-vis_tWindow vis_tWindow]);
                xticks([-vis_tWindow 0 vis_tWindow]);
                xlabel('time (s)');
                ylim([-5 5]);
                yticks(sort([ylim 0]));
                ylabel('phase (rad)');

                yyaxis right;
                all_ps = [];
                for ti = 1:size(eventPhase,1)
                     p = circ_rtest(eventPhase(ti,:));
                    all_ps(ti) = p;
                end
                plot(t,all_ps);
                ylabel('p (r-test)');
                ylimVals = [0 1];
                ylim(ylimVals);
                yticks(ylimVals);
                grid on;

                drawnow;
            end
        end

        if false
            % PHASE-AMPLITUDE COUPLING
            if iFreq < numel(freqList) % no PAC for highest frequency
                for iEvent = 1:7
                    iSubplot = prc(cols,[3 iEvent]);
                    ax = subplot(rows,cols,iSubplot);
                    [SI_mag,SI_phase] = synchronizationIndex(allW,t,vis_tWindow,iEvent,iFreq);

                    imagesc(t_vis,1:numel(freqList),SI_mag);
                    yLims = ylim;
                    yVals = linspace(yLims(1),yLims(2),size(SI_mag,1)*2+1);
                    yticks(yVals(2:2:end));
                    yticklabels(freqList(iFreq+1:end));
                    set(gca,'Ydir','normal');
                    colormap(jet);
                    caxis([0 0.2]);
                    xlabel('time (s)');
                    ylabel('freq (Hz)');
                    title('SI_m');
                    if iEvent == 7
                        hb = colorbar('location','eastoutside');
                        refPos = get(axRef,'position');
                        curPos = get(ax,'position');
                        curPos(3:4) = refPos(3:4);
                        set(ax,'position',curPos);
                    else
                        axRef = ax;
                    end
                    drawnow;

                    iSubplot = prc(cols,[4 iEvent]);
                    ax = subplot(rows,cols,iSubplot);
                    imagesc(t_vis,1:numel(freqList),SI_phase);
                    yLims = ylim;
                    yVals = linspace(yLims(1),yLims(2),size(SI_mag,1)*2+1);
                    yticks(yVals(2:2:end));
                    yticklabels(freqList(iFreq+1:end));
                    set(gca,'Ydir','normal');
                    cmocean('phase');
                    caxis([-pi pi]);
                    xlabel('time (s)');
                    ylabel('freq (Hz)');
                    title('SI_p');
                    if iEvent == 7
                        hb = colorbar('location','eastoutside');
                        refPos = get(axRef,'position');
                        curPos = get(ax,'position');
                        curPos(3:4) = refPos(3:4);
                        set(ax,'position',curPos);
                    end
                    drawnow;
                end
            end
        end
        set(gcf,'color','w');
        if doSave
            filename = [subject__names{iSubject},'_PAC_',num2str(curFreq),'Hz'];
            saveas(h,fullfile(savePath,[filename,'.fig']));
            saveas(h,fullfile(savePath,[filename,'.png']));
            close(h);
        end
    end
end