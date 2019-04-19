% MRLXFREQ
if ~exist('entrain_hist')
    load('20190318_entrain.mat')
    load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
    load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
end

% init
nBins = 12;
% % entrainmentUnits = [];
% % entrain_pvals = NaN(nSurr,2,numel(all_ts),numel(freqList)); % pos2(1) = In-trial, (2) = Inter-trial
% % entrain_rs = NaN(nSurr,2,numel(all_ts),numel(freqList));
% % entrain_mus = NaN(nSurr,2,numel(all_ts),numel(freqList));
% % entrain_hist = NaN(nSurr,2,numel(all_ts),nBins,numel(freqList));

doSave = false;

figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .02;];

do_3Dhistograms = false;
do_entrain_pvalsMRLs_dirUnits = true;
doLabels = false;

freqList = logFreqList([1 200],30);
nSurr = 200;

allUnits = 1:366;
dirUnits = {allUnits,dirSelUnitIds,ndirSelUnitIds};
dirLabels = {'allUnits','ndirSel','dirSel'};
dirLabels_wCount = {['allUnits (n = ',num2str(numel(dirUnits{1})),')'],...
    ['dirSel (n = ',num2str(numel(dirUnits{2})),')'],...
    ['ndirSel (n = ',num2str(numel(dirUnits{3})),')']};
inLabels = {'IN Trial','INTER Trial'};
surrLabels = {'Real Spikes','Poisson Spikes'};

