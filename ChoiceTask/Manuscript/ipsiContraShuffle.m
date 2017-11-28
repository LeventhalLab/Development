% the fraction of units whose activity is significantly different between
% ipsi/contra trials
pVal = 0.95;
pVal_minBinsNO = 2;
pVal_minBinsSO = 4;
colors = lines(2);

if false
    useEvents = 1:7;
    trialTypes = {'correct'};
    
    binMs = 20;
    binS = binMs / 1000;
    binEdges = -tWindow:binS:tWindow;
    requireTrials = 2;
    nShuffle = 1000;
    pNeuronDiff = [];
    pNeuronDiff_neg = [];
    
    analyzeRange_noseOut = (tWindow / binS) : (tWindow / binS) + (0.25 / binS);
    analyzeRange_sideOut = (tWindow / binS) : (tWindow / binS) + (0.5 / binS);
    
    dirSelNeurons = false(numel(analysisConf.neurons),1);
    
    dirSelNeuronsNO = false(numel(analysisConf.neurons),1);
    dirSelNeuronsNO_contra = false(numel(analysisConf.neurons),1);
    dirSelNeuronsNO_ipsi = false(numel(analysisConf.neurons),1);
    
    dirSelNeuronsSO = false(numel(analysisConf.neurons),1);
    dirSelNeuronsSO_contra = false(numel(analysisConf.neurons),1);
    dirSelNeuronsSO_ipsi = false(numel(analysisConf.neurons),1);
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
                dirSelNeuronsNO_contra(iNeuron) = any(movsum(pEventDiff(iEvent,analyzeRange_noseOut) > pVal,[0 pVal_minBinsNO-1]) == pVal_minBinsNO);
                dirSelNeuronsNO_ipsi(iNeuron) = any(movsum(pEventDiff_neg(iEvent,analyzeRange_noseOut) > pVal,[0 pVal_minBinsNO-1]) == pVal_minBinsNO);
                dirSelNeuronsNO(iNeuron) = dirSelNeuronsNO_contra(iNeuron) | dirSelNeuronsNO_ipsi(iNeuron);
            end
            if ismember(iEvent,[6])
                % see: http://gaidi.ca/weblog/finding-consecutive-numbers-that-exceed-a-threshold-in-matlab
                dirSelNeuronsSO_contra(iNeuron) = any(movsum(pEventDiff(iEvent,analyzeRange_sideOut) > pVal,[0 pVal_minBinsSO-1]) == pVal_minBinsSO);
                dirSelNeuronsSO_ipsi(iNeuron) = any(movsum(pEventDiff_neg(iEvent,analyzeRange_sideOut) > pVal,[0 pVal_minBinsSO-1]) == pVal_minBinsSO);
                dirSelNeuronsSO(iNeuron) = dirSelNeuronsSO_contra(iNeuron) | dirSelNeuronsSO_ipsi(iNeuron);
            end
        end
        pNeuronDiff(iNeuron,:,:) = pEventDiff;
        pNeuronDiff_neg(iNeuron,:,:) = pEventDiff_neg;
    end
end

dirSelNeurons = dirSelNeuronsNO | dirSelNeuronsSO;
dirSelNO = sum(dirSelNeuronsNO)
dirSelSO = sum(dirSelNeuronsSO)
dirSelNOSO = sum(dirSelNeurons)

contra_x = sum(dirSelNeuronsNO_contra)
x_contra = sum(dirSelNeuronsSO_contra)
ipsi_x = sum(dirSelNeuronsNO_ipsi)
x_ipsi = sum(dirSelNeuronsSO_ipsi)

contraIpsi_x = sum(dirSelNeuronsNO_contra & dirSelNeuronsNO_ipsi)
x_contraIpsi = sum(dirSelNeuronsSO_contra & dirSelNeuronsSO_ipsi)

contra_contra = sum(dirSelNeuronsNO_contra & dirSelNeuronsSO_contra)
contra_ipsi = sum(dirSelNeuronsNO_contra & dirSelNeuronsSO_ipsi)
ipsi_contra = sum(dirSelNeuronsNO_ipsi & dirSelNeuronsSO_contra)
ipsi_ipsi = sum(dirSelNeuronsNO_ipsi & dirSelNeuronsSO_ipsi)

contra_NR = contra_x - (contra_contra + ipsi_contra)
ipsi_NR = ipsi_x - (ipsi_ipsi + contra_ipsi)
NR_ipsi = sum(~dirSelNeuronsNO & dirSelNeuronsSO_ipsi)
NR_contra = sum(~dirSelNeuronsNO & dirSelNeuronsSO_contra)

NRNO = sum(~dirSelNeuronsNO)
NRSO = sum(~dirSelNeuronsSO)
NR_NOSO = sum(~dirSelNeurons)

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
            if ismember(4,primSec(iNeuron,:))
                eventBins_class(4,:) = eventBins_class(4,:) + (curBins > pVal)';
                eventBins_neg_class(4,:) = eventBins_neg_class(4,:) + (curBins_neg > pVal)';
            end
            if ismember(6,primSec(iNeuron,:))
                eventBins_class(6,:) = eventBins_class(6,:) + (curBins > pVal)';
                eventBins_neg_class(6,:) = eventBins_neg_class(6,:) + (curBins_neg > pVal)';
            end
        end
    end
    
%     yyaxis left;
    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor',colors(1,:),'EdgeColor',colors(1,:)); % POSITIVE
    hold on;
    bar(1:size(pNeuronDiff_neg,3),-eventBins_neg/size(pNeuronDiff_neg,1),'FaceColor',colors(2,:),'EdgeColor',colors(2,:)); % POSITIVE
    ylim([-.15 .15]);
    
%     yyaxis right;
    class_colors = jet(8);
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

legend(class_lns,eventFieldlabels)
set(gcf,'color','w');
tightfig;