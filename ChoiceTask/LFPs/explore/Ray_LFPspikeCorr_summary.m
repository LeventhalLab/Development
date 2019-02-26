% load('20190121_RayLFP_compiled.mat')
% load('20190220_RayLFP_compiled.mat')

% close all

freqList = logFreqList([1 200],30);
eventFieldnames_wFake = {eventFieldnames{:} 'Inter-trial'};
nShuffle = 1000;

doPlots_dirSelSignifiance = true;
doPlots_spectrum = false;
doPlot_fractionBands = false;
doPlot_meanBands = false;
doPlot_meanHeatmaps = false;

if doPlots_dirSelSignifiance
    units_dirSel = ismember(unitLookup,dirSelUnitIds);
    units_ndirSel = ismember(unitLookup,ndirSelUnitIds);
    nShuffle = 1000;
    if false
        pval_mat = [];
        for iDirSel = 1:2
            if iDirSel == 1
                unitSel = find(ismember(unitLookup,dirSelUnitIds));
            else
                unitSel = find(ismember(unitLookup,ndirSelUnitIds));
            end
            for iEvent = 1:8
                for iFreq = 1:30
                    real_acor = mean(squeeze(all_acors(unitSel,iEvent,iFreq,:)));
                    for iShuffle = 1:nShuffle
                        randSel = randsample(1:size(all_acors,1),numel(unitSel));
                        shuff_acor(iShuffle,:) = mean(squeeze(all_acors(randSel,iEvent,iFreq,:)));
                    end
                    pvals = sum(shuff_acor > real_acor) / nShuffle;
                    pval_mat(iDirSel,iEvent,iFreq,:) = pvals;
                end
            end
        end
    end
    % plot
%     pval_thresh(iDirSel,iEvent,iFreq,:) = pvals < pThresh | pvals > 1 - pThresh;
    dirSelTypes = {'dirSel','ndirSel'};
    rows = 4;
    cols = 8 ;
    tWindow = 0.5;
    pThresh = 0.05;
    SE = strel('sphere',1);
    pxThresh = 1;
    lineWidth = 1.5;
    t = linspace(-tWindow,tWindow,size(all_acors,4));
    fontSize = 6;
    h = ff(1400,800);
    for iDirSel = 1:2
        if iDirSel == 1
            unitSel = find(ismember(unitLookup,dirSelUnitIds));
        else
            unitSel = find(ismember(unitLookup,ndirSelUnitIds));
        end
        for iEvent = 1:8
            % real xcorr with circled p-values
            real_acor = squeeze(mean(all_acors(unitSel,iEvent,:,:)));
            subplot(rows,cols,prc(cols,[iDirSel*2-1,iEvent]));
            imagesc(t,1:numel(freqList),real_acor);
            hold on;
            plot([0,0],ylim,'k:');
            colormap(gca,parula);
            caxis([-.1 .1]);
            set(gca,'ydir','normal');
            xticks([-tWindow,0,tWindow]);
            xlabel('spike lag (s)');
            yticks(1:numel(freqList_a));
            yticklabels(compose('%3.1f',freqList));
            ylabel('Freq (Hz)');
            set(gca,'fontsize',fontSize);
            set(gca,'TitleFontSizeMultiplier',2);
            if iDirSel == 1
                title({'xcorr',eventFieldnames_wFake{iEvent},dirSelTypes{iDirSel}});
            else
                title(dirSelTypes{iDirSel});
            end
            if iEvent == 8
                cbAside(gca,'r (xcorr)','k');
            end
            
            pval_colors = ['r','b'];
            for iPval = 1:2
                pvals = squeeze(pval_mat(iDirSel,iEvent,:,:));
%                 pMat_thresh = pvals < pThresh | pvals > 1 - pThresh;
                if iPval == 1
                    pMat_thresh = pvals < pThresh;
                else
                    pMat_thresh = pvals > 1 - pThresh;
                end
                pMat_dilated = imdilate(pMat_thresh,SE);
                pMat_filled = imfill(pMat_dilated,'holes');
                B = bwboundaries(pMat_filled);
                stats = regionprops(pMat_thresh,'MajorAxisLength','MinorAxisLength');
                for k = 1:length(B)
                    if stats(k).MajorAxisLength > pxThresh && stats(k).MinorAxisLength > pxThresh
                        b = B{k};
                        plot(t(b(:,2)),b(:,1),pval_colors(iPval),'linewidth',lineWidth);
                    end
                end
            end
            
            % shuffled trial p-values
            pvalMat = squeeze(mean(all_shuff_pvals(unitSel,iEvent,:,:)));
            subplot(rows,cols,prc(cols,[iDirSel*2,iEvent]));
            imagesc(t,1:numel(freqList),pvalMat);
            hold on;
            plot([0,0],ylim,'k:');
            set(gca,'ydir','normal');
            xlabel('spike lag (s)');
            yticks(linspace(min(ylim),max(ylim),numel(freqList)));
            yticklabels(compose('%3.1f',freqList));
            colormap(gca,jupiter);
            caxis([-1 1]);
            set(gca,'fontsize',fontSize);
            title('shuffle p-value');
            if iEvent == 8
                cb = cbAside(gca,'pval','k');
                cb.Ticks = sort([caxis,0]);
                cb.TickLabels = {'0 (+)','1','0 (-)'};
            end
        end
    end
    addNote(h,{sprintf('p < %1.2f',pThresh),'red: real signal > chance','blue: real signal < chance'});
    set(gcf,'color','w');
