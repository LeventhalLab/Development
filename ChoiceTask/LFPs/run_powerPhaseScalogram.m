savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PACreports';
doSave = true;
for iSubject = 2:5
    % setup (load one data set)
    if true
        run_loadData; % size(allW) = (7,9766,94,18)
    end

    pVal = 0.05;
    cols = 7;
    rows = 5;
    vis_tWindow = 1;
    t1Idx = closest(t,-vis_tWindow);
    t2Idx = closest(t,vis_tWindow);
    t_vis = linspace(-vis_tWindow,vis_tWindow,numel(t1Idx:t2Idx));
    colors = lines(2);

    h = figuree(1200,rows*200);
    
    for iEvent = 1:7
        cur_power = squeeze(mean(abs(squeeze(allW(iEvent,t1Idx:t2Idx,:,:))),2))'; % power -> mean all trials
        cur_phase = squeeze(circ_mean(angle(squeeze(allW(iEvent,:,:,:))),[],2))';
        
        % POWER
        iSubplot = prc(cols,[1 iEvent]);
        ax = subplot(rows,cols,iSubplot);
        imagesc(t_vis,1:numel(freqList),cur_power);
        xlim([-vis_tWindow vis_tWindow]);
        xticks([-vis_tWindow 0 vis_tWindow]);
        yticks(1:numel(freqList));
        yticklabels(freqList);
        set(ax,'YDir','normal');
        colormap(ax,jet);
        grid on;
        
        if iEvent == 1
            title({[subject__names{iSubject}],eventFieldnames{iEvent},'Power'});
            ylabel('freq (Hz)');
        else
            title({eventFieldnames{iEvent},'Power'});
        end
        
        if iEvent == 4
            caxisVals = caxis;
        end
        
        if iEvent == 7
            hb = colorbar('location','eastoutside');
            refPos = get(axRef,'position');
            curPos = get(ax,'position');
            curPos(3:4) = refPos(3:4);
            set(ax,'position',curPos);
            
            caxis(caxisVals);
            for iCol = 1:cols-1
                iSubplot = prc(cols,[1 iCol]);
                subplot(rows,cols,iSubplot);
                caxis(caxisVals);
            end
        else
            axRef = ax;
        end
        drawnow;
        
        % PHASE
        iSubplot = prc(cols,[2 iEvent]);
        ax = subplot(rows,cols,iSubplot);
        imagesc(t_vis,1:numel(freqList),cur_phase);
        xlim([-vis_tWindow vis_tWindow]);
        xticks([-vis_tWindow 0 vis_tWindow]);
        yticks(1:numel(freqList));
        yticklabels(freqList);
        set(ax,'YDir','normal');
        cmocean('phase');
        grid on;
        
        title('Phase');
        
        if iEvent == 7
            hb = colorbar('location','eastoutside');
            refPos = get(axRef,'position');
            curPos = get(ax,'position');
            curPos(3:4) = refPos(3:4);
            set(ax,'position',curPos);
        end
        drawnow;
        
        % MRL
        all_rs = [];
        all_ps = [];
        allTrial_cur_phase = angle(squeeze(allW(iEvent,t1Idx:t2Idx,:,:)));
        for iFreq = 1:size(allTrial_cur_phase,3)
            for iTs = 1:size(allTrial_cur_phase,1)
                trial_phases = squeeze(allTrial_cur_phase(iTs,:,iFreq))';
                all_rs(iFreq,iTs) = circ_r(trial_phases);
                all_ps(iFreq,iTs) = circ_rtest(trial_phases);
            end
        end
        iSubplot = prc(cols,[3 iEvent]);
        ax = subplot(rows,cols,iSubplot);
        imagesc(t_vis,1:numel(freqList),all_rs);
        xlim([-vis_tWindow vis_tWindow]);
        xticks([-vis_tWindow 0 vis_tWindow]);
        yticks(1:numel(freqList));
        yticklabels(freqList);
        set(ax,'YDir','normal');
        colormap(ax,hot);
        caxis([0 0.6]);
        grid on;
        
        title('MRL');
        
        if iEvent == 7
            hb = colorbar('location','eastoutside');
            refPos = get(axRef,'position');
            curPos = get(ax,'position');
            curPos(3:4) = refPos(3:4);
            set(ax,'position',curPos);
        end
        
        % MRL p < pVal
        iSubplot = prc(cols,[4 iEvent]);
        ax = subplot(rows,cols,iSubplot);
        all_rs_pVal = all_rs;
        all_rs_pVal(all_ps >= pVal) = 0;
        imagesc(t_vis,1:numel(freqList),all_rs_pVal);
        xlim([-vis_tWindow vis_tWindow]);
        xticks([-vis_tWindow 0 vis_tWindow]);
        yticks(1:numel(freqList));
        yticklabels(freqList);
        set(ax,'YDir','normal');
        colormap(ax,hot);
        caxis([0 0.6]);
        grid on;
        
        title(['MRL p < ',num2str(pVal,'%1.2f')]);
        
        if iEvent == 7
            hb = colorbar('location','eastoutside');
            refPos = get(axRef,'position');
            curPos = get(ax,'position');
            curPos(3:4) = refPos(3:4);
            set(ax,'position',curPos);
        end
        
        % PVAL
        iSubplot = prc(cols,[5 iEvent]);
        ax = subplot(rows,cols,iSubplot);
        imagesc(t_vis,1:numel(freqList),all_ps);
        xlim([-vis_tWindow vis_tWindow]);
        xticks([-vis_tWindow 0 vis_tWindow]);
        yticks(1:numel(freqList));
        yticklabels(freqList);
        set(ax,'YDir','normal');
        colormap(ax,cool);
        caxis([0 1]);
        grid on;
        
        title('p-value');
        
        if iEvent == 7
            hb = colorbar('location','eastoutside');
            refPos = get(axRef,'position');
            curPos = get(ax,'position');
            curPos(3:4) = refPos(3:4);
            set(ax,'position',curPos);
        end
        
        xlabel('time (s)');
        
        drawnow;
    end
    set(gcf,'color','w');
end