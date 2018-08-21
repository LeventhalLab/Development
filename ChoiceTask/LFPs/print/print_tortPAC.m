doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMTcorr';

corrMat_pval = ones(numel(freqList),numel(freqList));
corrMat_rho = ones(numel(freqList),numel(freqList));

rows = 3;
cols = 7;
freqLabels = num2str(freqList(:),'%2.1f');

for iSession = 1:numel(selectedLFPFiles)
    h = figuree(1400,500);
    for iEvent = 1:7
        cur_MIMatrix = squeeze(session_MIMatrix_byMT{iSession}(iEvent,:,:,:));
        cur_Times = MImatrix_MT{iSession};
        corrMat_pval = [];
        corrMat_rho = [];
        for ifp = 1:numel(freqList)
            for ifA = ifp:numel(freqList)
                corr_x = squeeze(cur_MIMatrix(:,ifp,ifA));
                corr_y = cur_Times;
                [rho,pval] = corr(corr_x,corr_y');
                corrMat_pval(ifp,ifA) = pval;
                corrMat_rho(ifp,ifA) = rho;
            end
        end

        subplot(rows,cols,prc(cols,[1,iEvent]));
        imagesc(corrMat_pval');
        set(gca,'ydir','normal');
        colormap(gca,hot);
        caxis([0 1]);
        cbAside(gca,'pval','k');
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(90);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        ylabel('amp (Hz)');
        title({eventFieldnames{iEvent},'pval'});
        set(gca,'fontsize',6);

        subplot(rows,cols,prc(cols,[2,iEvent]));
        imagesc(corrMat_rho');
        set(gca,'ydir','normal');
        colormap(gca,jet);
        caxis([0 0.25]);
        cbAside(gca,'rho','k');
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(90);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        ylabel('amp (Hz)');
        set(gca,'fontsize',6);
        title('rho');

        subplot(rows,cols,prc(cols,[3,iEvent]));
        showMat = corrMat_rho;
        showMat(corrMat_pval >= 0.05) = 0;
        imagesc(showMat');
        set(gca,'ydir','normal');
        colormap(gca,jet);
        caxis([0 0.25]);
        cbAside(gca,'rho','k');
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(90);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        ylabel('amp (Hz)');
        title('rho, p < 0.05');
        set(gca,'fontsize',6);
    end
    
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,[num2str(iSession,'%02d'),'_tortMhoTcorr.png']));
        close(h);
    end
end