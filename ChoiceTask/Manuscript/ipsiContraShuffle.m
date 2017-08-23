% the fraction of units whose activity is significantly different between
% ipsi/contra trials

useEvents = 1:7;
% % trialTypes = {'correctContra','correctIpsi'};
% % [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,{trialTypes{iTrialType}},useEvents);

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

% % % %     % !! RT/MT analysis
% % % %     useTrials_filt = [];
% % % %     trialClass = [];
% % % %     trialClassCount = 1;
% % % %     for iTrial = 1:numel(useTrials)
% % % %         curTrialId = useTrials(iTrial);
% % % %         if curTrials(curTrialId).timing.MT > 0.4
% % % %             useTrials_filt = [useTrials_filt curTrialId];
% % % %             if curTrials(curTrialId).movementDirection == 1
% % % %                 trialClass(trialClassCount) = 1;
% % % %             else
% % % %                 trialClass(trialClassCount) = 0;
% % % %             end
% % % %             trialClassCount = trialClassCount + 1;
% % % %         end
% % % %     end
% % % %     
% % % %     % skip if there isn't one entry for each class (ipsi/contra)
% % % %     if sum(trialClass) == numel(trialClass) || sum(trialClass) == 0
% % % %         continue;
% % % %     end
% % % %     
% % % %     useTrials = useTrials_filt;
    
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
%         pEventAll(iEvent,:) = ??????;
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

% % % % figuree(1200,400);
% % % % for iEvent = 1:7
% % % %     subplot(1,7,iEvent);
% % % %     plot(squeeze(mean(pNeuronAll_RT(:,iEvent,:))),'b');
% % % %     hold on;
% % % %     plot(squeeze(mean(pNeuronAll_MT(:,iEvent,:))),'r');
% % % %     ylim([-2 8]);
% % % %     xlim([1 40]);
% % % %     grid on;
% % % % end