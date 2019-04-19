% see /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/explore/spikeXcorrGenerator.m
% load('20190402_xcorr');
% load('20190321_xcorr_poisson_allUnits.mat', 'tXcorr', 'lag')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec');
close all

figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .02];

doSave = true;
doLabels = false;

tlag = linspace(-tXcorr,tXcorr,numel(lag));
condLabels = {'allUnits','dirSel','ndirSel'};
condUnits = {1:366,dirSelUnitIds,ndirSelUnitIds};
freqList = logFreqList([1 200],30);
inLabels = {'in-trial','inter-trial'};

h = ff(400,575);
rows = 3;
cols = 2;
for iIn = 1:2
    for iDir = 1:3
        subplot_tight(rows,cols,prc(cols,[iDir,iIn]),subplotMargins);
        useUnits = ismember(xcorrUnits,condUnits{iDir});
        data = squeeze(nanmean(all_acors(useUnits,iIn,:,:)));
        imagesc(tlag,1:numel(freqList),data);
        hold on;
        plot([0,0],ylim,'k:');
        set(gca,'ydir','normal');
        xlim([min(tlag) max(tlag)]);
        xticks(sort([0,xlim]));
        colormap(gca,jet);
        caxis([-0.02,0.05]);
        if doLabels
            title({inLabels{iIn},condLabels{iDir}});
            xlabel('spike lags LFP (s)');
            yticks(linspace(min(ylim),max(ylim),numel(freqList)));
            yticklabels(compose('%3.1f',freqList));
        else
            yticks(ylim);
            yticklabels({});
            xticklabels({});
        end
    end
    
% %     subplot(rows,cols,prc(cols,[iIn,4]));
% %     data = squeeze(nanmean(all_acors(useUnits,iIn,useFreqs(iFreq),:)));
end
tightfig;
set(gcf,'color','w');
if doSave
    setFig('','',[1,3]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'SPIKEXCORR.eps'));
% % % %     saveas(h,fullfile(savePath,'SPIKEXCORR.png'));
    close(h);
end