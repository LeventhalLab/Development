% the fraction of units whose activity is significantly different between
% ipsi/contra trials
doSetup = false;
doSave = false;
doLabels = true;
dodebug = false;
doPies = true;
debugPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/ipsiContraShuffleDebug';
pVal = 0.99;
pVal_minBins = 2;
colors = lines(2);
dirSelType = 'NO'; % NO or SO
useIncorrect = false;
nSmooth = 3;
requireTrials = 3;
minFR = 0;
nShuffle = 1000;
subplotMargins = [.05 .02];
tWindow = 1;
binMs = 20;

if ismac
    localSideOutPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/sideOutAnalysis';
else
    localSideOutPath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\sideOutAnalysis';
end

excludeSessions = {'R0117_20160504a','R0142_20161207a','R0117_20160508a','R0117_20160510a'}; % corrupt video
[sessionNames,IA] = unique(analysisConf.sessionNames);

if doSetup
    useEvents = 1:7;
    binS = binMs / 1000;
    binEdges = -tWindow:binS:tWindow;
%     analyzeRange = (tWindow / binS) : (tWindow / binS) + (0.25 / binS);
    analyzeRange = (tWindow / binS) - (0.2 / binS) : (tWindow / binS) + (0.4 / binS);
    % init to p = 0.5 (N.S.)
    pNeuronDiff = nan(numel(analysisConf.neurons),numel(useEvents),numel(binEdges)-1);
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
    
    all_matrixDiff = NaN(numel(analysisConf.neurons),7,100);
    all_matrixDiffZ = NaN(numel(analysisConf.neurons),7,100);
    all_contraZ = NaN(numel(analysisConf.neurons),7,100);
    all_ipsiZ = NaN(numel(analysisConf.neurons),7,100);
    all_bothZ = NaN(numel(analysisConf.neurons),7,100);
    all_ntpIdx = NaN(numel(analysisConf.neurons),1);
    SIcorr_SI = [];
    SIcorr_RT = [];
    SIcorr_MT = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        neuronName = analysisConf.neurons{iNeuron};
        disp(neuronName);
        
        if ismember(iNeuron,removeUnits)
            disp('REMOVE NEURON');
            continue;
        end
        
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
        if FR < minFR
            disp([num2str(iNeuron),' FR too low']);
            continue;
        end
% %         if any(isnan(primSec(iNeuron,:)))
% %              disp([num2str(iNeuron),' isnan']);
% %         end
        
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
        if dodebug
            h = figuree(1200,800);
        end
        for iEvent = 1:numel(useEvents)
            curPeths = tsPeths(:,iEvent);
            eventMatrix = [];
            for iTrial = 1:numel(curPeths)
                eventMatrix(iTrial,:) = histcounts(curPeths{iTrial},binEdges);
            end

            contraMean = smooth(mean(eventMatrix(trialClass == 1,:)),nSmooth);
            ipsiMean = smooth(mean(eventMatrix(trialClass == 0,:)),nSmooth);
            contraZ = smooth((mean(eventMatrix(trialClass == 1,:)) - mean2(eventMatrix(trialClass == 1,:))) ./ std(mean(eventMatrix(trialClass == 1,:))),nSmooth);
            ipsiZ = smooth((mean(eventMatrix(trialClass == 0,:)) - mean2(eventMatrix(trialClass == 0,:))) ./ std(mean(eventMatrix(trialClass == 0,:))),nSmooth);
            matrixDiff = contraMean - ipsiMean;
            matrixDiffZ = contraZ - ipsiZ;
% %             if iEvent == 4
% %                 htest = figure;
% %                 plot(contraZ,'lineWidth',2);
% %                 hold on;
% %                 plot(ipsiZ,'lineWidth',2);
% %                 plot(matrixDiffZ,'k-','lineWidth',2);
% %                 close(htest);
% %             end
            if ~any(matrixDiffZ) || any(isnan(matrixDiffZ))
                disp('all zeros');
            end
            
            all_matrixDiff(iNeuron,iEvent,:) = matrixDiff;
            all_matrixDiffZ(iNeuron,iEvent,:) = matrixDiffZ;
            
            all_ipsiZ(iNeuron,iEvent,:) = ipsiZ;
            all_contraZ(iNeuron,iEvent,:) = contraZ;
            all_bothZ(iNeuron,iEvent,:) = smooth((mean(eventMatrix) - mean2(eventMatrix)) ./ std(mean(eventMatrix)),nSmooth);
% %             matrixDiff = abs(contraMean - ipsiMean);
            matrixDiffShuffle = [];
            for iShuffle = 1:nShuffle
                shuffledTrialTypes = trialClass(randperm(numel(trialClass)));
