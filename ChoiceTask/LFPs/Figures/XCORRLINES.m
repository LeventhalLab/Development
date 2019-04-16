% XCORRLINES
if ~exist('tXcorr')
    load('20190402_xcorr.mat')
    load('20190321_xcorr_poisson_allUnits.mat', 'tXcorr', 'lag')
    load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec');
    load('20190321_xcorr_poisson_allUnits')
end

close all

figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];
nShuffle = 1000;

doSave = true;
doLabels = false;

tlag = linspace(-tXcorr,tXcorr,numel(lag));
condLabels = {'allUnits','dirSel','ndirSel'};
condUnits = {1:366,dirSelUnitIds,ndirSelUnitIds};
freqList = logFreqList([1 200],30);
inLabels = {'in-trial','inter-trial'};

h = ff(900,500);
useFreqs = [6;17;22;29];
freqLabels = {'\delta','\beta','\gamma_L','\gamma_H'};
rows = 2;
cols = size(useFreqs,1);
colors = {lines(size(useFreqs,1)),lines(size(useFreqs,1))*.3};
pThresh = 0.05;
ylimVals = [-0.05,0.05];
for iFreq = 1:size(useFreqs,1)
    for iDir = 2:3
        useUnits = ismember(xcorrUnits,condUnits{iDir});
        subplot_tight(rows,cols,prc(cols,[iDir-1,iFreq]),subplotMargins);
        for iIn = 1:2
            poisson_data = squeeze(nanmean(all_acors_poisson_mean(:,condUnits{iDir},iIn,iFreq,:),2));
            plot(tlag,min(poisson_data)','color',[colors{iIn}(iFreq,:) 0.8]);
            plot(tlag,max(poisson_data)','color',[colors{iIn}(iFreq,:) 0.8]);
            hold on;
            data = squeeze(nanmean(all_acors(useUnits,iIn,useFreqs(iFreq),:)));
            plot(tlag,data,'color',colors{iIn}(iFreq,:),'linewidth',1);
            
            % display
% % % %             disp([condLabels{iDir},' ',inLabels{iIn},', ',num2str(iFreq)]);
% % % %             [v,k] = min(data);
% % % %             disp(['--> MIN: r = ',num2str(v,3),', t = ',num2str(tlag(k)*1000,3)]);
% % % %             [v,k] = max(data);
% % % %             disp(['--> MAX: r = ',num2str(v,3),', t = ',num2str(tlag(k)*1000,3)]);
% % % %             
            
% %             if iDir > 1
% %                 shuff_data = squeeze(all_acor_shuffle(:,iIn,iDir,useFreqs(iFreq),:));
% %                 diffFromShuff = sum(data' < shuff_data) / nShuffle;
% %                 pIdx = find(diffFromShuff < pThresh);% | diffFromShuff >= 1-pThresh);
% %                 plot(tlag(pIdx),ones(size(pIdx))*max(ylimVals)-(iIn*.005),'.','color',colors{iIn}(iFreq,:),'linewidth',2);
% %                 pIdx = find(diffFromShuff >= 1-pThresh);
% %                 plot(tlag(pIdx),ones(size(pIdx))*min(ylimVals)+(iIn*.005),'.','color',colors{iIn}(iFreq,:),'linewidth',2);
% %             else
% %                 if iIn == 2
% %                     legend({'in-trial','inter-trial'},'location','northwest');
% %                 end
% %             end
        end
        xlim([min(tlag) max(tlag)]);
        xticks(sort([0,xlim]));
        ylim(ylimVals);
        yticks(sort([0,ylim]));
        plot([0,0],ylim,'k:'); % center line
        grid on;
        
        if doLabels
            title({condLabels{iDir},freqLabels{iFreq}});
            xlabel('spike lags LFP (s)');
            ylabel('mean xcorr');
            grid on;
        else
            yticklabels({});
            xticklabels({});
        end
    end
end

tightfig;
set(gcf,'color','w');
if doSave
    setFig('','',[1.5,1.5]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'XCORRLINES.eps'));
    % % % %     saveas(h,fullfile(savePath,'SPIKEXCORR.png'));
    close(h);
end