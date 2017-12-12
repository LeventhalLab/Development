% the fraction of units whose activity is significantly different between
% ipsi/contra trials
dodebug = false;
debugPath = 'C:\Users\Administrator\Documents\Data\ChoiceTask\ipsiContraShuffleDebug';
pVal = 0.95;
pVal_minBins = 2;
colors = lines(2);
dirSelType = 'NO'; % NO or SO
useIncorrect = false;
nSmooth = 3;

if ismac
    localSideOutPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/sideOutAnalysis';
else
    localSideOutPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\sideOutAnalysis';
end

excludeSessions = {'R0117_20160504a','R0142_20161207a','R0117_20160508a','R0117_20160510a'}; % corrupt video
[sessionNames,IA] = unique(analysisConf.sessionNames);

if true
    useEvents = 1:7;
    binMs = 50;
    binS = binMs / 1000;
    binEdges = -tWindow:binS:tWindow;
    analyzeRange = (tWindow / binS) : (tWindow / binS) + (0.25 / binS);
    requireTrials = 5;
    nShuffle = 1000;
    % init to p = 0.5 (N.S.)
    pNeuronDiff = ones(numel(analysisConf.neurons),numel(useEvents),numel(binEdges)-1) * 0.5;
    pNeuronDiff_neg = [];

    dirSelNeurons_type = zeros(numel(analysisConf.neurons),1);
    dirSelNeurons = false(numel(analysisConf.neurons),1);
    dirSelNeurons_contra = false(numel(analysisConf.neurons),1);
    dirSelNeurons_ipsi = false(numel(analysisConf.neurons),1);
    dirSelNeurons_count = 0;

    dirSelUsedNeurons = [];
    if useIncorrect
        dirSelUsedNeurons_incorrect = [];
    else
        if strcmp(dirSelType,'NO')
            dirSelUsedNeuronsNO_correct = [];
        else
            dirSelUsedNeuronsSO_correct = [];
        end
    end
    for iNeuron = 1:numel(analysisConf.neurons)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        neuronName = analysisConf.neurons{iNeuron};
        disp(neuronName);
        
        curTrials = all_trials{iNeuron};
        
        if strcmp(dirSelType,'NO')
            trialIdInfo = organizeTrialsById(curTrials);
            if useIncorrect
                contraTrials = [trialIdInfo.incorrectContra];
                ipsiTrials = [trialIdInfo.incorrectIpsi];
            else
                contraTrials = [trialIdInfo.correctContra];
                ipsiTrials = [trialIdInfo.correctIpsi];
            end
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
        trialClass(1:numel(contraTrials)) = ones(numel(contraTrials),1); % contras are 1s

        % (ordered according to useTrials)
        tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow,eventFieldnames);
        FR = numel([tsPeths{:}]) / size(tsPeths,1) / size(tsPeths,2) / (tWindow * 2);
        if FR < 1
            disp([num2str(iNeuron),' FR too low']);
            continue;
        end
        
        if useIncorrect
            dirSelUsedNeurons_incorrect = [dirSelUsedNeurons_incorrect iNeuron];
        else
            if strcmp(dirSelType,'NO')
                dirSelUsedNeuronsNO_correct = [dirSelUsedNeuronsNO_correct iNeuron];
            else
                dirSelUsedNeuronsSO_correct = [dirSelUsedNeuronsSO_correct iNeuron];
            end
        end
        dirSelUsedNeurons = [dirSelUsedNeurons iNeuron];

        pEventDiff = [];
