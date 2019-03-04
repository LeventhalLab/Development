% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')

close all
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr';

tWindow = 1;
showFreqs = [2,20,55,120];

nSmooth = 20;
colors = lines(4);
lineWidth = 3;
timingFields = {'RT','MT'};

rows = 4;
cols = 2;
pets = repmat(0.5,[2,7]);
pets(1,3) = 1;
pets(2,5) = 1;
rInt = 10;
titleLabels = {'power','phase'};

for iTiming = 1:2
    h = ff(1400,800);
    timeCorrs_power_rho = squeeze((all_powerCorrs(iTiming,:,:,:)));
    timeCorrs_power_pval = squeeze((all_powerPvals(iTiming,:,:,:)));
    timeCorrs_phase_rho = squeeze((all_phaseCorrs(iTiming,:,:,:)));
    timeCorrs_phase_pval = squeeze((all_phasePvals(iTiming,:,:,:)));
    for iPval = 1:2
        if iPval == 1
            useCorrs = {timeCorrs_power_rho,timeCorrs_phase_rho};
            ylimVals = [-0.5 0.5;0 0.5];
            climVals = [-0.5 0.5];
            cmap = jupiter;
        else
            useCorrs = {timeCorrs_power_pval,timeCorrs_phase_pval};
            ylimVals = [0 0.001;0 0.001];
            climVals = [0 0.001];
            cmap = hot;
        end
        t = linspace(-tWindow,tWindow,size(timeCorrs_power_rho,2));

        % imagesc
        subIdxs = [1,3];
        for iPlot = 1:2
            subplot(rows,cols,prc(cols,[subIdxs(iPlot),iPval]));
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
            colormap(gca,cmap);
            set(gca,'ydir','normal');
            caxis(climVals);
            xticks([]);
            yticks([]);
            ylabel('Freq (Hz)');
            title([timingFields{iTiming},' ',titleLabels{iPlot}]);
            box off;
            cbAside(gca,'','k');
        end

        % line plot
        subIdxs = [2,4];
        for iPlot = 1:2
            subplot(rows,cols,prc(cols,[subIdxs(iPlot),iPval]));
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
    saveFile = ['RTMTcorr_allSessions_wPvals_',timingFields{iTiming}];
    addNote(h,saveFile);
    if doSave
        saveas(h,fullfile(savePath,[saveFile,'.jpg']));
        close(h);
    end
end