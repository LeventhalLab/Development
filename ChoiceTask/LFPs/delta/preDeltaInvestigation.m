doSetup = false;
doSave = true;
freqList = {[1 4]}; % hilbert method
iEvent = 4;
tWindow = 1;

if doSetup
    compiledData = [];
    iSession = 0;
    for iNeuron = selectedLFPFiles(1:4)'
        iSession = iSession + 1;
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};
        curTrials = curTrials([curTrials(:).correct] == 1 | [curTrials(:).falseStart] == 1);

        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        falseTrialIds = find([curTrials(:).falseStart] == 1);
        [W,all_data] = eventsLFPv2(curTrials,sevFilt,tWindow,Fs,freqList,{eventFieldnames{iEvent}});

        lineWidth = 1.5;
        grayColor = repmat(0.8,[1 4]);
        t = linspace(-tWindow,tWindow,size(all_data,2));
        ylimVals = [-250 250];
        rows = 2;
        cols = 2;
        h = ff(800,500);
        lns = [];

        subplot(rows,cols,prc(cols,[1,1]));
        for iTrial = 1:numel(trialIds)
            plot(t,squeeze(real(W(1,:,trialIds(iTrial)))),'color',grayColor,'lineWidth',0.5);
            hold on;
        end
        lns(1) = plot(t,squeeze(mean(real(W(1,:,trialIds)),3)),'-k','lineWidth',lineWidth);
        lns(2) = plot(t,squeeze(mean(abs(W(1,:,trialIds)),3)),'-r','lineWidth',lineWidth);
        compiledData(1,1,1,iSession,:) = squeeze(mean(real(W(1,:,trialIds)),3));
        compiledData(1,1,2,iSession,:) = squeeze(mean(abs(W(1,:,trialIds)),3));
        xticks([-tWindow,0,tWindow]);
        xlabel('time (s)');
        title('correct');
        ylim(ylimVals);
        yticks(sort([ylim 0]));
        grid on;
        legend(lns,{'real','power'},'location','northwest');

        subplot(rows,cols,prc(cols,[2,1]));
        for iTrial = 1:numel(falseTrialIds)
            plot(t,squeeze(real(W(1,:,falseTrialIds(iTrial)))),'color',grayColor,'lineWidth',0.5);
            hold on;
        end
        plot(t,squeeze(mean(real(W(1,:,falseTrialIds)),3)),'-k','lineWidth',lineWidth);
        plot(t,squeeze(mean(abs(W(1,:,falseTrialIds)),3)),'-r','lineWidth',lineWidth);
        compiledData(2,1,1,iSession,:) = squeeze(mean(real(W(1,:,falseTrialIds)),3));
        compiledData(2,1,2,iSession,:) = squeeze(mean(abs(W(1,:,falseTrialIds)),3));
        xticks([-tWindow,0,tWindow]);
        xlabel('time (s)');
        ylim(ylimVals);
        yticks(sort([ylim 0]));
        title('falseStart');
        grid on;


        lowRTtrials = find(allTimes <= .200);
        highRTtrials = find(allTimes > .200);

        subplot(rows,cols,prc(cols,[1,2]));
        for iTrial = 1:numel(lowRTtrials)
            plot(t,squeeze(real(W(1,:,trialIds(lowRTtrials(iTrial))))),'color',grayColor,'lineWidth',0.5);
            hold on;
        end
        plot(t,squeeze(mean(real(W(1,:,trialIds(lowRTtrials))),3)),'-k','lineWidth',lineWidth);
        plot(t,squeeze(mean(abs(W(1,:,trialIds(lowRTtrials))),3)),'-r','lineWidth',lineWidth);
        compiledData(1,2,1,iSession,:) = squeeze(mean(real(W(1,:,trialIds(lowRTtrials))),3));
        compiledData(1,2,2,iSession,:) = squeeze(mean(abs(W(1,:,trialIds(lowRTtrials))),3));
        xticks([-tWindow,0,tWindow]);
        xlabel('time (s)');
        ylim(ylimVals);
        yticks(sort([ylim 0]));
        title('lowRT');
        grid on;

        subplot(rows,cols,prc(cols,[2,2]));
        for iTrial = 1:numel(highRTtrials)
            plot(t,squeeze(real(W(1,:,trialIds(highRTtrials(iTrial))))),'color',grayColor,'lineWidth',0.5);
            hold on;
        end
        plot(t,squeeze(mean(real(W(1,:,trialIds(highRTtrials))),3)),'-k','lineWidth',lineWidth);
        plot(t,squeeze(mean(abs(W(1,:,trialIds(highRTtrials))),3)),'-r','lineWidth',lineWidth);
        compiledData(2,2,1,iSession,:) = squeeze(mean(real(W(1,:,trialIds(highRTtrials))),3));
        compiledData(2,2,2,iSession,:) = squeeze(mean(abs(W(1,:,trialIds(highRTtrials))),3));
        xticks([-tWindow,0,tWindow]);
        xlabel('time (s)');
        ylim(ylimVals);
        yticks(sort([ylim 0]));
        title('highRT');
        grid on;
        
        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,['preDelta_s',num2str(iSession,'%02d'),'.png']));
            close(h);
        end
    end
end
h = ff(800,500);
for iRow = 1:2
    for iCol = 1:2
        subplot(rows,cols,prc(cols,[iRow,iCol]));
        sessMean = squeeze(mean(compiledData(iRow,iCol,1,:,:),4));
        lns(1) = plot(t,sessMean,'-k','lineWidth',lineWidth);
        hold on;
        sessMean = squeeze(mean(compiledData(iRow,iCol,2,:,:),4));
        lns(2) = plot(t,sessMean,'-r','lineWidth',lineWidth);
        xticks([-tWindow,0,tWindow]);
        xlabel('time (s)');
        ylim(ylimVals);
        yticks(sort([ylim 0]));
    end
end
