% the fraction of units whose activity is significantly different between
% ipsi/contra trials
pVal = 0.95;

if true
    useEvents = 1:7;
    trialTypes = {'correctContra','correctIpsi'};

    requireTrials = 5;
    nShuffle = 1000;
    pNeuronDiff = [];
    pNeuronAll = [];
    
    dirSelNeurons = zeros(numel(analysisConf.neurons),1);
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
            if iEvent == 4 && sum(pEventDiff(iEvent,:) > pVal) > 5
                dirSelNeurons(iNeuron) = 1;
            end
        end
        pNeuronDiff(iNeuron,:,:) = pEventDiff;
        pNeuronAll(iNeuron,:,:) = pEventAll;
    end
end
dirSelNeurons = logical(dirSelNeurons);

% see ipsiContraShuffle.m
useEvents = [1:7];
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
    ylim([0 0.4]);
    yticks([0:0.2:0.4]);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
    xlabel(eventFieldnames{iEvent});
    if iEvent == 1
        ylabel('Fraction of units < 0.05');
    end
end