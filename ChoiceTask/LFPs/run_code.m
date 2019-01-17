h = ff(1400,500);
rows = 3;
cols = 7;
acorCaxis = [-500 1500];
useData = {all_A,all_A_shuffled_mean};

for iEvent = 1:7
    for iShuffle = 1:2
        subplot(rows,cols,prc(cols,[iShuffle,iEvent]));
        imagesc(lag,1:numel(freqList),squeeze(mean(useData{iShuffle}(:,iEvent,:,:))));
        hold on;
        plot([0,0],ylim,'k:');
        set(gca,'ydir','normal');
        xlabel('spike lag (ms)');
        yticks(linspace(min(ylim),max(ylim),numel(freqList)));
        yticklabels(compose('%3.1f',freqList));
        colormap(gca,jet);
        caxis(acorCaxis);
        ax = gca;
        ax.YAxis.FontSize = 7;
        if iShuffle == 1
            if iEvent == 1
                ylabel('Freq (Hz)');
                title({eventFieldnames{iEvent},'mean xcorr'});
            else
                title({eventFieldnames{iEvent},'mean xcorr'});
            end
        else
            title('mean xcorr_{shuffle}');
        end
        if iEvent == 7
            cbAside(gca,'acor','k');
        end
    end
    
    subplot(rows,cols,prc(cols,[3,iEvent]));
    imagesc(lag,1:numel(freqList),squeeze(mean(all_shuff_pvals(:,iEvent,:,:))));
    hold on;
    plot([0,0],ylim,'k:');
    set(gca,'ydir','normal');
    xlabel('spike lag (ms)');
    yticks(linspace(min(ylim),max(ylim),numel(freqList)));
    yticklabels(compose('%3.1f',freqList));
    colormap(gca,jupiter);
    caxis([-1 1]);
    ax = gca;
    ax.YAxis.FontSize = 7;
    title(['shuff (x',num2str(nShuffle),')']);
    if iEvent == 7
        cbAside(gca,'pval','k');
    end
end
set(gcf,'color','w');