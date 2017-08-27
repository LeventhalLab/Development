% the fraction of units whose activity is significantly different between
% lowTIME/highTIME trials
useAnalysis = 3;
useEvents = 1:7;
trialTypes = {'correctContra','correctIpsi'};

requireTrials = 1;
nShuffle = 1000;
pNeuronDiff = [];
pNeuronAll = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    
    if useAnalysis == 1
        analysisName = 'low/high RT';
        TIMEmin = 0;
        TIMEmax = median(all_rt);% + std(all_rt);
        trialIdInfo_lowTIME = organizeTrialsById_RT(curTrials,TIMEmin,TIMEmax);

        TIMEmin = median(all_rt);% + std(all_rt);
        TIMEmax = 2;
        trialIdInfo_highTIME = organizeTrialsById_RT(curTrials,TIMEmin,TIMEmax);
    end
    if useAnalysis == 2
        analysisName = 'low/high MT';
        TIMEmin = 0;
        TIMEmax = median(all_mt);% + std(all_rt);
        trialIdInfo_lowTIME = organizeTrialsById_MT(curTrials,TIMEmin,TIMEmax);

        TIMEmin = median(all_mt);% + std(all_rt);
        TIMEmax = 2;
        trialIdInfo_highTIME = organizeTrialsById_MT(curTrials,TIMEmin,TIMEmax);
    end
    if useAnalysis == 3
        analysisName = 'low/high pretone';
        TIMEmin = 0;
        TIMEmax = .75;% + std(all_rt);
        trialIdInfo_lowTIME = organizeTrialsById_pretone(curTrials,TIMEmin,TIMEmax);

        TIMEmin = .75;% + std(all_rt);
        TIMEmax = 2;
        trialIdInfo_highTIME = organizeTrialsById_pretone(curTrials,TIMEmin,TIMEmax);
    end
    
    if numel(trialIdInfo_lowTIME.correctContra) < requireTrials || numel(trialIdInfo_lowTIME.correctIpsi) < requireTrials || ...
        numel(trialIdInfo_highTIME.correctContra) < requireTrials || numel(trialIdInfo_highTIME.correctIpsi) < requireTrials
        disp(['Not enough trials, iNeuron: ',num2str(iNeuron)]);
        continue;
    end
    
    useTrials = [trialIdInfo_lowTIME.correctContra trialIdInfo_lowTIME.correctIpsi trialIdInfo_highTIME.correctContra trialIdInfo_highTIME.correctIpsi];
    trialClass = zeros(numel(useTrials),1);
    trialClass(1:numel([trialIdInfo_lowTIME.correctContra trialIdInfo_lowTIME.correctIpsi])) = ones(numel([trialIdInfo_lowTIME.correctContra trialIdInfo_lowTIME.correctIpsi]),1);

    
    % (ordered according to useTrials)
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
    
    pEventDiff = [];
    pEventAll = [];
    for iEvent = 1:numel(useEvents)
        curPeths = tsPeths(:,iEvent);
        eventMatrix = [];
        for iTrial = 1:numel(curPeths)
            counts = histcounts(curPeths{iTrial},nBins_tWindow);
            eventMatrix(iTrial,:) = counts;
        end

        highTIMEMean = mean(eventMatrix(trialClass == 1,:));
        lowTIMEMean = mean(eventMatrix(trialClass == 0,:));
        matrixDiff = abs(highTIMEMean - lowTIMEMean);
        matrixDiffShuffle = [];
        for iShuffle = 1:nShuffle
            shuffledTrialTypes = trialClass(randperm(numel(trialClass)));
            highTIMEMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 1,:));
            lowTIMEMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 0,:));
            matrixDiffShuffle(iShuffle,:) = abs(highTIMEMeanShuffled - lowTIMEMeanShuffled);
        end
        % how often is matrixDiff greater than matrixDiffShuffle?
        for iBin = 1:numel(matrixDiff)
            curMDS = matrixDiffShuffle(:,iBin);
            pEventDiff(iEvent,iBin) = numel(find(matrixDiff(iBin) > curMDS)) / nShuffle;
        end
    end
    pNeuronDiff(iNeuron,:,:) = pEventDiff;
    pNeuronAll(iNeuron,:,:) = pEventAll;
end

pVal = 0.95;
figuree(1200,400);
for iEvent = 1:numel(useEvents)
    subplot(1,numel(useEvents),iEvent)
    eventBins = zeros(1,size(pNeuronDiff,3));
    for iNeuron = 1:size(pNeuronDiff,1)
        if ~isempty(unitEvents{iNeuron}.class)%% && unitEvents{iNeuron}.class(1) == 3 % tone
            curBins = squeeze(pNeuronDiff(iNeuron,iEvent,:)); % 40 bins per-event
            eventBins = eventBins + (curBins > pVal);
        end
    end

%     bar(1:size(pNeuronDiff,3),eventBins/numel(toneNeurons),'FaceColor','k','EdgeColor','none'); % POSITIVE
    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor','k','EdgeColor','none'); % POSITIVE
    hold on;
    ylim([0 0.2]);
%     yticks([0:0.2:0.4]);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
    if iEvent == 1
        title({analysisName,eventFieldnames{iEvent}});
        ylabel('Fraction of units < 0.05');
    else
         title({'',eventFieldnames{iEvent}});
    end
end