if do_3Dhistograms
    iFreq = 6;
    
    close all
    h = ff(750,800);
    rows = 4;
    cols = 4;
    linewidths = [0.5,1,1];
    linecolors = [0 0 0;lines(2)];
    meanZ = [];
    for iDir = 1:3
        iCol = 0;
        for iIn = 1:2
            for iPoisson = 1:2
                iCol = iCol + 1;
                subplot_tight(rows,cols,prc(cols,[iDir iCol]),subplotMargins);
                if iPoisson == 1
                    data = squeeze(entrain_hist(1,iIn,dirUnits{iDir},:,iFreq));
                    norm_sum = sum(data,2);
                    useIds = find(~isnan(norm_sum));
                    Z = data(useIds,:) ./ norm_sum(useIds);
                    Z = circshift(Z,6,2);
                    meanZ(iCol,iDir,:) = [nanmean(Z) nanmean(Z)];
                else
                    all_meanZ = [];
                    all_Z = [];
                    for iSurr = 1:nSurr
                        data = squeeze(entrain_hist(iSurr,iIn,dirUnits{iDir},:,iFreq));
                        norm_sum = sum(data,2);
                        useIds = find(~isnan(norm_sum));
                        Z = data(useIds,:) ./ norm_sum(useIds);
                        all_Z(iSurr,:,:) = circshift(Z,6,2);
                        all_meanZ(iSurr,:) = [nanmean(Z) nanmean(Z)];
                    end
                    meanZ(iCol,iDir,:) = mean(all_meanZ);
                    Z = squeeze(mean(all_Z));
                end
                [~,kZ] = sort(max(Z'));
                Z = Z(kZ,:);
                kBins = [];
                for iNeuron = 1:size(Z,1)
                    [~,k] = max(Z(iNeuron,:));
                    kBins(iNeuron) = k;
                end
                [~,k] = sort(kBins);
                Z = Z(k,:);

                imagesc([Z';Z']);
                hold on;
                caxis([0.05 .10])
                usexlims = [0.5 size(Z,1) + 0.5];
                xtickVals = [1 size(Z,1)];
                xlim(usexlims);
                xticks(xtickVals);
                xticklabels([]);
                yticks([0.5 12.5 24.5]);
                plot(xlim,[12.5 12.5],'k:');
                colormap(jet);
                if doLabels
                    xlabel('units');
                    yticklabels([0 360 720]);
                    ylabel('\phi');
                    title({inLabels{iIn},surrLabels{iPoisson},dirLabels{iDir}});
                else
                    yticklabels([]);
                    xticklabels([]);
                end
            end
        end
    end
    
    for iCol = 1:4
        subplot_tight(rows,cols,prc(cols,[4 iCol]),subplotMargins);
        for iDir = 1:3
            plot(squeeze(meanZ(iCol,iDir,:)),'linewidth',linewidths(iDir),'color',linecolors(iDir,:));
            hold on;
            xlim([1 24]);
            xticks([1 12 24]);
            xticklabels([0 360 720]);
            ylim([.08 .09]);
            yticks(ylim);
            plot([12 12],ylim,'k:');
            if doLabels
                xlabel('\phi');
                ylabel('mean');
                legend(dirLabels_wCount,'fontsize',8);
            else
                yticklabels([]);
                xticklabels([]);
            end
        end
    end
    tightfig;
    set(gcf,'color','w');
    if doSave
        setFig('','',[1.5,1.5]);
        print(gcf,'-painters','-depsc',fullfile(figPath,['PHASEBINS.eps']));
        % % % %     saveas(h,fullfile(savePath,['SUASESSTRIAL.png']));
        close(h);
    end
end

if do_entrain_pvalsMRLs_dirUnits
    close all
    h = ff(1000,800);
    rows = 2;
    cols = 2;
    pThresh = 0.05;
    colors = [0 0 0;lines(2)];
    poissonAlpha = [1 0.25];
    linewidths = [1 2 2];
    lns = [];
    pThresh = 0.05;
    fromChanceYs = [.98 .95 .92];
    fromShuffleYs = [NaN .85 .82];
    fromLabels = {'diff all','diff poisson'};
    nShuffle = 1000;
    allUnits = find(ismember(dirUnits{1},entrainmentUnits));
    
    for iIn = 1:2
        subplot(rows,cols,prc(cols,[1 iIn]));
        for iDir = 1:3
            pMat = [];
            for iPoisson = 1:2
                all_pMat = [];
                shuffMat = [];
                for iFreq = 1:numel(freqList)
                    useUnits = ismember(dirUnits{iDir},entrainmentUnits);
                    if iPoisson == 1
                        data = squeeze(entrain_pvals(1,iIn,dirUnits{iDir}(useUnits),iFreq));
                        pMat(iFreq) = sum(data < pThresh) ./ sum(useUnits);
                        
                        for iShuffle = 1:nShuffle
                            shuffUnits = randsample(allUnits,sum(useUnits));
                            data = squeeze(entrain_pvals(1,iIn,shuffUnits,iFreq));
                            shuffMat(iShuffle,iFreq) = sum(data < pThresh) ./ sum(useUnits);
                        end
                    else
                        for iSurr = 1:nSurr
                            data = squeeze(entrain_pvals(iSurr+1,iIn,dirUnits{iDir},iFreq));
                            all_pMat(iSurr,iFreq) = sum(data < pThresh) ./ sum(useUnits);
                        end
                    end
                end
                if ~isempty(all_pMat)
                    diffFromChance = [];
                    for iFreq = 1:numel(freqList)
                        diffFromChance(iFreq) = sum(pMat(iFreq) < all_pMat(:,iFreq)) / nSurr;
                    end
                    pIdx = find(diffFromChance < pThresh);
                    plot(pIdx,repmat(fromChanceYs(iDir),[1,numel(pIdx)]),'s','markerfacecolor',colors(iDir,:),'MarkerEdgeColor','none');
                    hold on;
                    pMat = mean(all_pMat);
                end
                ln = plot(pMat,'color',[colors(iDir,:) poissonAlpha(iPoisson)],'linewidth',linewidths(iDir));
                hold on;
                if iPoisson == 1
                    lns(iDir) = ln;
                    if iDir > 1
                        diffFromShuff = [];
                        for iFreq = 1:numel(freqList)
                            diffFromShuff(iFreq) = sum(pMat(iFreq) < shuffMat(:,iFreq)) / nShuffle;
                        end
                        pIdx = find(diffFromShuff < pThresh | diffFromShuff >= 1-pThresh);
                        plot(pIdx,repmat(fromShuffleYs(iDir),[1,numel(pIdx)]),'s','markerfacecolor',colors(iDir,:),'MarkerEdgeColor','none');
                    end
                end
            end
        end
        xlim([0 numel(freqList)+1]);
        xticks(1:numel(freqList));
        xticklabels(compose('%1.1f',freqList));
        xtickangle(270);
        xlabel('freq. (Hz)');
        ylim([0 1]);
        yticks(sort([ylim,mean(fromChanceYs),nanmean(fromShuffleYs)]));
        yticklabels({'0',fromLabels{:},'1'});
        ylabel(sprintf('frac. p < %1.2f',pThresh));
        title([inLabels{iIn}]);
        if iPoisson == 2
            legend(lns(1:3),dirLabels_wCount,'location','northoutside');
        end
        
        
        subplot(rows,cols,prc(cols,[2 iIn]));
        maxY = 0.05;
        for iDir = 1:3
            pMat = [];
            for iPoisson = 1:2
                all_pMat = [];
                shuffMat = [];
                for iFreq = 1:numel(freqList)
                    useUnits = ismember(dirUnits{iDir},entrainmentUnits);
                    if iPoisson == 1
                        data = squeeze(entrain_rs(1,iIn,dirUnits{iDir}(useUnits),iFreq));
                        pMat(iFreq) = nanmean(data);
                        
                        for iShuffle = 1:nShuffle
                            shuffUnits = randsample(allUnits,sum(useUnits));
                            data = squeeze(entrain_rs(1,iIn,shuffUnits,iFreq));
                            shuffMat(iShuffle,iFreq) = nanmean(data);
                        end
                    else
                        for iSurr = 1:nSurr
                            data = squeeze(entrain_rs(iSurr+1,iIn,dirUnits{iDir},iFreq));
                            all_pMat(iSurr,iFreq) = nanmean(data);
                        end
                    end
                end
                if ~isempty(all_pMat)
                    diffFromChance = [];
                    for iFreq = 1:numel(freqList)
                        diffFromChance(iFreq) = sum(pMat(iFreq) < all_pMat(:,iFreq)) / nSurr;
                    end
                    pIdx = find(diffFromChance < pThresh);
                    plot(pIdx,repmat(fromChanceYs(iDir)*maxY,[1,numel(pIdx)]),'s','markerfacecolor',colors(iDir,:),'MarkerEdgeColor','none');
                    hold on;
                    pMat = mean(all_pMat);
                end
                ln = plot(pMat,'color',[colors(iDir,:) poissonAlpha(iPoisson)],'linewidth',linewidths(iDir));
                hold on;
                if iPoisson == 1
                    lns(iDir) = ln;
                    if iDir > 1
                        diffFromShuff = [];
                        for iFreq = 1:numel(freqList)
                            diffFromShuff(iFreq) = sum(pMat(iFreq) < shuffMat(:,iFreq)) / nShuffle;
                        end
                        pIdx = find(diffFromShuff < pThresh | diffFromShuff >= 1-pThresh);
                        plot(pIdx,repmat(fromShuffleYs(iDir)*maxY,[1,numel(pIdx)]),'s','markerfacecolor',colors(iDir,:),'MarkerEdgeColor','none');
                    end
                end
            end
        end
        xlim([0 numel(freqList)+1]);
        xticks(1:numel(freqList));
        xticklabels(compose('%1.1f',freqList));
        xtickangle(270);
        xlabel('freq. (Hz)');
        ylim([0 maxY]);
        yticks(sort([ylim,mean(fromChanceYs)*maxY,nanmean(fromShuffleYs)*maxY]));
        yticklabels({'0',fromLabels{:},num2str(maxY,2)});
        ylabel('mean MRL');
        title([inLabels{iIn}]);
        if iPoisson == 2
            legend(lns(1:3),dirLabels_wCount,'location','northoutside');
        end
    end

    addNote(h,{'light colors indicate firing-rate-matached Poisson spiking',...
        'averaged over 200 "Poisson-simulated" sessions'});
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,'entrain_pvalsMRLs_dirUnits.png'));
        close(h);
    end
end