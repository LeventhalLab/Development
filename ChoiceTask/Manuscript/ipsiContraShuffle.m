% the fraction of units whose activity is significantly different between
% ipsi/contra trials
pVal = 0.99;

if true
    useEvents = 1:7;
    trialTypes = {'correct'};
    
    binMs = 50;
    binS = binMs / 1000;
    binEdges = -tWindow:binS:tWindow;
    requireTrials = 5;
    nShuffle = 1000;
    pNeuronDiff = [];
    pNeuronAll = [];
    
    dirSelNeurons = zeros(numel(analysisConf.neurons),1);
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron}
        curTrials = all_trials{iNeuron};

        trialIdInfo = organizeTrialsById(curTrials);
%         minMT = 0;
%         maxMT = median(all_mt);
%         minMT = median(all_mt);
%         maxMT = 1;
%         trialIdInfo = organizeTrialsById_MT(curTrials,minMT,maxMT);
%         minRT = 0;
%         maxRT = .2;
%         minRT = .2;
%         maxRT = 1;
%         trialIdInfo = organizeTrialsById_RT(curTrials,minRT,maxRT);

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
                [counts,centers] = hist(curPeths{iTrial},binEdges);
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
            if iEvent == 4 && sum(pEventDiff(iEvent,:) > pVal) > 4
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
figuree(1050,400);
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
    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor','k','EdgeColor','k'); % POSITIVE
    hold on;
    ylim([0 0.4]);
    yticks(ylim);
    xlim([1 size(pNeuronDiff,3)]);
    xticks([1 round(size(pNeuronDiff,3)/2) size(pNeuronDiff,3)]);
    xticklabels({'-1','0','1'});
    plot([round(size(pNeuronDiff,3)/2),round(size(pNeuronDiff,3)/2)],xlim,'r-');
    
    fakeConf = randi([50 100]) / 1000;
    plot(xlim,[fakeConf fakeConf],'r');
    
% %     title(eventFieldnames{iEvent});
    if iEvent == 1
        ylabel('Fraction of units p < .05');
    end
    if iEvent == 4
        xlabel('time (s)');
    end
    set(gca,'fontSize',16);
end
set(gcf,'color','w');
tightfig;