% save('Canolt_comodulogram_20190122','corrMatrix_rho','corrMatrix_pval','shuff_corrMatrix_rho_mean','shuff_corrMatrix_pval',...
% 'eventFieldnames_wFake','freqList','nShuff');

function h = Canolty_comodulogram_print(corrMatrix_rho,shuff_corrMatrix_rho_mean,useSessions,...
    eventFieldnames,freqList)

doPlot_allEvents = true;
doPlot_singleEvent = false;

corrMatrix = squeeze(mean(corrMatrix_rho));
corrMatrix_shuf = squeeze(mean(shuff_corrMatrix_rho_mean));

% % % place NaNs in matrices
% % for ifp = 1:size(corrMatrix,2)
% %     for ifA = 1:size(corrMatrix,3)
% %         if ifA < ifp
% %             for iEvent = 1:size(corrMatrix,1)
% %                 corrMatrix(iEvent,ifA,ifp) = NaN;
% %                 corrMatrix_shuf(iEvent,ifA,ifp) = NaN;
% % % % % %                 shuff_MImatrix_pvals(iEvent,ifA,ifp) = NaN;
% %             end
% %         end
% %     end
% % end

if doPlot_allEvents
    fontSize = 7;
    pLims = [0 0.001];
    cLims = [-0.5 0.5];
    rows = 2;
    cols = numel(eventFieldnames);
    h = figuree(1400,500);

    for iEvent = 1:cols
        curMat = squeeze(corrMatrix(iEvent,:,:))';
        subplot(rows,cols,prc(cols,[1 iEvent]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,jet);
        set(gca,'ydir','normal');
        caxis(cLims);
        xticks(1:numel(freqList));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('amp (Hz)');
        yticks(1:numel(freqList));
        yticklabels(compose('%3.1f',freqList));
        ylabel('amp (Hz)');
        set(gca,'fontsize',fontSize);
        set(gca,'TitleFontSizeMultiplier',2);
        if iEvent == 1
            title({'mean rho',[num2str(useSessions(1)),'-',num2str(useSessions(end))],eventFieldnames{iEvent}});
        else
            title({'mean rho',eventFieldnames{iEvent}});
        end
        if iEvent == cols
            cbAside(gca,'rho','k');
        end

    % %     % note: z = norminv(alpha/N); N = # of index values
    % %     pMat = normcdf(curMat,'upper')*size(freqList{:},1).^2;
    % %     subplot(rows,cols,prc(cols,[2 iEvent]));
    % %     imagesc(pMat');
    % %     colormap(gca,magma);
    % %     set(gca,'ydir','normal');
    % %     caxis(pLims);
    % %     xticks(1:numel(freqList));
    % %     xticklabels(bandLabels(freqList(:)));
    % %     % xtickangle(270);
    % %     xlabel('phase (Hz)');
    % %     yticks(1:numel(freqList));
    % %     yticklabels(bandLabels(freqList(:)));
    % %     ylabel('amp (Hz)');
    % %     set(gca,'fontsize',fontSize);
    % %     title('mean real pval');
    % %     if iEvent == cols
    % %         cbAside(gca,'p-value','k');
    % %     end

        curMat = squeeze(corrMatrix_shuf(iEvent,:,:))';
        subplot(rows,cols,prc(cols,[2 iEvent]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,jet);
        set(gca,'ydir','normal');
        caxis(cLims);
        xticks(1:numel(freqList));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('amp (Hz)');
        yticks(1:numel(freqList));
        yticklabels(compose('%3.1f',freqList));
        ylabel('amp (Hz)');
        set(gca,'fontsize',fontSize);
        set(gca,'TitleFontSizeMultiplier',2);
        title('shuffled rho');
        if iEvent == cols
            cbAside(gca,'rho','k');
        end

    % %     pMat = squeeze(shuff_MImatrix_pvals(iEvent,:,:));
    % %     subplot(rows,cols,prc(cols,[4 iEvent]));
    % %     imagesc(1-pMat');
    % %     colormap(gca,magma);
    % %     set(gca,'ydir','normal');
    % %     caxis(pLims);
    % %     xticks(1:numel(freqList));
    % %     xticklabels(bandLabels(freqList(:)));
    % %     % xtickangle(270);
    % %     xlabel('phase (Hz)');
    % %     yticks(1:numel(freqList));
    % %     yticklabels(bandLabels(freqList(:)));
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
    cLims = [0 10];
    rows = 2;
    cols = 2;
    h = figuree(800,800);
    
    eventCount = 0;
    for iEvent = [4,8]
        eventCount = eventCount + 1;
        curMat = squeeze(corrMatrix(iEvent,:,:));
        subplot(rows,cols,prc(cols,[1 eventCount]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,parula);
        set(gca,'ydir','normal');
        caxis(cLims);
        xticks(1:numel(freqList));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
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

        curMat = squeeze(corrMatrix_shuf(iEvent,:,:));
        subplot(rows,cols,prc(cols,[2 eventCount]));
        imagesc(curMat,'AlphaData',~isnan(curMat));
        colormap(gca,parula);
        set(gca,'ydir','normal');
        caxis(cLims);
        xticks(1:numel(freqList));
        xticklabels(compose('%3.1f',freqList));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
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