end

if doPlots_spectrum
    dirSelTypes = {'all','dirSel','ndirSel'};
    h = ff(1400,900);
    rows = 4;
    cols = 8 ;
    colors = magma(30);
    tWindow = 0.5;
    t = linspace(-tWindow,tWindow,size(all_acors,4));
    useRow = 0;
    for iDirSel = 2:3
        unitSel = 1:size(all_acors,1);
        if iDirSel == 2
            unitSel = ismember(unitLookup,dirSelUnitIds);
        elseif iDirSel == 3
            unitSel = ismember(unitLookup,ndirSelUnitIds);
        end
        for iPval = 1:2
            if iPval == 1
                use_acors = all_acors; % rows 1,3
                ylimVals = [-0.1 0.1];
                shuffLabel = '';
                ylabelVal = 'r';
            else
                use_acors = all_shuff_pvals; % rows 2,4
                ylimVals = [-1 1];
                shuffLabel = ' shuffled';
                ylabelVal = 'p-value';
            end
            useRow = useRow + 1;
            for iEvent = 1:8
                subplot(rows,cols,prc(cols,[useRow,iEvent]));
                for iFreq = 1:30
                    data = mean(squeeze(use_acors(unitSel,iEvent,iFreq,:)));
                    plot(t,data,'color',colors(iFreq,:));
                    hold on;
                end
                xlim([-tWindow tWindow]);
                xticks(sort([xlim,0]));
                ylim(ylimVals);
                yticks(sort([ylim 0]));
                if iEvent == 1
                    ylabel(ylabelVal);
                end
                if useRow == 4
                    xlabel('spike lags LFP (s)');
                end
                if useRow == 1
                    title({'LFP x SDE',eventFieldnames_wFake{iEvent},[dirSelTypes{iDirSel},shuffLabel]},'color','w');
                else
                    title([dirSelTypes{iDirSel},shuffLabel],'color','w');
                end
                set(gca,'color','k');
                set(gca,'XColor','w');
                set(gca,'YColor','w');
                grid on;
                if iEvent == 8
                    cb = cbAside(gca,'Freq (Hz)');
                    colormap(colors);
                    cb.Limits = [0 1];
                    cb.Ticks = linspace(0,1,numel(freqList));
                    cb.TickLabels = compose('%2.1f',freqList);
                    cb.Color = 'w';
                    cb.FontSize = 6;
                end
            end
        end
    end
    set(gcf,'color','k');
end

if doPlot_fractionBands
    pThresh = 0.95;
    h = ff(1400,800);
    rows = 3;
    cols = 8;
    colors = [0 0 0;lines(2)];
    delta1 = closest(freqList,1);
    delta2 = closest(freqList,4);
    beta1 = closest(freqList,13);
    beta2 = closest(freqList,30);
    gamma1 = closest(freqList,100);
    gamma2 = closest(freqList,200);
    printFreqs = [delta1 delta2;beta1 beta2;gamma1 gamma2];
    legendLabels = {'allUnits','dirSel','ndirSel'};
    rowLabels = {'delta','beta','gamma_h'};

    for iFreq = 1:3
        for iEvent = 1:size(all_acors,2)
            for iDirSel = 1:3
                subplot(rows,cols,prc(cols,[iFreq,iEvent]));
                unitSel = 1:size(all_acors,1);
                if iDirSel == 2
                    unitSel = ismember(unitLookup,dirSelUnitIds);
                elseif iDirSel == 3
                    unitSel = ismember(unitLookup,ndirSelUnitIds);
                end
                thisData = squeeze(all_shuff_pvals(unitSel,iEvent,printFreqs(iFreq,1),:));
                pvalSum = sum(thisData > pThresh | thisData < -pThresh);
                pvalFrac = pvalSum / size(thisData,1);
                
                plot(lag,smooth(pvalFrac,20),'color',colors(iDirSel,:),'lineWidth',2);
                hold on;
                ylim([0 0.7]);
                yticks(ylim);
                grid on;
                if iFreq == 1
                    title({eventFieldnames_wFake{iEvent},rowLabels{iFreq}});
                else
                    title(rowLabels{iFreq});
                end
            end
            if iEvent == 1
                ylabel(['xcorr frac < ',num2str(1-pThresh)]);
            end
            if iEvent == 8
                legend(legendLabels);
            end
            if iFreq == 3
                xlabel('spike lags LFP (ms)');
            end
        end
    end
    set(gcf,'color','w');
end

