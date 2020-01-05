% PHASEBINS
% came from: /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/explore/entrainPlots.m
if ~exist('entrain_hist')
    load('20190318_entrain.mat')
    load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
    load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
end

doSave = false;
doLabels = false;

figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .02;];

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
            ax = gca;
            ax.Position = ax.Position .* [1 1 1 0.95];
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