% %                 contraMeanShuffled = smooth(mean(eventMatrix(shuffledTrialTypes == 1,:)),nSmooth);
% %                 ipsiMeanShuffled = smooth(mean(eventMatrix(shuffledTrialTypes == 0,:)),nSmooth);
% %                 matrixDiffShuffle(iShuffle,:) = contraMeanShuffled - ipsiMeanShuffled;
                contraZMeanShuffled = smooth((mean(eventMatrix(shuffledTrialTypes == 1,:)) - mean2(eventMatrix)) ./ std(mean(eventMatrix)),nSmooth);
                ipsiZMeanShuffled = smooth((mean(eventMatrix(shuffledTrialTypes == 0,:)) - mean2(eventMatrix)) ./ std(mean(eventMatrix)),nSmooth);
  
                matrixDiffShuffle(iShuffle,:) = contraZMeanShuffled - ipsiZMeanShuffled;
% %                 matrixDiffShuffle(iShuffle,:) = abs(contraMeanShuffled - ipsiMeanShuffled);
            end
            % how often is matrixDiff greater than matrixDiffShuffle?
            for iBin = 1:numel(matrixDiff)
                curMDS = matrixDiffShuffle(:,iBin);
% %                 pEventDiff(iEvent,iBin) = numel(find(matrixDiff(iBin) > curMDS)) / nShuffle;
                pEventDiff(iEvent,iBin) = numel(find(matrixDiffZ(iBin) > curMDS)) / nShuffle; % use Z