if doPlot_meanBands
    h = ff(1400,800);
    rows = 3;
    cols = 8;
    colors = [0 0 0;lines(2)];
    delta1 = closest(freqList,1);
    delta2 = closest(freqList,4);
    beta1 = closest(freqList,13);
    beta2 = closest(freqList,30);
    gamma1 = closest(freqList,100);
    gamma2 = closest(freqList,200);
    printFreqs = [delta1 delta2;beta1 beta2;gamma1 gamma2];
    legendLabels = {'allUnits','dirSel','ndirSel'};
    rowLabels = {'delta','beta','gamma_h'};
    pThresh = 0.05;

    for iFreq = 1:3
        for iEvent = 1:size(all_acors,2)
            for iDirSel = 1:3
                subplot(rows,cols,prc(cols,[iFreq,iEvent]));
                unitSel = 1:size(all_acors,1);
                if iDirSel == 2
                    unitSel = ismember(unitLookup,dirSelUnitIds);
                elseif iDirSel == 3
                    unitSel = ismember(unitLookup,ndirSelUnitIds);
                end
                thisData = mean(squeeze(mean(all_shuff_pvals(unitSel,iEvent,printFreqs(iFreq,1):printFreqs(iFreq,2),:))));
                plot(lag,thisData,'color',colors(iDirSel,:),'lineWidth',2);
                hold on;
                ylim([-.7,.7]);
                yticks(sort([0 ylim]));
                grid on;
                if iFreq == 1
                    title({eventFieldnames_wFake{iEvent},rowLabels{iFreq}});
                else
                    title(rowLabels{iFreq});
                end
            end
            if iEvent == 1
                ylabel('xcorr pval');
            end
            if iEvent == 8
                legend(legendLabels);
            end
            if iFreq == 3
                xlabel('spike lags LFP (ms)');
            end
        end
    end
    set(gcf,'color','w');
end

if doPlot_meanHeatmaps
    useData = {all_acors,all_acors_shuffled_mean};
    doDirSel = 1;
    if doDirSel == 1
        noteText = 'dirSel units';
        unitSel = ismember(unitLookup,dirSelUnitIds);
    elseif doDirSel == -1
        noteText = 'ndirSel units';
        unitSel = ismember(unitLookup,ndirSelUnitIds);
    else
        noteText = 'all units';
        unitSel = 1:size(all_acors,1);
    end

    h = ff(1400,800);
    rows = 4;
    cols = 8;
    acorCaxis = [-.1 .1];
    pThresh = 0.05;
    for iEvent = 1:size(all_acors,2)
        for iPval = 1:2
            subplot(rows,cols,prc(cols,[iPval,iEvent]));
            imagesc(lag,1:numel(freqList),squeeze(mean(useData{iPval}(unitSel,iEvent,:,:))));
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
            if iPval == 1
                if iEvent == 1
                    ylabel('Freq (Hz)');
                    title({eventFieldnames_wFake{iEvent},'mean xcorr'});
                else
                    title({eventFieldnames_wFake{iEvent},'mean xcorr'});
                end
            else
                title('mean xcorr_{shuffle}');
            end
            if iEvent == 8
                cbAside(gca,'acor','k');
            end
        end

        pvalMat = squeeze(mean(all_shuff_pvals(unitSel,iEvent,:,:)));
% % % %         signMat = sign(pvalMat);
% % % %         pvalMat_inv = 1 - abs(pvalMat);
% % % %         pvalMat_adj = [];
% % % %         for iBin = 1:size(pvalMat_inv,2)
% % % %             pvalMat_adj(:,iBin) = pvalMat_inv(:,iBin);%pval_adjust(pvalMat_inv(:,iBin),'holm');
% % % %         end
% % % %         pvalMat_adj_resigned = (1 - pvalMat_adj) .* signMat;
        
        subplot(rows,cols,prc(cols,[3,iEvent]));
        imagesc(lag,1:numel(freqList),pvalMat);
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
% %         title(['shuff (x',num2str(nShuffle),')']);
        title('shuffle p-value');
        if iEvent == 8
            cbAside(gca,'pval','k');
        end
        
        % [ ] is this working correctly?!
        pvalMat_thresh = pvalMat;
        signMat = sign(pvalMat);
        pvalMat_inv = 1 - abs(pvalMat);
        pvalMat_thresh(pvalMat_inv >= pThresh) = NaN;
        
        subplot(rows,cols,prc(cols,[4,iEvent]));
        imagesc(lag,1:numel(freqList),pvalMat_thresh,'AlphaData',~isnan(pvalMat_thresh));
        hold on;
        plot([0,0],ylim,'k:');
        set(gca,'ydir','normal');
        xlabel('spike lag (ms)');
        yticks(linspace(min(ylim),max(ylim),numel(freqList)));
        yticklabels(compose('%3.1f',freqList));
        colormap(gca,[0 0 1;1 0 0]);
        caxis([-1 1]);
        ax = gca;
        ax.YAxis.FontSize = 7;
        title('shuffle p-value');
        if iEvent == 8
            cbAside(gca,'pval','k');
        end
    end
    set(gcf,'color','w');
    addNote(h,noteText);
end