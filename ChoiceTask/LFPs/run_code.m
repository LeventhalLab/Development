ifp = 3;
    ifA = 17;
    MI_bars = [];
    h = figuree(1400,500);
    rows = 2;
    cols = 7;
    freqLabels = num2str(freqList(:),'%2.1f');
    for iEvent = 1:size(all_MImatrix,2)
        subplot(rows,cols,prc(cols,[1 iEvent]));
        curMat = squeeze(nanmean(squeeze(all_MImatrix(:,iEvent,:,:)))) - squeeze(nanmean(squeeze(all_MImatrix_surr(:,iEvent,:,:))));
        MI_bars(iEvent) = curMat(ifp,ifA);
        imagesc(curMat');
        colormap(jet);
        set(gca,'ydir','normal');
        caxis([-0.01 0.05]);
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(90);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        ylabel('amp (Hz)');
        title({'',eventFieldnames{iEvent}});
        if iEvent == 7
            cb = cbAside(gca,'MI - baseline','k');
        end

        subplot(rows,cols,prc(cols,[2 iEvent]));
% %         for iSession = 1:size(all_MImatrix,1)
% %             plot(squeeze(all_MImatrix(iSession,iEvent,ifp,:)) - squeeze(nanmean(squeeze(all_MImatrix_surr(:,iEvent,ifp,:)))),'color',repmat(.8,[1,3]));
% %             hold on;
% %         end
        plot(curMat(ifp,:),'k');
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(90);
        ylim([-0.01 0.05]);
        yticks(sort([0,ylim]));
        ylabel('MI - baseline');
        title(['phase: ',num2str(freqList(ifp))]);
    end

    figuree(400,400);
    bar(MI_bars,'k');
    xticks(1:7);
    xticklabels(eventFieldnames);
    xtickangle(90);
    ylim([-0.01 0.05]);
    yticks(sort([0,ylim]));
    ylabel('MI - baseline');
    title(['phase: ',num2str(freqList(ifp)),', amp: ',num2str(freqList(ifA))]);