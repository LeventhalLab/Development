unitClassFlag = [];
useEvents = 1:7;
for iNeuron = 1:numel(analysisConf.neurons)
    if ~isempty(unitEvents{iNeuron}.class) && ismember(unitEvents{iNeuron}.class(1),[3,4])
        unitClassFlag(iNeuron,1) = 1;
    else
        unitClassFlag(iNeuron,1) = 0;
    end
end
unitClassFlag = logical(unitClassFlag);
% override
unitClassFlag = true(size(unitClassFlag));

if true
    tWindow = 1;
    binMs = 50;
    nBins = round((2*tWindow / .001) / binMs);
    nBinHalfWidth = ((tWindow*2) / nBins) / 2;
    binEdges = linspace(-tWindow+nBinHalfWidth,tWindow-nBinHalfWidth,nBins+1);
    neuronRTCorr = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron}
        curTrials = all_trials{iNeuron};
        trialIdInfo = organizeTrialsById(curTrials);
        
        timingField = 'RT';
        [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
        
        % override for ipsi/contra trials only
% %         allTimes = allTimes(ismember(trialIdInfo.correctIpsi,useTrials));
% %         useTrials = useTrials(ismember(trialIdInfo.correctIpsi,useTrials));
        
        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
        if isempty(tsPeths)
            continue;
        end

        tmp = figure;
        eventRTCorr = [];
        for iEvent = 1:numel(eventFieldnames)
            trial_hCounts = [];
            for iTrial = 1:numel(useTrials)
                ts_eventX = tsPeths{iTrial,iEvent};
                h = histogram(ts_eventX,binEdges);
                trial_hCounts(iTrial,:) = h.Values;
            end
            binRTCorr = [];
            for iBin = 1:size(trial_hCounts,2)
                R = corr([trial_hCounts(:,iBin)';allTimes]');
                binRTCorr(iBin) = R(2);
            end
            eventRTCorr(iEvent,:) = binRTCorr;
        end
        close(tmp);
        neuronRTCorr(iNeuron,:,:) = eventRTCorr;
        hold on;
    end
end

if true
    nShuffle = 1000;
    pVal = 0.95;
    neuronCount = 1;

    class1 = squeeze(nanmean(squeeze(neuronRTCorr(dirSelNeurons & unitClassFlag,:,:)))); % directionally selective
    class2 = squeeze(nanmean(squeeze(neuronRTCorr(~dirSelNeurons & unitClassFlag,:,:)))); % NOT directionally selective
    
    matrixDiffShuffle = [];
    for iShuffle = 1:nShuffle
        ix = randperm(numel(dirSelNeurons));
        dirSelNeurons_shuff = dirSelNeurons(ix);
        unitClassFlag_shuff = unitClassFlag(ix);
        
        class1shuffled = squeeze(nanmean(squeeze(neuronRTCorr(dirSelNeurons_shuff & unitClassFlag_shuff,:,:))));
        class2shuffled = squeeze(nanmean(squeeze(neuronRTCorr(~dirSelNeurons_shuff & unitClassFlag_shuff,:,:))));
        for iEvent = 1:numel(useEvents)
            matrixDiffShuffle(iShuffle,iEvent,:) = abs(class1shuffled(iEvent,:) - class2shuffled(iEvent,:));
        end
    end
    
    pMatrix = [];
    for iEvent = 1:numel(useEvents)
        matrixDiff = abs(class1(iEvent,:) - class2(iEvent,:));
        for iBin = 1:size(class1,2)
            pMatrix(iEvent,iBin) = numel(find(matrixDiff(iBin) > matrixDiffShuffle(:,iEvent,iBin))) / nShuffle;
        end
    end
end

figuree(1300,400);
colors = lines(3);
lns = [];
for iEvent = 1:7
    subplot(1,7,iEvent);
    
    yyaxis left;
    lns(1) = plot(smooth(nanmean(squeeze(neuronRTCorr(dirSelNeurons & unitClassFlag,iEvent,:))),3),'-','color',colors(1,:),'lineWidth',2);
    hold on;
    lns(2) = plot(smooth(nanmean(squeeze(neuronRTCorr(~dirSelNeurons & unitClassFlag,iEvent,:))),3),'-','color',colors(3,:),'lineWidth',2);
    ylim([-.1 .1]);
    
    yyaxis right;
    cur_pMatrix = smooth(1 - pMatrix(iEvent,:),3);
    plot(cur_pMatrix,'-','color',[colors(2,:) .3]);
    pMatrix_nans = cur_pMatrix;
    pMatrix_nans(find(cur_pMatrix > 1-pVal)) = NaN;
    plot(pMatrix_nans,'*','color',colors(2,:));
    ylim([0 1]);
    ylabel('p value');
    
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    title(eventFieldnames{iEvent});
    grid on;
    if iEvent == 1
        title({'corr(z,RT)',eventFieldnames{iEvent}});
    end
end
legend(lns,['Dir Sel n=',num2str(sum(dirSelNeurons & unitClassFlag))],['NOT Dir Sel n=',num2str(sum(~dirSelNeurons & unitClassFlag))]);

% individual traces
% % figuree(1300,400);
% % colors = lines(3);
% % lns = [];
% % for iEvent = 3
% % %     subplot(1,7,iEvent);
% %     
% %     yyaxis left;
% %     plot((squeeze(neuronRTCorr(dirSelNeurons & unitClassFlag,iEvent,:))),'-','color',[colors(1,:) .15],'lineWidth',0.5);
% %     hold on;
% %     plot((squeeze(neuronRTCorr(~dirSelNeurons & unitClassFlag,iEvent,:))),'-','color',[colors(3,:) .15],'lineWidth',0.5);
% %     
% %     lns(1) = plot(smooth(nanmean(squeeze(neuronRTCorr(dirSelNeurons & unitClassFlag,iEvent,:))),3),'-','color',colors(1,:),'lineWidth',2);
% %     lns(2) = plot(smooth(nanmean(squeeze(neuronRTCorr(~dirSelNeurons & unitClassFlag,iEvent,:))),3),'-','color',colors(3,:),'lineWidth',2);
% %     ylim([-0.5 .5]);
% %     
% %     xlim([1 20]);
% %     xticks([1 10 20]);
% %     xticklabels({'-1','0','1'});
% %     title(eventFieldnames{iEvent});
% %     grid on;
% %     if iEvent == 1
% %         title({'corr(z,RT)',eventFieldnames{iEvent}});
% %     end
% % end
% % legend(lns,['Dir Sel n=',num2str(sum(dirSelNeurons & unitClassFlag))],['NOT Dir Sel n=',num2str(sum(~dirSelNeurons & unitClassFlag))]);

if false
    dirClasses = [];
    allClasses = [];
    for iNeuron = 1:numel(dirSelNeurons)
        if ~isempty(unitEvents{iNeuron}.class)
            allClasses = [allClasses unitEvents{iNeuron}.class(1)];
            if dirSelNeurons(iNeuron) == 1
                dirClasses = [dirClasses unitEvents{iNeuron}.class(1)];
            end
        end
    end
    figure;
    h = histogram(allClasses,0.5:1:7.5);
    hold on;
    h = histogram(dirClasses,0.5:1:7.5);
end