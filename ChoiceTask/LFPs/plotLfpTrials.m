function plotLfpTrials(allLfp,t,vis_tWindow,n,eventFieldnames)

t1Idx = closest(t,-vis_tWindow);
t2Idx = closest(t,vis_tWindow);
t_vis = linspace(-vis_tWindow,vis_tWindow,numel(t1Idx:t2Idx));
ylimVals = [-500 500];

useTrials = unique(round(linspace(1,size(allLfp,3),n)));
rows = numel(useTrials);
cols = 7;

figuree(1200,80*rows);
curRow = 1;
for iTrial = useTrials
    for iEvent = 1:cols
        iSubplot = prc(cols,[curRow iEvent]);
        ax = subplot(rows,cols,iSubplot);
        curLfp = squeeze(squeeze(allLfp(iEvent,t1Idx:t2Idx,iTrial)));
        curLfp = curLfp - mean(curLfp); % detrend
        plot(t_vis,curLfp);
        xlabel('time (s)');
        xticks([-vis_tWindow 0 vis_tWindow]);
        xticklabels({num2str(-vis_tWindow),'',num2str(vis_tWindow)});
        ylim(ylimVals);
        yticks([]);
        if iEvent == 1
            ylabel('uV');
            yticks(sort([ylimVals 0]));
        end
        if curRow == 1
            title({eventFieldnames{iEvent},['trial ',num2str(iTrial)]});
        else
            title(['trial ',num2str(iTrial)])
        end
        grid on;
    end
    curRow = curRow + 1;
end
tightfig;