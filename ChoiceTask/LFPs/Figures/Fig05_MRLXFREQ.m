 % MRLXFREQ
% came from: /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/explore/entrainPlots.m
if ~exist('entrain_hist')
    load('20190318_entrain.mat')
    load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
    load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
end

% init
nBins = 12;
nSurr = 200;
% % entrainmentUnits = [];
% entrain_pvals = NaN(nSurr+1,2,366,numel(freqList)); % pos2(1) = In-trial, (2) = Inter-trial
% entrain_rs = NaN(nSurr+1,2,366,numel(freqList));
% entrain_mus = NaN(nSurr+1,2,366,numel(freqList));
% entrain_hist = NaN(nSurr+1,2,366,nBins,numel(freqList));

doSave = false;
doLabels = true;

figPath = '/Users/matt/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .02;];

freqList = logFreqList([1 200],30);

allUnits = 1:366;
allUnits = allUnits(~ismember(allUnits,[dirSelUnitIds,ndirSelUnitIds]));
dirUnits = {allUnits,dirSelUnitIds,ndirSelUnitIds};
dirLabels = {'allUnits','ndirSel','dirSel'};
dirLabels_wCount = {['allUnits (n = ',num2str(numel(dirUnits{1})),')'],...
    ['dirSel (n = ',num2str(numel(dirUnits{2})),')'],...
    ['ndirSel (n = ',num2str(numel(dirUnits{3})),')']};
inLabels = {'IN Trial','INTER Trial'};
surrLabels = {'Real Spikes','Poisson Spikes'};


close all
h = ff(1000,800);
rows = 2;
cols = 2;
colors = [0 0 0;lines(2)];
poissonAlpha = [1 0.25];
lns = [];
pThresh = 0.05;
fromChanceYs = [.95 .98 .92];
fromShuffleYs = [NaN .97 .92];
fromLabels = {'diff all','diff poisson'};
nShuffle = 1000;
allUnits = find(ismember(dirUnits{1},entrainmentUnits));
xmarks = round(logFreqList([1 200],6),0); %[1 4 7 13 30 70 200];
usexticks = [];
for ii = 1:numel(xmarks)
    usexticks(ii) = closest(freqList,xmarks(ii));
end

for iIn = 1:2
    subplot_tight(rows,cols,prc(cols,[1 iIn]),subplotMargins);
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
                pIdx = double(diffFromChance < .001);
                pIdx(pIdx == 0) = NaN;
                % NOT PLOTTING TOP LINES ON BOTTOM
%                 plot(1:numel(pIdx),fromChanceYs(iDir)*pIdx,'color',colors(iDir,:),'linewidth',1);
%                 hold on;
                pMat = mean(all_pMat);
            end

            ln = plot(pMat,'color',[colors(iDir,:) poissonAlpha(iPoisson)],'linewidth',1);
            hold on;

            if iPoisson == 1
                lns(iDir) = ln;
                if iDir > 1
                    diffFromShuff = [];
                    for iFreq = 1:numel(freqList)
                        diffFromShuff(iFreq) = sum(pMat(iFreq) < shuffMat(:,iFreq)) / nShuffle;
                    end
                    pIdx = find(diffFromShuff < pThresh | diffFromShuff >= 1-pThresh);
                    plot(pIdx,repmat(fromShuffleYs(iDir),[1,numel(pIdx)]),'s','markerfacecolor',...
                        colors(iDir,:),'MarkerEdgeColor','none','markersize',10);
                end
            end
        end
    end
    xlim([1 numel(freqList)]);
    ylim([0 1]);
    yticks(ylim);
    if doLabels
        title([inLabels{iIn}]);
        ylabel(sprintf('frac. p < %1.2f',pThresh));
        xtickangle(270);
        xlabel('freq. (Hz)');
    else
        xticks(usexticks);
        yticklabels([]);
        xticklabels([]);
        box off;
    end
    plot([6 6],ylim,':','color',repmat(0.1,[1,3])); % mark where values are taken from
    
    subplot_tight(rows,cols,prc(cols,[2 iIn]),subplotMargins);
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
                pIdx = double(diffFromChance < .001);
                pIdx(pIdx == 0) = NaN;
                % NOT PLOTTING TOP LINES ON BOTTOM
%                 plot(1:numel(pIdx),fromChanceYs(iDir)*pIdx*maxY,'color',colors(iDir,:),'linewidth',1);
%                 hold on;
                pMat = mean(all_pMat);
            end
            ln = plot(pMat,'color',[colors(iDir,:) poissonAlpha(iPoisson)],'linewidth',1);
            hold on;
            if iPoisson == 1
                lns(iDir) = ln;
                if iDir > 1
                    diffFromShuff = [];
                    for iFreq = 1:numel(freqList)
                        diffFromShuff(iFreq) = sum(pMat(iFreq) < shuffMat(:,iFreq)) / nShuffle;
                    end
                    pIdx = find(diffFromShuff < pThresh | diffFromShuff >= 1-pThresh);
                    plot(pIdx,repmat(fromShuffleYs(iDir)*maxY,[1,numel(pIdx)]),'s','markerfacecolor',...
                        colors(iDir,:),'MarkerEdgeColor','none','markersize',10);
                end
            end
        end
    end
    xlim([1 numel(freqList)]);
    ylim([0 0.05]);
    yticks(ylim);
    if doLabels
        title([inLabels{iIn}]);
        ylabel(sprintf('frac. p < %1.2f',pThresh));
        xtickangle(270);
        xlabel('freq. (Hz)');
    else
        xticks(usexticks);
        yticklabels([]);
        xticklabels([]);
        box off;
    end
    plot([6 6],ylim,':','color',repmat(0.1,[1,3])); % mark where values are taken from
end

if ~doLabels
    tightfig;
end
set(gcf,'color','w');
if doSave
    setFig('','',[1.5,1.5]);
    print(gcf,'-painters','-depsc',fullfile(figPath,['MRLXFREQ.eps']));
    % % % %     saveas(h,fullfile(savePath,['SUASESSTRIAL.png']));
    close(h);
end