% %                 pEventDiff_neg(iEvent,iBin) = numel(find(matrixDiff(iBin) < curMDS)) / nShuffle;
            end
            
            doingSel = false;
            if (iEvent == 4 && strcmp(dirSelType,'NO')) || (iEvent == 6 && strcmp(dirSelType,'SO'))
                doingSel = true;
                
                dirSelNeurons_contra_ntpIdx = movsum(pEventDiff(iEvent,analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
                dirSelNeurons_ipsi_ntpIdx = movsum(pEventDiff(iEvent,analyzeRange) < 1-pVal,[0 pVal_minBins-1]) == pVal_minBins;
                all_ntpIdx(iNeuron) = sum(dirSelNeurons_contra_ntpIdx) + sum(dirSelNeurons_ipsi_ntpIdx); % event 4
                % whole window version
                dirSelNeurons_contra_ntpIdx_whole = movsum(pEventDiff(iEvent,:) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
                dirSelNeurons_ipsi_ntpIdx_whole = movsum(pEventDiff(iEvent,:) < 1-pVal,[0 pVal_minBins-1]) == pVal_minBins;
                all_ntpIdx_whole(iNeuron) = sum(dirSelNeurons_contra_ntpIdx_whole) + sum(dirSelNeurons_ipsi_ntpIdx_whole); % event 4

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
            end

            if dodebug
                rows = 6;
                cols = 8;
                lns = [];
                debugColors = lines(3);
                evDiff = pEventDiff(iEvent,:);
                contraIdx = find(evDiff > pVal);
                ipsiIdx = find(evDiff < 1-pVal);
                
                % row 1 ---
                subplot_tight(rows,cols,iEvent,subplotMargins);
                lns(1) = plot(contraMean,'lineWidth',2,'color',debugColors(1,:)); hold on;
                lns(2) = plot(ipsiMean,'lineWidth',2,'color',debugColors(2,:));
                lns(3) = plot(matrixDiff,'lineWidth',2,'color',debugColors(3,:));
                
                curUnitClass = primSec(iNeuron,1);
                if isnan(curUnitClass)
                    curUnitClass = 8;
                end
                if doingSel
                    plot([analyzeRange(1) analyzeRange(1)],ylim,'r--');
                    plot([analyzeRange(end) analyzeRange(end)],ylim,'r--');
                    title({['class: ',eventFieldlabelsNR{curUnitClass}],['dir: ',unitTypeLabel],eventFieldlabels{iEvent}});
                end
                
                if iEvent == 1
                    legend(lns,{'contra','ipsi','diff'},'location','northwest');
                    legend boxoff;
                    title({['Unit ',num2str(iNeuron)],eventFieldlabels{iEvent}});
                    ylabel('avg. spikes/bin');
                    use_ylims = ylim;
                    use_yticks = yticks;
                elseif ~doingSel
                    title({'',eventFieldlabels{iEvent}});
                end
                if iEvent ~= 1
                    ylim(use_ylims);
                    yticks(use_yticks);
                end
                xlim([1 numel(binEdges)-1]);
                xticks([1 round(numel(evDiff)/2) numel(evDiff)]);
                xticklabels({'-1','0','1'});
                grid on;
                
                % row 2 ---
                subplot_tight(rows,cols,iEvent+cols,subplotMargins);
                plot(evDiff,'k','lineWidth',2); hold on;
                plot(contraIdx,evDiff(contraIdx),'*','color',debugColors(1,:));
                plot(ipsiIdx,evDiff(ipsiIdx),'*','color',debugColors(2,:));
                
                if doingSel
                    plot(analyzeRange(dirSelNeurons_contra_ntpIdx),evDiff(analyzeRange(dirSelNeurons_contra_ntpIdx)),'o','color',debugColors(1,:),'markerSize',15);
                    plot(analyzeRange(dirSelNeurons_ipsi_ntpIdx),evDiff(analyzeRange(dirSelNeurons_ipsi_ntpIdx)),'o','color',debugColors(2,:),'markerSize',15);
                    plot([analyzeRange(1) analyzeRange(1)],ylim,'r--');
                    plot([analyzeRange(end) analyzeRange(end)],ylim,'r--');
                    title({['*p < ',num2str(1-pVal)],'circled meets detection'});
                end
                
                if iEvent == 1
                    ylabel('p');
                end
                xlim([1 numel(binEdges)-1]);
                xticks([1 round(numel(evDiff)/2) numel(evDiff)]);
                xticklabels({'-1','0','1'});
                ylim([-0.2 1.2]);
                yticks([0 1]);
                plot(xlim,[0 0],'k-');
                plot(xlim,[1 1],'k-');
                plot(xlim,[pVal pVal],'k--');
                plot(xlim,[1-pVal 1-pVal],'k--');
                grid on;
            end
        end
        if dodebug
            iSubplot = 17;
            iSubplot = plotTimingRaster(analysisConf,all_trials,all_ts,tWindow,eventFieldnames,iNeuron,iSubplot,rows,cols,subplotMargins);

            tightfig;
            set(h,'color','w');

            noteText = {['pVal: ',num2str(pVal)],['nSmooth: ',num2str(nSmooth)],['requireTrials: ',num2str(requireTrials)],...
                ['nShuffle: ',num2str(nShuffle)],['binMs: ',num2str(binMs)]};
            addNote(h,noteText);

            saveFile = ['debug',dirSelType,'_u',num2str(iNeuron,'%03d'),'_class-',eventFieldlabelsNR{curUnitClass},'_dir-',unitTypeLabel,'.pdf'];
            if doSave
                print(h,'-painters','-dpdf',fullfile(debugPath,saveFile));
            end
            close(h);
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

percentDirNeurons = 100 * (dirSelNO + dirSelSO) / (numel(dirSelUsedNeuronsNO_correct) + numel(dirSelUsedNeuronsSO_correct));

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

contra_NR = contra_x - (contra_contra + ipsi_contra)
ipsi_NR = ipsi_x - (ipsi_ipsi + contra_ipsi)
NR_ipsi = sum(~dirSelNeuronsNO & dirSelNeuronsSO_ipsi)
NR_contra = sum(~dirSelNeuronsNO & dirSelNeuronsSO_contra)

NRNO = sum(~dirSelNeuronsNO)
NRSO = sum(~dirSelNeuronsSO)
NR_NOSO = sum(~dirSelNeurons)

if doPies
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
    if doSave
        print(gcf,'-painters','-depsc',fullfile(figPath,'ipsiContraShuffle_codingNOSO.eps'));
    end

    figure;
    subplot_tight(1,2,1,subplotMargins);
    pie([sum(dirSelNeuronsNO_contra) sum(dirSelNeuronsNO_ipsi)]);
    colormap(lines(2));
    a = sum(dirSelNeuronsNO_contra);
    b = sum(dirSelNeuronsNO_ipsi);
    c = (a + b) / 2;
    d = c;
    [x2,p] = chiSquare(a,b,c,d)
    if doLabels
        title({'NO dirSel Unit Count',['p = ',num2str(1-p)]});
    end

    subplot_tight(1,2,2,subplotMargins);
    pie([sum(dirSelNeuronsSO_contra) sum(dirSelNeuronsSO_ipsi)]);
    colormap(lines(2));
    a = sum(dirSelNeuronsSO_contra);
    b = sum(dirSelNeuronsSO_ipsi);
    c = (a + b) / 2;
    d = c;
    [x2,p] = chiSquare(a,b,c,d)
    if doLabels
        title({'SO dirSel Unit Count',['p = ',num2str(1-p)]});
    end
    setFig('','',[1 0]);

    if doSave
        print(gcf,'-painters','-depsc',fullfile(figPath,'ipsiContraShuffle_NOSO-count.eps'));
    end
end

% see ipsiContraShuffle.m
% % useEvents = [4,6];
% % figuree(500,400);

% use ALL units?
% % % % minZ = 0;
% % % % [primSec,fractions] = primSecClass(unitEvents,minZ);

useEvents = 1:7;
h = figuree(1200,350);
all_eventBins = [];
neuron_eventBins = zeros(size(pNeuronDiff,1),1);
for iEvent = 1:numel(useEvents)
    curEvent = useEvents(iEvent);
    subplot_tight(1,numel(useEvents),iEvent,subplotMargins)
    eventBins = zeros(1,size(pNeuronDiff,3));
    eventBins_neg = zeros(1,size(pNeuronDiff,3));
% % % %     eventBins_class = zeros(8,size(pNeuronDiff_neg,3));
% % % %     eventBins_neg_class = zeros(8,size(pNeuronDiff_neg,3));
    for iNeuron = dirSelUsedNeurons
        curBins = squeeze(pNeuronDiff(iNeuron,curEvent,:));

        neuronSigEvent = (curBins > pVal)';
        eventBins = eventBins + neuronSigEvent; % this adds per-bin
        neuronSigEvent_neg = (curBins < 1-pVal)';
        eventBins_neg = eventBins_neg + neuronSigEvent_neg;

        if ismember(iEvent,[4])
            dirSelNeurons_contra_ntpIdx = movsum(curBins(analyzeRange) > pVal,[0 pVal_minBins-1]) == pVal_minBins;
            dirSelNeurons_ipsi_ntpIdx = movsum(curBins(analyzeRange) < 1-pVal,[0 pVal_minBins-1]) == pVal_minBins;
            neuron_eventBins(iNeuron) = neuron_eventBins(iNeuron) + sum(dirSelNeurons_contra_ntpIdx) + sum(dirSelNeurons_ipsi_ntpIdx);
        end
    end
%     yyaxis left;
    bar(1:size(pNeuronDiff,3),eventBins/numel(dirSelUsedNeurons),'FaceColor',colors(1,:),'EdgeColor',colors(1,:)); % contra
    hold on;
    bar(1:size(pNeuronDiff,3),-eventBins_neg/numel(dirSelUsedNeurons),'FaceColor',colors(2,:),'EdgeColor',colors(2,:)); % ipsi
    ylim([-.15 .15]);
    
    X = binoinv(pVal,numel(dirSelUsedNeuronsNO_correct),1-pVal) / numel(dirSelUsedNeuronsNO_correct);
    
    if iEvent == 4
        h2 = figure;
        plot(1:size(pNeuronDiff,3),(eventBins + eventBins_neg)/numel(dirSelUsedNeurons),'color','k'); % contra
        hold on;
        nSmooth = 1;
        plot(1:size(pNeuronDiff,3),smooth(eventBins/numel(dirSelUsedNeurons),nSmooth),'color',colors(1,:),'lineWidth',0.5); % contra
        plot(1:size(pNeuronDiff,3),smooth(-eventBins_neg/numel(dirSelUsedNeurons),nSmooth),'color',colors(2,:),'lineWidth',0.5); % ipsi
        nSmooth = 10;
        plot(1:size(pNeuronDiff,3),smooth(eventBins/numel(dirSelUsedNeurons),nSmooth),'color',colors(1,:),'lineWidth',1.5); % contra
        plot(1:size(pNeuronDiff,3),smooth(-eventBins_neg/numel(dirSelUsedNeurons),nSmooth),'color',colors(2,:),'lineWidth',1.5); % ipsi
        plot(xlim,[X X],'r');
        plot(xlim,[-X -X],'r');
        ylim([-.15 .3]);
        title('contra + ipsi');
        figure(h);
    end
    
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
    middleBin = round(size(pNeuronDiff,3)/2) + 0.5;
    xticks([1 middleBin size(pNeuronDiff,3)]);
    if doLabels
        xticklabels({'-1','0','1'});
        if iEvent == 1
            ylabel(['Fraction of DirSel units p < ',num2str(1-pVal,'%1.2f')]);
            yticks(ylim);
        else
            yticks([]);
        end
        if iEvent == 4
            xlabel('Time (s)');
        end
    else
        xticklabels([]);
        yticks(sort([ylim 0]));
        yticklabels([]);
    end
    
    % Given pVal, what fraction is due to chance?
    plot(xlim,[X X],'r');
    plot(xlim,[-X -X],'r');
    
    box off;
    grid on;
    
    % info
    disp(num2str(iEvent));
    contraPrct = eventBins/numel(dirSelUsedNeuronsNO_correct);
    contraExChance = find(contraPrct >= X,1,'first');
    disp(['exceeds chance at: ',num2str((contraExChance - round(size(pNeuronDiff,3)/2)) * binMs),' ms']);
    [v,k] = max(contraPrct);
    disp(['reaches max at: ',num2str((k - round(size(pNeuronDiff,3)/2)) * binMs),' ms']);
    disp(['max contra prct: ',num2str(v)]);
end

% % % % legend(class_lns,eventFieldlabels)
tightfig;
setFig('','',[2,1]);

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'ipsiContraShuffle.eps'));
    close(h);
end