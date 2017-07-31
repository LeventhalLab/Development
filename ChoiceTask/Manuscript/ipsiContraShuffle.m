useEvents = 1:7;
requireTrials = 5;
nShuffle = 1000;
pNeuronDiff = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);
    
    if numel(trialIdInfo.correctContra) < requireTrials || numel(trialIdInfo.correctIpsi) < requireTrials
        continue;
    end
    
    useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi];
    trialTypes = zeros(numel(useTrials),1);
    trialTypes(1:numel(trialIdInfo.correctContra)) = ones(numel(trialIdInfo.correctContra),1);
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
        contraMean = mean(eventMatrix(trialTypes == 1,:));
        ipsiMean = mean(eventMatrix(trialTypes == 0,:));
        matrixDiff = abs(contraMean - ipsiMean);
        matrixDiffShuffle = [];
        for iShuffle = 1:nShuffle
            shuffledTrialTypes = trialTypes(randperm(numel(trialTypes)));
            contraMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 1,:));
            ipsiMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 0,:));
            matrixDiffShuffle(iShuffle,:) = abs(contraMeanShuffled - ipsiMeanShuffled);
        end
        % how often is matrixDiff greater than matrixDiffShuffle?
        for iBin = 1:numel(matrixDiff)
            curMDS = matrixDiffShuffle(:,iBin);
            pEventDiff(iEvent,iBin) = numel(find(matrixDiff(iBin) > curMDS)) / nShuffle;
        end
    end
    pNeuronDiff(iNeuron,:,:) = pEventDiff;
end