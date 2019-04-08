% load('20190402_xcorr');
% load('20190321_xcorr_poisson_allUnits.mat', 'tXcorr', 'lag')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec');
doSave = false;

tlag = linspace(-tXcorr,tXcorr,numel(lag));
condLabels = {'allUnits','dirSel','ndirSel'};
condUnits = {1:366,dirSelUnitIds,ndirSelUnitIds};
freqList = logFreqList([1 200],30);
inLabels = {'in-trial','inter-trial'};

h = ff(1400,500);
rows = 2;
cols = 4;
for iIn = 1:2
    for iDir = 1:3
        subplot(rows,cols,prc(cols,[iIn,iDir]));
        useUnits = ismember(xcorrUnits,condUnits{iDir});
        data = squeeze(nanmean(all_acors(useUnits,iIn,:,:)));
        imagesc(tlag,1:numel(freqList),data);
        hold on;
        plot([0,0],ylim,'k:');
        set(gca,'ydir','normal');
        xlim([min(tlag) max(tlag)]);
        xticks(sort([0,xlim]));
        xlabel('spike lags LFP (s)');
        yticks(linspace(min(ylim),max(ylim),numel(freqList)));
        yticklabels(compose('%3.1f',freqList));
        colormap(gca,jet);
        caxis([-0.02,0.05]);
        title({inLabels{iIn},condLabels{iDir}});
    end
    
    subplot(rows,cols,prc(cols,[iIn,4]));
    data = squeeze(nanmean(all_acors(useUnits,iIn,useFreqs(iFreq),:)));
end
set(gcf,'color','w');
if doSave
    saveas(h,fullfile(savePath,'SPIKEXCORR.png'));
    close(h);
end