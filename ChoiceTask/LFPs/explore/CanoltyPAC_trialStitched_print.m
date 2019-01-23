function h = CanoltyPAC_trialStitched_print(all_MImatrix,all_shuff_MImatrix_mean,all_shuff_MImatrix_pvals,useSessions,...
    eventFieldnames,freqList_p,freqList_a,freqList)

doPlot_allEvents = false;
doPlot_singleEvent = true;

if numel(useSessions) == 1
    MImatrix = all_MImatrix{useSessions};
    shuff_MImatrix_mean = all_shuff_MImatrix_mean{useSessions};
    shuff_MImatrix_pvals = all_shuff_MImatrix_pvals{useSessions};
else
    t = [];
    u = [];
    v = [];
    for iSession = 1:numel(useSessions)
        t(iSession,:,:,:) = all_MImatrix{useSessions(iSession)};
        u(iSession,:,:,:) = all_shuff_MImatrix_mean{useSessions(iSession)};
        v(iSession,:,:,:) = all_shuff_MImatrix_pvals{useSessions(iSession)};
    end
    MImatrix = squeeze(median(t));
    shuff_MImatrix_mean = squeeze(median(u));
    shuff_MImatrix_pvals = squeeze(median(v));
end

t = [];
u = [];
v = [];
for ifp = 1:size(MImatrix,2)
    for ifA = 1:size(MImatrix,3)
        for iEvent = 1:size(MImatrix,1)
            t(iEvent,ifA,ifp) = MImatrix(iEvent,ifp,ifA);
            u(iEvent,ifA,ifp) = shuff_MImatrix_mean(iEvent,ifp,ifA);
            v(iEvent,ifA,ifp) = shuff_MImatrix_pvals(iEvent,ifp,ifA);
        end
    end
end

MImatrix = squeeze((t));
shuff_MImatrix_mean = squeeze((u));
shuff_MImatrix_pvals = squeeze((v));

% place NaNs in matrices
for ifp = 1:size(MImatrix,2)
    for ifA = 1:size(MImatrix,3)
        if ifA < ifp
            for iEvent = 1:size(MImatrix,1)
                MImatrix(iEvent,ifA,ifp) = NaN;
                shuff_MImatrix_mean(iEvent,ifA,ifp) = NaN;
                shuff_MImatrix_pvals(iEvent,ifA,ifp) = NaN;
            end
        end
    end
end

if doPlot_allEvents
    fontSize = 7;
    pLims = [0 0.001];
    zLims = [0 10];
    rows = 2;
    cols = numel(eventFieldnames);
    h = figuree(1400,500);

    for iEvent = 1:cols
        curMat = squeeze(MImatrix(iEvent,:,:));
        subplot(rows,cols,prc(cols,[1 iEvent]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,parula);
        set(gca,'ydir','normal');
        caxis(zLims);
        xticks(1:numel(freqList_p));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList_a));
        yticklabels(compose('%3.1f',freqList));
        ylabel('amp (Hz)');
        set(gca,'fontsize',fontSize);
        set(gca,'TitleFontSizeMultiplier',2);
        if iEvent == 1
            title({'mean real Z',[num2str(useSessions(1)),'-',num2str(useSessions(end))],eventFieldnames{iEvent}});
        else
            title({'mean real Z',eventFieldnames{iEvent}});
        end
        if iEvent == cols
            cbAside(gca,'Z-MI','k');
        end

    % %     % note: z = norminv(alpha/N); N = # of index values
    % %     pMat = normcdf(curMat,'upper')*size(freqList{:},1).^2;
    % %     subplot(rows,cols,prc(cols,[2 iEvent]));
    % %     imagesc(pMat');
    % %     colormap(gca,magma);
    % %     set(gca,'ydir','normal');
    % %     caxis(pLims);
    % %     xticks(1:numel(freqList_p));
    % %     xticklabels(bandLabels(freqList_p(:)));
    % %     % xtickangle(270);
    % %     xlabel('phase (Hz)');
    % %     yticks(1:numel(freqList_a));
    % %     yticklabels(bandLabels(freqList_a(:)));
    % %     ylabel('amp (Hz)');
    % %     set(gca,'fontsize',fontSize);
    % %     title('mean real pval');
    % %     if iEvent == cols
    % %         cbAside(gca,'p-value','k');
    % %     end

        curMat = squeeze(shuff_MImatrix_mean(iEvent,:,:));
        subplot(rows,cols,prc(cols,[2 iEvent]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,parula);
        set(gca,'ydir','normal');
        caxis(zLims);
        xticks(1:numel(freqList_p));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList_a));
        yticklabels(compose('%3.1f',freqList));
        ylabel('amp (Hz)');
        set(gca,'fontsize',fontSize);
        set(gca,'TitleFontSizeMultiplier',2);
        title('mean shuff Z');
        if iEvent == cols
            cbAside(gca,'Z-MI','k');
        end

    % %     pMat = squeeze(shuff_MImatrix_pvals(iEvent,:,:));
    % %     subplot(rows,cols,prc(cols,[4 iEvent]));
    % %     imagesc(1-pMat');
    % %     colormap(gca,magma);
    % %     set(gca,'ydir','normal');
    % %     caxis(pLims);
    % %     xticks(1:numel(freqList_p));
    % %     xticklabels(bandLabels(freqList_p(:)));
    % %     % xtickangle(270);
    % %     xlabel('phase (Hz)');
    % %     yticks(1:numel(freqList_a));
    % %     yticklabels(bandLabels(freqList_a(:)));
    % %     ylabel('amp (Hz)');
    % %     set(gca,'fontsize',fontSize);
    % %     title('mean shuff pval');
    % %     if iEvent == cols
    % %         cbAside(gca,'p-value','k');
    % %     end
    end

    set(gcf,'color','w');
    drawnow;
end

if doPlot_singleEvent
    fontSize = 10;
    zLims = [0 10];
    rows = 2;
    cols = 2;
    h = figuree(800,800);
    
    eventCount = 0;
    for iEvent = [4,8]
        eventCount = eventCount + 1;
        curMat = squeeze(MImatrix(iEvent,:,:));
        subplot(rows,cols,prc(cols,[1 eventCount]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,parula);
        set(gca,'ydir','normal');
        caxis(zLims);
        xticks(1:numel(freqList_p));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList_a));
        yticklabels(compose('%3.1f',freqList));
        ylabel('amp (Hz)');
        set(gca,'fontsize',fontSize);
        set(gca,'TitleFontSizeMultiplier',2);
        if iEvent == 1
            title({'mean real Z',[num2str(useSessions(1)),'-',num2str(useSessions(end))],eventFieldnames{iEvent}});
        else
            title({'mean real Z',eventFieldnames{iEvent}});
        end
        if iEvent == cols
            cbAside(gca,'Z-MI','k');
        end

        curMat = squeeze(shuff_MImatrix_mean(iEvent,:,:));
        subplot(rows,cols,prc(cols,[2 eventCount]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,parula);
        set(gca,'ydir','normal');
        caxis(zLims);
        xticks(1:numel(freqList_p));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList_a));
        yticklabels(compose('%3.1f',freqList));
        ylabel('amp (Hz)');
        set(gca,'fontsize',fontSize);
        set(gca,'TitleFontSizeMultiplier',2);
        title('mean shuff Z');
        if iEvent == cols
            cbAside(gca,'Z-MI','k');
        end
    end

    set(gcf,'color','w');
    drawnow;
end