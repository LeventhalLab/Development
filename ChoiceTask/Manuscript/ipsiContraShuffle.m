% the fraction of units whose activity is significantly different between
% ipsi/contra trials

useEvents = 1:7;
trialTypes = {'correctContra','correctIpsi'};
% [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);

requireTrials = 5;
nShuffle = 1000;
pNeuronDiff = [];
pNeuronAll = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    
    trialIdInfo = organizeTrialsById(curTrials);
    
    if numel(trialIdInfo.correctContra) < requireTrials || numel(trialIdInfo.correctIpsi) < requireTrials
        continue;
    end
    
    useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi];
    trialClass = zeros(numel(useTrials),1);
    trialClass(1:numel(trialIdInfo.correctContra)) = ones(numel(trialIdInfo.correctContra),1);

    
    % (ordered according to useTrials)
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
    
    pEventDiff = [];
    pEventAll = [];
    for iEvent = 1:numel(useEvents)
        curPeths = tsPeths(:,iEvent);
        eventMatrix = [];
        for iTrial = 1:numel(curPeths)
            [counts,centers] = hist(curPeths{iTrial},nBins_tWindow);
            eventMatrix(iTrial,:) = counts;
        end

        contraMean = mean(eventMatrix(trialClass == 1,:));
        ipsiMean = mean(eventMatrix(trialClass == 0,:));
        matrixDiff = abs(contraMean - ipsiMean);
        matrixDiffShuffle = [];
        for iShuffle = 1:nShuffle
            shuffledTrialTypes = trialClass(randperm(numel(trialClass)));
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
    pNeuronAll(iNeuron,:,:) = pEventAll;
end