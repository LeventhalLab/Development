% the fraction of units whose activity is significantly different between
% ipsi/contra trials
pVal = 0.95;
pVal_minBins = 4;
colors = lines(2);

if true
    useEvents = 1:7;
    trialTypes = {'correct'};
    
    binMs = 20;
    binS = binMs / 1000;
    binEdges = -tWindow:binS:tWindow;
    requireTrials = 2;
    nShuffle = 1000;
    pNeuronDiff = [];
    pNeuronDiff_neg = [];
    
    dirSelNeurons = false(numel(analysisConf.neurons),1);
    dirSelNeurons_contra = false(numel(analysisConf.neurons),1);
    dirSelNeurons_ipsi = false(numel(analysisConf.neurons),1);
    for iNeuron = 1:numel(analysisConf.neurons)
        neuronName = analysisConf.neurons{iNeuron};
        disp(neuronName);
        curTrials = all_trials{iNeuron};

        trialIdInfo = organizeTrialsById(curTrials);
        
        % for chi-square tests
        % chi-#1
        contraTrials = [trialIdInfo.correctContra];
        ipsiTrials = [trialIdInfo.correctIpsi];
        % chi-#2
% %         contraTrials = [trialIdInfo.correctContra trialIdInfo.incorrectIpsi];
% %         ipsiTrials = [trialIdInfo.correctIpsi trialIdInfo.incorrectContra];
        % chi-#3
% %         contraTrials = [trialIdInfo.correctContra trialIdInfo.incorrectIpsi];
% %         ipsiTrials = [trialIdInfo.correctIpsi trialIdInfo.incorrectContra];

        if numel(contraTrials) < requireTrials || numel(ipsiTrials) < requireTrials
            disp([num2str(iNeuron),' not enough trials']);
            continue;
        end

        useTrials = [contraTrials ipsiTrials];
        trialClass = zeros(numel(useTrials),1);
        trialClass(1:numel(contraTrials)) = ones(numel(contraTrials),1);


        % (ordered according to useTrials)
        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);

        pEventDiff = [];
        pEventDiff_neg = [];
        for iEvent = 1:numel(useEvents)
            curPeths = tsPeths(:,iEvent);
            eventMatrix = [];
            for iTrial = 1:numel(curPeths)
                eventMatrix(iTrial,:) = histcounts(curPeths{iTrial},binEdges);
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
            if ismember(iEvent,[4])
                % see: http://gaidi.ca/weblog/finding-consecutive-numbers-that-exceed-a-threshold-in-matlab
                dirSelNeurons_contra(iNeuron) = any(movsum(pEventDiff(iEvent,:) > pVal,[0 pVal_minBins-1]) == pVal_minBins);
                dirSelNeurons_ipsi(iNeuron) = any(movsum(pEventDiff_neg(iEvent,:) > pVal,[0 pVal_minBins-1]) == pVal_minBins);
                dirSelNeurons(iNeuron) = dirSelNeurons_contra(iNeuron) | dirSelNeurons_ipsi(iNeuron);
                
% %                 dirSelNeurons_contra(iNeuron) = sum(pEventDiff(iEvent,:) > pVal) > pVal_minBins;
% %                 dirSelNeurons_ipsi(iNeuron) = sum(pEventDiff_neg(iEvent,:) > pVal) > pVal_minBins;
            end
        end
        pNeuronDiff(iNeuron,:,:) = pEventDiff;
        pNeuronDiff_neg(iNeuron,:,:) = pEventDiff_neg;
    end
end

% see ipsiContraShuffle.m
% % useEvents = [4,6];
% % figuree(500,400);

% use ALL units?
minZ = 0;
[primSec,fractions] = primSecClass(unitEvents,minZ);

useEvents = 1:7;
figuree(1200,400);
all_eventBins = [];
for iEvent = 1:numel(useEvents)
    curEvent = useEvents(iEvent);
    subplot(1,numel(useEvents),iEvent)
    eventBins = zeros(1,size(pNeuronDiff,3));
    eventBins_class = zeros(8,size(pNeuronDiff_neg,3));
    eventBins_neg = zeros(1,size(pNeuronDiff_neg,3));
    eventBins_neg_class = zeros(8,size(pNeuronDiff_neg,3));
    for iNeuron = 1:size(pNeuronDiff,1)
        if ~isempty(unitEvents{iNeuron}.class)%% && unitEvents{iNeuron}.class(1) == 3 % tone
            curBins = squeeze(pNeuronDiff(iNeuron,curEvent,:)); % 40 bins per-event
            curBins_neg = squeeze(pNeuronDiff_neg(iNeuron,curEvent,:));
            eventBins = eventBins + (curBins > pVal)';
            eventBins_neg = eventBins_neg + (curBins_neg > pVal)';
            if ismember(3,primSec(iNeuron,:))
                eventBins_class(3,:) = eventBins_class(3,:) + (curBins > pVal)';
                eventBins_neg_class(3,:) = eventBins_neg_class(3,:) + (curBins_neg > pVal)';
            end
            if ismember(4,primSec(iNeuron,:))
                eventBins_class(4,:) = eventBins_class(4,:) + (curBins > pVal)';
                eventBins_neg_class(4,:) = eventBins_neg_class(4,:) + (curBins_neg > pVal)';
            end
        end
    end
    
%     yyaxis left;
    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor',colors(1,:),'EdgeColor',colors(1,:)); % POSITIVE
    hold on;
    bar(1:size(pNeuronDiff_neg,3),-eventBins_neg/size(pNeuronDiff_neg,1),'FaceColor',colors(2,:),'EdgeColor',colors(2,:)); % POSITIVE
    ylim([-.15 .15]);
    
%     yyaxis right;
    class_colors = parula(8);
%     class_colors(3,:) = [1 1 0];
%     class_colors(4,:) = [0 1 0];
    class_lns = [];
    class_lns_ii = 1;
    for iClass = 1:7
        class_lns(class_lns_ii) = plot(1:size(pNeuronDiff,3),eventBins_class(iClass,:)/size(pNeuronDiff,1),'-','color',class_colors(iClass,:),'lineWidth',2);
        plot(1:size(pNeuronDiff,3),-eventBins_neg_class(iClass,:)/size(pNeuronDiff,1),'-','color',class_colors(iClass,:),'lineWidth',2);
        class_lns_ii = class_lns_ii + 1;
    end
%     ylim([-1 1]);
    
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
        ylabel(['Fraction of DirSel units p < ',num2str(1-pVal,'%1.2f')]);
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

% % legend(class_lns,'tone units','nose out units')
set(gcf,'color','w');
tightfig;