% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181218_highresEntrainment.mat', 'eventFieldnames')

doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';

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

close all
h = ff(1000,800);
rows = 3;
cols = 2;
% format: entrain_pvals(iSurr,iIn,iNeuron,iFreq)
pThresh = 0.05;
colors = [0 0 0;lines(2)];
poissonAlpha = [1 0.25];
linewidths = [1 2 2];
lns = [];
for iPoisson = 1:2
    for iIn = 1:2
        subplot(rows,cols,prc(cols,[1 iIn]));
        for iDir = 1:3
            pMat_surr = [];
            pMat = [];
            for iFreq = 1:numel(freqList)
                if iPoisson == 1
                    data = squeeze(entrain_pvals(1,iIn,dirUnits{iDir},iFreq));
                    pMat(iFreq) = sum(data < pThresh) ./ sum(ismember(dirUnits{iDir},entrainmentUnits));
                else
                    for iSurr = 1:nSurr
                        data = squeeze(entrain_pvals(iSurr+1,iIn,dirUnits{iDir},iFreq));
                        pMat_surr(iSurr,iFreq) = sum(data < pThresh) ./ sum(ismember(dirUnits{iDir},entrainmentUnits));
                    end
                    pMat = mean(pMat_surr);
                end
            end
            plot(pMat,'color',[colors(iDir,:) poissonAlpha(iPoisson)],'linewidth',linewidths(iDir));
            hold on;
        end
        xticks(1:numel(freqList));
        xticklabels(compose('%1.1f',freqList));
        xtickangle(270);
        xlabel('freq. (Hz)');
        ylim([0 1]);
        yticks(ylim);
        ylabel(sprintf('frac. p < %1.2f',pThresh));
        legend(dirLabels_wCount);
        title([inLabels{iIn}]);
        
        subplot(rows,cols,prc(cols,[2 iIn]));
        for iDir = 1:3
            pMat_surr = [];
            pMat = [];
            for iFreq = 1:numel(freqList)
                if iPoisson == 1
% %                     useUnits = squeeze(entrain_pvals(1,iIn,dirUnits{iDir},iFreq)) < pThresh;
% %                     data = squeeze(entrain_rs(1,iIn,dirUnits{iDir}(useUnits),iFreq));
                    data = squeeze(entrain_rs(1,iIn,dirUnits{iDir},iFreq));
                    pMat(iFreq) = nanmean(data);
                else
                    for iSurr = 1:nSurr
                        data = squeeze(entrain_rs(iSurr+1,iIn,dirUnits{iDir},iFreq));
                        pMat_surr(iSurr,iFreq) = mean(data);
                    end
                    pMat = nanmean(pMat_surr);
                end
            end
            plot(pMat,'color',[colors(iDir,:) poissonAlpha(iPoisson)],'linewidth',linewidths(iDir));
            hold on;
        end
        xticks(1:numel(freqList));
        xticklabels(compose('%1.1f',freqList));
        xtickangle(270);
        xlabel('freq. (Hz)');
        ylim([0 0.07]);
        yticks(ylim);
        ylabel(sprintf('mean MRL',pThresh));
        legend(dirLabels_wCount);
        title([inLabels{iIn}]);
        
        subplot(rows,cols,prc(cols,[3 iIn]));
        for iDir = 1:3
            pMat_surr = [];
            pMat = [];
            for iFreq = 1:numel(freqList)
                if iPoisson == 1
                    useUnits = squeeze(entrain_pvals(1,iIn,dirUnits{iDir},iFreq)) < pThresh;
                    data = squeeze(entrain_rs(1,iIn,dirUnits{iDir}(useUnits),iFreq));
% %                     data = squeeze(entrain_rs(1,iIn,dirUnits{iDir},iFreq));
                    pMat(iFreq) = nanmean(data);
                else
                    for iSurr = 1:nSurr
                        data = squeeze(entrain_rs(iSurr+1,iIn,dirUnits{iDir},iFreq));
                        pMat_surr(iSurr,iFreq) = mean(data);
                    end
                    pMat = nanmean(pMat_surr);
                end
            end
            plot(pMat,'color',[colors(iDir,:) poissonAlpha(iPoisson)],'linewidth',linewidths(iDir));
            hold on;
        end
        xticks(1:numel(freqList));
        xticklabels(compose('%1.1f',freqList));
        xtickangle(270);
        xlabel('freq. (Hz)');
        ylim([0 0.07]);
        yticks(ylim);
        ylabel(sprintf('mean MRL for p < %1.2f units',pThresh));
        legend(dirLabels_wCount);
        title([inLabels{iIn}]);
    end
end
addNote(h,{'light colors indicate firing-rate-matached Poisson spiking',...
    'averaged over 200 "Poisson-simulated" sessions'});
set(gcf,'color','w');
if doSave
    saveas(h,fullfile(savePath,'entrain_pvalsMRLs_dirUnits.png'));
    close(h);
end