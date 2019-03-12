% close all
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr';

doSave = true;
doRho = false;

iTiming = 2;
t = linspace(-1,1,size(all_pha_rho,4));
pThresh = 0.05;
freqList = logFreqList([1 200],30);
useFreqs = [4,6,17,18,19];
useSessions = 1:30;
nSmooth = 10;

h = ff(1400,800);
rows = 4;
cols = 7;
use_pvals = {all_pow_pval,all_pha_pval};
use_rhos = {all_pow_rho;all_pha_rho};
typeLabel = {'power','phase'};
climVals = [-0.3 0.3;0.1 0.5];
cmap = jupiter;
cmaps = {cmap(1:size(cmap,1),:);cmap(round(size(cmap,1)/2):size(cmap,1),:)};
colors = magma(30);
for iRow = 1:2
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[iRow*2-1,iEvent]));
        data = squeeze(mean(use_rhos{iRow}(:,iTiming,iEvent,:,:)));
        imagesc(data');
        colormap(gca,cmaps{iRow});
        set(gca,'ydir','normal');
        caxis(climVals(iRow,:));
        xticks([]);
        yticks([]);
        title({eventFieldnames{iEvent},[timingFields{iTiming},' - ',powerLabel{iRow}]});
        if iEvent == 1
            ylabel('Freq (Hz)');
        end
        if iEvent == 7
            cbAside(gca,'rho','k');
        end
            
        subplot(rows,cols,prc(cols,[iRow*2,iEvent]));
        for iFreq = 1:numel(freqList)
            data = squeeze(use_pvals{iRow}(useSessions,iTiming,iEvent,:,iFreq));
            pval_thresh = sum(data < pThresh) / size(all_pha_rho,1);
            plot(t,smooth(pval_thresh,nSmooth),'color',colors(iFreq,:),'lineWidth',1);
            hold on;
        end
        set(gca,'color','k');
        set(gca,'XColor','k');
        set(gca,'YColor','k');
        if iEvent == 1
            ylabel(sprintf('frac. sess. p < %1.2f',pThresh));
        end
        if iEvent == 7
            cb = colorbar;
            colormap(gca,colors);
            cb.Label.String = 'freq (Hz)';
            cb.Limits = [0 1];
            cb.Ticks = linspace(0,1,numel(freqList));
            cb.TickLabels = compose('%2.1f',freqList);
            cb.Color = 'k';
        end
        ylim([0 0.3]);
        yticks(ylim);
        xlim([-1 1]);
        xticks([-1 0 1]);
        grid on;
    end
end
set(gcf,'color','w');
addNote(h,{'all sessions (n = 30) averages','*not by subject*'});
if doSave
    h.InvertHardcopy = 'off';
    saveas(h,fullfile(savePath,['RMTM_fracSessPval_allSessions_',timingFields{iTiming},'.png']));
    close(h);
end

if doRho
    h = ff(1400,800);
    rows = 2;
    cols = 7;
    use_pvals = {all_pow_rho,all_pha_rho};
    typeLabel = {'power','phase'};
    colors = magma(30);
    ylimVals = [-.3 .3;.1 .4];
    for iRow = 1:2
        for iEvent = 1:7
            subplot(rows,cols,prc(cols,[iRow,iEvent]));
            for iFreq = 1:numel(freqList)
                data = squeeze(use_pvals{iRow}(useSessions,iTiming,iEvent,:,iFreq));
                pval_thresh = mean(data);% / size(all_pha_rho,1);
                plot(t,smooth(pval_thresh,10),'color',colors(iFreq,:),'lineWidth',1);
                hold on;
            end
            set(gca,'color','k');
            set(gca,'XColor','k');
            set(gca,'YColor','k');
            if iEvent == 1
                ylabel(sprintf('frac p < %1.2f',pThresh));
            end
            if iEvent == 7
                cb = colorbar;
                colormap(colors);
                cb.Limits = [0 1];
                cb.Ticks = linspace(0,1,numel(freqList));
                cb.TickLabels = compose('%2.1f',freqList);
                cb.Color = 'k';
            end
            ylim(ylimVals(iRow,:));
            yticks(ylim);
            xlim([-1 1]);
            xticks([-1 0 1]);
            title({eventFieldnames{iEvent},[typeLabel{iRow}]});
            grid on;
        end
    end

    set(gcf,'color','w');
end