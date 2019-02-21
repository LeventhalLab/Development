% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('20190121_RayLFP_compiled.mat')
% load('20190121_RayLFP_compiled.mat')
close all

freqList = logFreqList([1 200],30);
eventFieldnames_wFake = {eventFieldnames{:} 'Inter-trial'};
nShuffle = 100;

doPlot_fractionBands = false;
doPlot_meanBands = false;
doPlot_meanHeatmaps = true;

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
    for iEvent = 1:size(all_acors,2)
        for iShuffle = 1:2
            subplot(rows,cols,prc(cols,[iShuffle,iEvent]));
            imagesc(lag,1:numel(freqList),squeeze(mean(useData{iShuffle}(unitSel,iEvent,:,:))));
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