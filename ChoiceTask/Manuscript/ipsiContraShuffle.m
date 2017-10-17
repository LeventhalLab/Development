% the fraction of units whose activity is significantly different between
% ipsi/contra trials
pVal = 0.99;
colors = lines(2);

if true
    useEvents = 1:7;
    trialTypes = {'correct'};
    
    binMs = 50;
    binS = binMs / 1000;
    binEdges = -tWindow:binS:tWindow;
    requireTrials = 5;
    nShuffle = 1000;
    pNeuronDiff = [];
    pNeuronDiff_neg = [];
    
    dirSelNeurons = zeros(numel(analysisConf.neurons),1);
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron};
        disp(neuronName);
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
        pEventDiff_neg = [];
        for iEvent = 1:numel(useEvents)
            curPeths = tsPeths(:,iEvent);
            eventMatrix = [];
            for iTrial = 1:numel(curPeths)
                [counts,centers] = hist(curPeths{iTrial},binEdges);
                eventMatrix(iTrial,:) = counts;
            end

            contraMean = mean(eventMatrix(trialClass == 1,:));
            ipsiMean = mean(eventMatrix(trialClass == 0,:));
            matrixDiff = contraMean - ipsiMean;
% %             matrixDiff = abs(contraMean - ipsiMean);
            matrixDiffShuffle = [];
            for iShuffle = 1:nShuffle
                shuffledTrialTypes = trialClass(randperm(numel(trialClass)));
                contraMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 1,:));
                ipsiMeanShuffled = mean(eventMatrix(shuffledTrialTypes == 0,:));
                matrixDiffShuffle(iShuffle,:) = contraMeanShuffled - ipsiMeanShuffled;
% %                 matrixDiffShuffle(iShuffle,:) = abs(contraMeanShuffled - ipsiMeanShuffled);
            end
            % how often is matrixDiff greater than matrixDiffShuffle?
            for iBin = 1:numel(matrixDiff)
                curMDS = matrixDiffShuffle(:,iBin);
                pEventDiff(iEvent,iBin) = numel(find(matrixDiff(iBin) > curMDS)) / nShuffle;
                pEventDiff_neg(iEvent,iBin) = numel(find(matrixDiff(iBin) < curMDS)) / nShuffle;
            end
            if iEvent == 4 && (sum(pEventDiff(iEvent,:) > pVal) > 4 || sum(pEventDiff_neg(iEvent,:) > pVal) > 4)
                dirSelNeurons(iNeuron) = 1;
            end
        end
        pNeuronDiff(iNeuron,:,:) = pEventDiff;
        pNeuronDiff_neg(iNeuron,:,:) = pEventDiff_neg;
    end
end
dirSelNeurons = logical(dirSelNeurons);

% see ipsiContraShuffle.m
useEvents = [1:7];
figuree(1200,400);
for iEvent = 1:numel(useEvents)
    subplot(1,numel(useEvents),iEvent)
    eventBins = zeros(1,size(pNeuronDiff,3));
    eventBins_neg = zeros(1,size(pNeuronDiff_neg,3));
    for iNeuron = 1:size(pNeuronDiff,1)
        if ~isempty(unitEvents{iNeuron}.class)%% && unitEvents{iNeuron}.class(1) == 3 % tone
            curBins = squeeze(pNeuronDiff(iNeuron,iEvent,:)); % 40 bins per-event
            curBins_neg = squeeze(pNeuronDiff_neg(iNeuron,iEvent,:));
            eventBins = eventBins + (curBins > pVal);
            eventBins_neg = eventBins_neg + (curBins_neg > pVal);
        end
    end

    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor',colors(1,:),'EdgeColor',colors(1,:)); % POSITIVE
    hold on;
    bar(1:size(pNeuronDiff_neg,3),-eventBins_neg/size(pNeuronDiff_neg,1),'FaceColor',colors(2,:),'EdgeColor',colors(2,:)); % POSITIVE
    ylim([-.2 .2]);
    xlim([1 size(pNeuronDiff,3)]);
    xticks([1 round(size(pNeuronDiff,3)/2) size(pNeuronDiff,3)]);
    xticklabels({'-1','0','1'});
    plot([round(size(pNeuronDiff,3)/2) round(size(pNeuronDiff,3)/2)],ylim,'k--');
    
    % Given pVal, what fraction is due to chance?
    X = binoinv(pVal,size(pNeuronDiff,1),1-pVal) / size(pNeuronDiff,1);
    plot(xlim,[X X],'r');
    plot(xlim,[-X -X],'r');
    
% %     title(eventFieldnames{iEvent});
    if iEvent == 1
        ylabel(['Fraction of units p < ',num2str(1-pVal,'%1.2f')]);
        yticks(ylim);
    else
        yticks([]);
    end
    if iEvent == 4
        xlabel('Time (s)');
    end
    set(gca,'fontSize',16);
    box off;
end
set(gcf,'color','w');
tightfig;