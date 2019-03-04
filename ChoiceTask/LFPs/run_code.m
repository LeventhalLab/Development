% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')

close all
doSave = false;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr';

tWindow = 1;
iTiming = 2;
showFreqs = [2,20,55,120];

nSmooth = 20;
colors = lines(4);
lineWidth = 3;
timingFields = {'RT','MT'};

rows = 4;
cols = 3;
pets = repmat(0.5,[2,7]);
pets(1,3) = 1;
pets(2,5) = 1;
rInt = 10;
climVals_rho = [-0.5 0.5];
ylimVals = [-0.5 0.5;0 1];
titleLabels = {'power','phase'};

for iTiming = 1%:2
% %     timeCorrs_power_rho = squeeze(mean(all_timeCorrs_power_rho(:,iTiming,:,:,:)));
% %     timeCorrs_power_pval = squeeze(mean(all_timeCorrs_power_pval(:,iTiming,:,:,:)));
% %     timeCorrs_phase_rho = squeeze(mean(all_timeCorrs_phase_rho(:,iTiming,:,:,:)));
% %     timeCorrs_phase_pval = squeeze(mean(all_timeCorrs_phase_pval(:,iTiming,:,:,:)));

% %         timeCorrs_power_rho = squeeze((all_timeCorrs_power_rho(iSession,iTiming,:,:,:)));
% %         timeCorrs_power_pval = squeeze((all_timeCorrs_power_pval(iSession,iTiming,:,:,:)));
% %         timeCorrs_phase_rho = squeeze((all_timeCorrs_phase_rho(iSession,iTiming,:,:,:)));
% %         timeCorrs_phase_pval = squeeze((all_timeCorrs_phase_pval(iSession,iTiming,:,:,:)));

    timeCorrs_power_rho = squeeze((all_powerCorrs(iTiming,:,:,:)));
    timeCorrs_phase_rho = squeeze((all_phaseCorrs(iTiming,:,:,:)));

    useCorrs = {timeCorrs_power_rho,timeCorrs_phase_rho};
    t = linspace(-tWindow,tWindow,size(timeCorrs_power_rho,2));

    % imagesc
    subIdxs = [1,3];
    for iPlot = 1:2
        subplot(rows,cols,prc(cols,[subIdxs(iPlot),iTiming]));
        corrMat = [];
        rIdx = 1;
        for iEvent = 1:7
            data = squeeze(useCorrs{iPlot}(iEvent,:,:));
            startIdx = closest(t,-pets(iTiming,iEvent));
            endIdx = closest(t,pets(iTiming,iEvent));
            corrMat(rIdx:rIdx+(endIdx-startIdx),:) = data(startIdx:endIdx,:);
            rIdx = rIdx + (endIdx-startIdx) + rInt;
        end
        imagesc(corrMat');
        colormap(gca,jupiter);
        set(gca,'ydir','normal');
        caxis(climVals_rho);
        xticks([]);
        yticks([]);
        ylabel('Freq (Hz)');
        title([timingFields{iTiming},' ',titleLabels{iPlot}]);
        box off;
    end

    % line plot
    subIdxs = [2,4];
    for iPlot = 1:2
        subplot(rows,cols,prc(cols,[subIdxs(iPlot),iTiming]));
        lns = [];

        for iFreq = 1:numel(showFreqs)
            rIdx = 1;
            for iEvent = 1:7
                data = smooth(squeeze(useCorrs{iPlot}(iEvent,:,closest(freqList,showFreqs(iFreq)))),nSmooth);
                startIdx = closest(t,-pets(iTiming,iEvent));
                endIdx = closest(t,pets(iTiming,iEvent));
                lns(iFreq) = plot(rIdx:rIdx+(endIdx-startIdx),data(startIdx:endIdx),'linewidth',lineWidth,'color',colors(iFreq,:));
                hold on;
                % lines/labels
                if iFreq == 1
                    centerIdx = rIdx + round((endIdx-startIdx)/2);
                    plot([centerIdx,centerIdx],ylimVals(iPlot,:),':','color',repmat(0.5,[1,3]));
                    yLabel = 0.2;
                    text(centerIdx,-yLabel,eventFieldnames{iEvent},'horizontalAlignment','center');
                    if iEvent == 1 && iPlot == 1
                        plot([rIdx+2,rIdx+(endIdx-startIdx)-2],[yLabel,yLabel],'k-','lineWidth',5);
                        text((endIdx-startIdx)+2,yLabel,'1 second');
                    end
                end
                rIdx = rIdx + (endIdx-startIdx) + rInt;
            end
        end
        xlim([1 rIdx-rInt]);
        xticks([]);
        ylim(ylimVals(iPlot,:));
        yticks(sort(unique([0,ylim])));
        ylabel('r');
        box off;
        if iPlot == 2
            legend(lns,{'\delta','\beta','\gamma_L','\gamma_h'});
        end
    end
end
%     tightfig;
set(gcf,'color','w');
saveFile = ['RTMTcorr_session_',name(1:5)];
addNote(h,saveFile);
if doSave
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end