% %         pEventDiff_neg = [];
        for iEvent = 1:numel(useEvents)
            curPeths = tsPeths(:,iEvent);
            eventMatrix = [];
            for iTrial = 1:numel(curPeths)
                eventMatrix(iTrial,:) = histcounts(curPeths{iTrial},binEdges);
            end

            contraMean = smooth(mean(eventMatrix(trialClass == 1,:)),nSmooth);
            ipsiMean = smooth(mean(eventMatrix(trialClass == 0,:)),nSmooth);
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
% %                 pEventDiff_neg(iEvent,iBin) = numel(find(matrixDiff(iBin) < curMDS)) / nShuffle;
            end
            
            
            if (iEvent == 4 && strcmp(dirSelType,'NO')) || (iEvent == 6 && strcmp(dirSelType,'SO'))
                dirSelNeurons_contra_ntpIdx = movsum(pEventDiff(iEvent,analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
                dirSelNeurons_ipsi_ntpIdx = movsum(pEventDiff(iEvent,analyzeRange) < 1-pVal,[0 pVal_minBins-1]) == pVal_minBins;
                
                % designate contra or ipsi
                unitType = 0; % 0:none, 1:contra, 2:ipsi
                if any(dirSelNeurons_contra_ntpIdx)
                    if any(dirSelNeurons_ipsi_ntpIdx)
                        fcidx = find(dirSelNeurons_contra_ntpIdx == 1,1,'first');
                        fiidx = find(dirSelNeurons_ipsi_ntpIdx == 1,1,'first');
                        if fcidx < fiidx
                            unitType = 1; % contra unit!
                        else
                            unitType = 2; % ipsi unit!
                        end
                    else
                        unitType = 1; % contra unit!
                    end
                elseif any(dirSelNeurons_ipsi_ntpIdx)
                    unitType = 2; % ipsi unit!
                end
                
                unitTypeLabel = 'none';
                dirSelNeurons_type(iNeuron) = unitType;
                switch unitType
                    case 1
                        dirSelNeurons_contra(iNeuron) = 1;
                        dirSelNeurons_count = dirSelNeurons_count + 1;
                        unitTypeLabel = 'contra';
                    case 2
                        dirSelNeurons_ipsi(iNeuron) = 1;
                        dirSelNeurons_count = dirSelNeurons_count + 1;
                        unitTypeLabel = 'ipsi';
                end

                if dodebug
                    lns = [];
                    debugColors = lines(3);
                    evDiff = pEventDiff(iEvent,:);
                    contraIdx = find(evDiff > pVal);
                    ipsiIdx = find(evDiff < 1-pVal);
                    h = figuree(400,600);
                    subplot(211);
                    lns(1) = plot(contraMean,'lineWidth',2,'color',debugColors(1,:)); hold on;
                    lns(2) = plot(ipsiMean,'lineWidth',2,'color',debugColors(2,:));
                    lns(3) = plot(matrixDiff,'lineWidth',2,'color',debugColors(3,:));
                    
                    plot([analyzeRange(1) analyzeRange(1)],ylim,'r--');
                    plot([analyzeRange(end) analyzeRange(end)],ylim,'r--');
                    xlim([1 numel(binEdges)-1]);
                    ylabel('spikes/bin');
                    legend(lns,'contra','ipsi','diff');
                    title({['Unit ',num2str(iNeuron)],['dir: ',unitTypeLabel],['--',eventFieldlabels{iEvent},'--']});
                    
                    subplot(212);
                    plot(evDiff,'k','lineWidth',2); hold on;
                    plot(contraIdx,evDiff(contraIdx),'*','color',debugColors(1,:));
                    plot(ipsiIdx,evDiff(ipsiIdx),'*','color',debugColors(2,:));
                    plot(analyzeRange(dirSelNeurons_contra_ntpIdx),evDiff(analyzeRange(dirSelNeurons_contra_ntpIdx)),'o','color',debugColors(1,:),'markerSize',15);
                    plot(analyzeRange(dirSelNeurons_ipsi_ntpIdx),evDiff(analyzeRange(dirSelNeurons_ipsi_ntpIdx)),'o','color',debugColors(2,:),'markerSize',15);
                    
                    xlim([1 numel(binEdges)-1]);
                    xlabel('time');
                    ylim([-0.2 1.2]);
                    yticks([0 1]);
                    ylabel('p');
                    plot([analyzeRange(1) analyzeRange(1)],ylim,'r--');
                    plot([analyzeRange(end) analyzeRange(end)],ylim,'r--');
                    plot(xlim,[0 0],'k-');
                    plot(xlim,[1 1],'k-');
                    plot(xlim,[pVal pVal],'k--');
                    plot(xlim,[1-pVal 1-pVal],'k--');
                    
                    title({['*p < ',num2str(1-pVal)],'circled meets detection'});
                    set(gcf,'color','w');
                    saveFile = ['debug',dirSelType,'_u',num2str(iNeuron,'%03d'),'_dir-',unitTypeLabel,'.png'];
                    saveas(h,fullfile(debugPath,saveFile));
                    close(h);
                end
            end
        end
        pNeuronDiff(iNeuron,:,:) = pEventDiff;
% %         pNeuronDiff_neg(iNeuron,:,:) = pEventDiff_neg;
    end
    if strcmp(dirSelType,'NO')
        dirSelNeuronsNO = dirSelNeurons_contra | dirSelNeurons_ipsi;
        dirSelNeuronsNO_contra = dirSelNeurons_contra;
        dirSelNeuronsNO_ipsi = dirSelNeurons_ipsi;
        dirSelNeuronsNO_type = dirSelNeurons_type;
        dirSelNeuronsNO_count = dirSelNeurons_count;

    else
        dirSelNeuronsSO = dirSelNeurons_contra | dirSelNeurons_ipsi;
        dirSelNeuronsSO_contra = dirSelNeurons_contra;
        dirSelNeuronsSO_ipsi = dirSelNeurons_ipsi;
        dirSelNeuronsSO_type = dirSelNeurons_type;
        dirSelNeuronsSO_count = dirSelNeurons_count;
    end
end

dirSelNeurons = dirSelNeuronsNO | dirSelNeuronsSO;
dirSelNO = sum(dirSelNeuronsNO)
dirSelSO = sum(dirSelNeuronsSO)
dirSelNOSO = sum(dirSelNeurons)

percentDirNeurons = 100 * (dirSelNO + dirSelSO) / (dirSelUsedNeuronsNO_correct + dirSelUsedNeuronsSO_correct);

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

disp(['Codes SAME dir: ',num2str(contra_contra+ipsi_ipsi)]);
disp(['Codes DIFF dir: ',num2str(contra_ipsi+ipsi_contra)]);

figure;
pie([contra_contra+ipsi_ipsi contra_ipsi+ipsi_contra]);
legend('SAME','DIFF');
a = contra_contra+ipsi_ipsi;
b = contra_ipsi+ipsi_contra;
c = (a + b) / 2;
d = c;
[x2,p] = chiSquare(a,b,c,d);
title({'Coding between NO & SO',['p = ',num2str(1-p)]});
set(gcf,'color','w');

contra_NR = contra_x - (contra_contra + ipsi_contra)
ipsi_NR = ipsi_x - (ipsi_ipsi + contra_ipsi)
NR_ipsi = sum(~dirSelNeuronsNO & dirSelNeuronsSO_ipsi)
NR_contra = sum(~dirSelNeuronsNO & dirSelNeuronsSO_contra)

NRNO = sum(~dirSelNeuronsNO)
NRSO = sum(~dirSelNeuronsSO)
NR_NOSO = sum(~dirSelNeurons)

figure;
pie([sum(dirSelNeuronsNO_contra) sum(dirSelNeuronsNO_ipsi)]);
colormap(lines(2));
a = sum(dirSelNeuronsNO_contra);
b = sum(dirSelNeuronsNO_ipsi);
c = (a + b) / 2;
d = c;
[x2,p] = chiSquare(a,b,c,d);
title({'NO dirSel Unit Count',['p = ',num2str(1-p)]});
legend('Contra','Ipsi');
set(gcf,'color','w');


% see ipsiContraShuffle.m
% % useEvents = [4,6];
% % figuree(500,400);

% use ALL units?
% % % % minZ = 0;
% % % % [primSec,fractions] = primSecClass(unitEvents,minZ);

useEvents = 1:7;
figuree(1200,400);
all_eventBins = [];
for iEvent = 1:numel(useEvents)
    curEvent = useEvents(iEvent);
    subplot(1,numel(useEvents),iEvent)
    eventBins = zeros(1,size(pNeuronDiff,3));
    eventBins_neg = zeros(1,size(pNeuronDiff,3));
% % % %     eventBins_class = zeros(8,size(pNeuronDiff_neg,3));
% % % %     eventBins_neg_class = zeros(8,size(pNeuronDiff_neg,3));
    for iNeuron = 1:size(pNeuronDiff,1)
% %         if ~isempty(unitEvents{iNeuron}.class)%% && unitEvents{iNeuron}.class(1) == 3 % tone
            curBins = squeeze(pNeuronDiff(iNeuron,curEvent,:));
% % % %             curBins_neg = squeeze(pNeuronDiff_neg(iNeuron,curEvent,:));
            eventBins = eventBins + (curBins > pVal)';
            eventBins_neg = eventBins_neg + (curBins < 1-pVal)';

% % % %             showUnitClass = [1:7];
% % % %             for curUnitClass = showUnitClass
% % % %                 if curUnitClass == primSec(iNeuron,1)
% % % %                     eventBins_class(curUnitClass,:) = eventBins_class(curUnitClass,:) + (curBins > pVal)';
% % % %                     eventBins_neg_class(curUnitClass,:) = eventBins_neg_class(curUnitClass,:) + (curBins_neg > pVal)';
% % % %                 end
% % % %             end
% %         end
    end
    
%     yyaxis left;
    bar(1:size(pNeuronDiff,3),eventBins/numel(dirSelUsedNeuronsNO_correct),'FaceColor',colors(1,:),'EdgeColor',colors(1,:)); % contra
    hold on;
    bar(1:size(pNeuronDiff,3),-eventBins_neg/numel(dirSelUsedNeuronsNO_correct),'FaceColor',colors(2,:),'EdgeColor',colors(2,:)); % ipsi
    ylim([-.3 .3]);
    
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
    X = binoinv(pVal,numel(dirSelUsedNeuronsNO_correct),1-pVal) / numel(dirSelUsedNeuronsNO_correct);
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

% % % % legend(class_lns,eventFieldlabels)
set(gcf,'color','w');
tightfig;