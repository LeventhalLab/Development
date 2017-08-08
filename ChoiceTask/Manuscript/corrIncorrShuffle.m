useEvents = 1:7;
requireTrials = 5;
nShuffle = 1000;
pNeuronDiff = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);
    
    if numel(trialIdInfo.correctContra) + numel(trialIdInfo.correctIpsi) < requireTrials || numel(trialIdInfo.incorrectContra) + numel(trialIdInfo.incorrectIpsi) < requireTrials
        continue;
    end
    
    useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
    trialClass = zeros(numel(useTrials),1);
    trialClass(1:numel(trialIdInfo.correctContra) + numel(trialIdInfo.correctIpsi)) = ones(numel(trialIdInfo.correctContra) + numel(trialIdInfo.correctIpsi),1);
    % should be ordered according to useTrials
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
    
    pEventDiff = [];
    for iEvent = 1:numel(useEvents)
        curPeths = tsPeths(:,iEvent);
        eventMatrix = [];
        for iTrial = 1:numel(curPeths)
            [counts,centers] = hist(curPeths{iTrial},nBins_tWindow);
            eventMatrix(iTrial,:) = counts;
        end
        corrMean = mean(eventMatrix(trialClass == 1,:));
        incorrMean = mean(eventMatrix(trialClass == 0,:));
        matrixDiff = abs(corrMean - incorrMean);
        matrixDiffShuffle = [];
        for iShuffle = 1:nShuffle
            shuffledTrialTypes = trialClass(randperm(numel(trialClass)));
            corrMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 1,:));
            incorrMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 0,:));
            matrixDiffShuffle(iShuffle,:) = abs(corrMeanShuffled - incorrMeanShuffled);
        end
        % how often is matrixDiff greater than matrixDiffShuffle?
        for iBin = 1:numel(matrixDiff)
            curMDS = matrixDiffShuffle(:,iBin);
            pEventDiff(iEvent,iBin) = numel(find(matrixDiff(iBin) > curMDS)) / nShuffle;
        end
    end
    pNeuronDiff(iNeuron,:,:) = pEventDiff;
end