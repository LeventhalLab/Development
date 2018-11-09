% load('session_20181107_PACdata.mat');

% pval for MImatrix is z-score-based
% shuff: all_shuff_MImatrix_mean, all_shuff_MImatrix_pvals

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/allSessions';
eventFieldnames_wFake = [eventFieldnames(:)' {'outTrial'}];
doMedian = true;
doPlot1 = false;
doPlot2 = true;

freqList_p = logFreqList([2 10],10);
freqList_a = logFreqList([10 200],10);
freqList = unique([freqList_p freqList_a]);

mean_MImatrix = [];
mean_MImatrix_shuff = [];
for iSession = 1:numel(all_MImatrix)
    MImatrix =  all_MImatrix{iSession};
    MImatrix_shuff =  all_shuff_MImatrix_mean{iSession};
    for iEvent = 1:numel(eventFieldnames_wFake)
        mean_MImatrix(iSession,iEvent,:,:) = MImatrix(iEvent,:,:);
        mean_MImatrix_shuff(iSession,iEvent,:,:) = MImatrix_shuff(iEvent,:,:);
    end
end

% PAC matrix
if doPlot1
    pLims = [0 0.001];
    zLims = [-50 50];
    rows = 2;
    cols = numel(eventFieldnames_wFake);
    h = figuree(1300,350);
    for iEvent = 1:numel(eventFieldnames_wFake)
        if doMedian
            curMat = squeeze(median(mean_MImatrix(:,iEvent,:,:)));
            medLabel = 'median';
        else
            curMat = squeeze(mean(mean_MImatrix(:,iEvent,:,:)));
            medLabel = 'mean';
        end
        subplot(rows,cols,prc(cols,[1 iEvent]));
        imagesc(curMat');
        colormap(gca,jet);
        set(gca,'ydir','normal');
        caxis(zLims);
        xticks(1:numel(freqList_p));
        xticklabels(num2str(freqList_p(:),'%2.1f'));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList_a));
        yticklabels(num2str(freqList_a(:),'%2.1f'));
        ylabel('amp (Hz)');
        set(gca,'fontsize',6);
        if iEvent == 1
            title({[medLabel,' real Z'],[subjectName,' s',num2str(iSession,'%02d')],eventFieldnames_wFake{iEvent}});
        else
            title({[medLabel,' real Z'],eventFieldnames_wFake{iEvent}});
        end
        if iEvent == numel(eventFieldnames_wFake)
            cbAside(gca,'Z-MI','k');
        end

    % %     % note: z = norminv(alpha/N); N = # of index values
    % %     pMat = normcdf(curMat,'upper')*numel(freqList).^2;
    % %     subplot(rows,cols,prc(cols,[2 iEvent]));
    % %     imagesc(pMat');
    % %     colormap(gca,jet);
    % %     set(gca,'ydir','normal');
    % %     caxis(pLims);
    % %     xticks(1:numel(freqList_p));
    % %     xticklabels(num2str(freqList_p(:),'%2.1f'));
    % %     xtickangle(270);
    % %     xlabel('phase (Hz)');
    % %     yticks(1:numel(freqList_a));
    % %     yticklabels(num2str(freqList_a(:),'%2.1f'));
    % %     ylabel('amp (Hz)');
    % %     set(gca,'fontsize',6);
    % %     title('mean real pval');
    % %     if iEvent == size(W,1)
    % %         cbAside(gca,'p-value','k');
    % %     end

        if doMedian
            curMat = squeeze(median(mean_MImatrix_shuff(:,iEvent,:,:)));
        else
            curMat = squeeze(mean(mean_MImatrix_shuff(:,iEvent,:,:))); 
        end
        subplot(rows,cols,prc(cols,[2 iEvent]));
        imagesc(curMat');
        colormap(gca,jet);
        set(gca,'ydir','normal');
        caxis(zLims);
        xticks(1:numel(freqList_p));
        xticklabels(num2str(freqList_p(:),'%2.1f'));
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList_a));
        yticklabels(num2str(freqList_a(:),'%2.1f'));
        ylabel('amp (Hz)');
        set(gca,'fontsize',6);
        title('mean shuff Z');
        if iEvent == numel(eventFieldnames_wFake)
            cbAside(gca,'Z-MI','k');
        end

    % %     pMat = squeeze(shuff_MImatrix_pvals(iEvent,:,:));
    % %     subplot(rows,cols,prc(cols,[4 iEvent]));
    % %     imagesc(1-pMat');
    % %     colormap(gca,jet);
    % %     set(gca,'ydir','normal');
    % %     caxis(pLims);
    % %     xticks(1:numel(freqList_p));
    % %     xticklabels(num2str(freqList_p(:),'%2.1f'));
    % %     xtickangle(270);
    % %     xlabel('phase (Hz)');
    % %     yticks(1:numel(freqList_a));
    % %     yticklabels(num2str(freqList_a(:),'%2.1f'));
    % %     ylabel('amp (Hz)');
    % %     set(gca,'fontsize',6);
    % %     title('mean shuff pval');
    % %     if iEvent == size(W,1)
    % %         cbAside(gca,'p-value','k');
    % %     end
    end
    set(gcf,'color','w');
    saveFile = ['allSessions_zscoreTrialwMixed_',medLabel,'.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end

% line plot
if doPlot2
    compiled_pvals_beta = [];
    compiled_pvals_gamma = [];
    ifp_1 = closest(freqList_p,2);
    ifp_2 = closest(freqList_p,4);
    ifA_beta = closest(freqList_a,20);
    ifA_gamma = closest(freqList_a,50);
    for iSession = 1:size(mean_MImatrix,1)
        for iEvent = 1:numel(eventFieldnames_wFake)
            curMat = squeeze(mean_MImatrix(iSession,iEvent,:,:));
            pMat = normcdf(curMat,'upper')*numel(freqList).^2;
            compiled_pvals_beta(iSession,iEvent) = mean(pMat(ifp_1:ifp_2,ifA_beta));
            compiled_pvals_gamma(iSession,iEvent) = mean(pMat(ifp_1:ifp_2,ifA_gamma));
        end
    end
    
    colors = linesUM(2);
    h = ff(400,300);
    pThresh = 0.001;
    pval_bar_beta = sum(compiled_pvals_beta < pThresh) ./ size(mean_MImatrix,1);
    pval_bar_gamma = sum(compiled_pvals_gamma < pThresh) ./ size(mean_MImatrix,1);
    hb = bar([pval_bar_beta' pval_bar_gamma']);
    hb(1).FaceColor = colors(1,:);
    hb(2).FaceColor = colors(2,:);
    xticklabels(eventFieldnames_wFake);
    xtickangle(30);
    ylabel(['Frac. of Sessions < ',num2str(pThresh,2)]);
    ylim([0 1]);
    yticks(ylim);
    legend('\delta x \beta','\delta x \gamma');

    set(gcf,'color','w');
    saveFile = ['allSessions_frac_pval_',medLabel,'.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end


if false
    zs = linspace(3,5,100);
    ys = normcdf(zs,'upper')*numel(freqList).^2;
    ff(400,400);
    plot(zs,ys);
    ylabel('p-value');
    xlabel('Z-score');
    grid on;
end