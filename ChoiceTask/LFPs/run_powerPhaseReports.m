% setup (load one data set)
if false
    run_loadData;
end
% size(allW) = (7,9766,94,18)

cols = 7;
rows = 2;
vis_tWindow = 1;
t1Idx = closest(t,-vis_tWindow);
t2Idx = closest(t,vis_tWindow);
t_vis = linspace(-vis_tWindow,vis_tWindow,numel(t1Idx:t2Idx));
colors = lines(2);

% run one report per frequency band
for iFreq = 12%:numel(freqList)
    curFreq = freqList(iFreq);
    disp(['Working on ',num2str(curFreq),' Hz']);
    
    figuree(1200,400);

    curData = squeeze(allW(:,:,:,iFreq));
    curPower = abs(curData);
    curPhase = angle(curData);

    % POWER
    all_ylims = [];
    subplot_ps = [];
    iRow = 1;
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
        all_ylims(iEvent,:) = ylim;
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
        
        if iEvent == 1
            title({[num2str(curFreq),' Hz'],eventFieldnames{iEvent}});
        else
            title(eventFieldnames{iEvent});
        end
    end
    rescale_y(rows,cols,subplot_ps,all_ylims);
    
    % PHASE
    iRow = 2;
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
    end
    
    % PHASE-AMPLITUDE COUPLING
    lowFreqIdx = 1;
    [SI_mag,SI_phase] = synchronizationIndex(allW,t,vis_tWindow,iEvent,lowFreqIdx);
    
    figure;
    imagesc(t_vis,1:numel(freqList),SI_mag);
    yticks(1:numel(freqList));
    yticklabels(freqList);
    set(gca,'Ydir','normal');
    colormap(jet);
    colorbar;
    caxis([0 1]);
    xlabel('time (s)');
    ylabel('freq (Hz)');
    
end