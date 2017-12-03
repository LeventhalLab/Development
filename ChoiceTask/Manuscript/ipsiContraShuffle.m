% the fraction of units whose activity is significantly different between
% ipsi/contra trials
pVal = 0.95;
pVal_minBins = 2;
colors = lines(2);
analyzeRange = (tWindow / binS) : (tWindow / binS) + (0.25 / binS);
dirSelType = 'NO'; % NO or SO

if ismac
    localSideOutPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/sideOutAnalysis';
else
    localSideOutPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\sideOutAnalysis';
end

excludeSessions = {'R0117_20160504a','R0142_20161207a','R0117_20160508a','R0117_20160510a'}; % corrupt video
[sessionNames,IA] = unique(analysisConf.sessionNames);

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

    if strcmp(dirSelType,'NO')
        dirSelNeuronsNO = false(numel(analysisConf.neurons),1);
        dirSelNeuronsNO_contra = false(numel(analysisConf.neurons),1);
        dirSelNeuronsNO_ipsi = false(numel(analysisConf.neurons),1);
        dirSelNeuronsNO_count = 0;
    else
        dirSelNeuronsSO = false(numel(analysisConf.neurons),1);
        dirSelNeuronsSO_contra = false(numel(analysisConf.neurons),1);
        dirSelNeuronsSO_ipsi = false(numel(analysisConf.neurons),1);
        dirSelNeuronsSO_count = 0;
    end

    for iNeuron = 1:numel(analysisConf.neurons)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        neuronName = analysisConf.neurons{iNeuron};
        disp(neuronName);
        
        curTrials = all_trials{iNeuron};
        
        if strcmp(dirSelType,'NO')
            trialIdInfo = organizeTrialsById(curTrials);
            contraTrials = [trialIdInfo.correctContra];
            ipsiTrials = [trialIdInfo.correctIpsi];
        else
            if ismember(sessionConf.sessions__name,excludeSessions)
                continue;
            end
            CSVpath = fullfile(localSideOutPath,[sessionConf.sessions__name,'_sideOutAnalysis.csv']);
            M = csvread(CSVpath);
            contraTrials = find(M == 1)';
            ipsiTrials = find(M == 2)';
        end

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
            if iEvent == 4 && strcmp(dirSelType,'NO')
                dirSelNeuronsNO_contra_ntpIdx = movsum(pEventDiff(iEvent,analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
                dirSelNeuronsNO_ipsi_ntpIdx = movsum(pEventDiff_neg(iEvent,analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
                if any(dirSelNeuronsNO_contra_ntpIdx) && any(dirSelNeuronsNO_ipsi_ntpIdx)
                    if mean(pEventDiff(iEvent,analyzeRange)) > mean(pEventDiff_neg(iEvent,analyzeRange))
                        dirSelNeuronsNO_contra(iNeuron) = 1;
                    else
                        dirSelNeuronsNO_ipsi(iNeuron) = 1;
                    end
                else
                    dirSelNeuronsNO_contra(iNeuron) = any(dirSelNeuronsNO_contra_ntpIdx);
                    dirSelNeuronsNO_ipsi(iNeuron) = any(dirSelNeuronsNO_ipsi_ntpIdx);
                end
                dirSelNeuronsNO(iNeuron) = dirSelNeuronsNO_contra(iNeuron) | dirSelNeuronsNO_ipsi(iNeuron);
                dirSelNeuronsNO_count = dirSelNeuronsNO_count + 1;
            end
            if iEvent == 6 && strcmp(dirSelType,'SO')
                % see: http://gaidi.ca/weblog/finding-consecutive-numbers-that-exceed-a-threshold-in-matlab
                % mutually exclusive
                dirSelNeuronsSO_contra_ntpIdx = movsum(pEventDiff(iEvent,analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
                dirSelNeuronsSO_ipsi_ntpIdx = movsum(pEventDiff_neg(iEvent,analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
                if any(dirSelNeuronsSO_contra_ntpIdx) && any(dirSelNeuronsSO_ipsi_ntpIdx)
                    if mean(pEventDiff(iEvent,analyzeRange)) > mean(pEventDiff_neg(iEvent,analyzeRange))
                        dirSelNeuronsSO_contra(iNeuron) = 1;
                    else
                        dirSelNeuronsSO_ipsi(iNeuron) = 1;
                    end
                else
                    dirSelNeuronsSO_contra(iNeuron) = any(dirSelNeuronsSO_contra_ntpIdx);
                    dirSelNeuronsSO_ipsi(iNeuron) = any(dirSelNeuronsSO_ipsi_ntpIdx);
                end
                dirSelNeuronsSO(iNeuron) = dirSelNeuronsSO_contra(iNeuron) | dirSelNeuronsSO_ipsi(iNeuron);
                dirSelNeuronsSO_count = dirSelNeuronsSO_count + 1;
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
            curBins = squeeze(pNeuronDiff(iNeuron,curEvent,:));
            curBins_neg = squeeze(pNeuronDiff_neg(iNeuron,curEvent,:));
            eventBins = eventBins + (curBins > pVal)';
            eventBins_neg = eventBins_neg + (curBins_neg > pVal)';
            showUnitClass = [1:7];
            for curUnitClass = showUnitClass
                if curUnitClass == primSec(iNeuron,1)
                    eventBins_class(curUnitClass,:) = eventBins_class(curUnitClass,:) + (curBins > pVal)';
                    eventBins_neg_class(curUnitClass,:) = eventBins_neg_class(curUnitClass,:) + (curBins_neg > pVal)';
                end
            end
        end
    end
    
%     yyaxis left;
    bar(1:size(pNeuronDiff,3),eventBins/size(pNeuronDiff,1),'FaceColor',colors(1,:),'EdgeColor',colors(1,:)); % POSITIVE
    hold on;
    bar(1:size(pNeuronDiff_neg,3),-eventBins_neg/size(pNeuronDiff_neg,1),'FaceColor',colors(2,:),'EdgeColor',colors(2,:)); % POSITIVE
    ylim([-.15 .15]);
    
% % % %     yyaxis right;
% % %     class_colors = jet(8);
% % % %     class_colors(3,:) = [1 1 0];
% % % %     class_colors(4,:) = [0 1 0];
% % %     class_lns = [];
% % %     class_lns_ii = 1;
% % %     for iClass = 1:7
% % %         class_lns(class_lns_ii) = plot(1:size(pNeuronDiff,3),eventBins_class(iClass,:)/size(pNeuronDiff,1),'-','color',class_colors(iClass,:),'lineWidth',2);
% % %         plot(1:size(pNeuronDiff,3),-eventBins_neg_class(iClass,:)/size(pNeuronDiff,1),'-','color',class_colors(iClass,:),'lineWidth',2);
% % %         class_lns_ii = class_lns_ii + 1;
% % %     end
% % % %     ylim([-1 1]);
    
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