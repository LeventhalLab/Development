% directionally selectivity index
% Zleft-Zright / Zleft+Zright
% scatter for all units: Nose Out Y, Side Out X
analysisTitle = 'Dir Units';
doplot = true;

if ismac
    localSideOutPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/sideOutAnalysis';
    localExportPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/sideOutAnalysis/_export';
else
    localSideOutPath = 'C:\Users\Administrator\Documents\Data\ChoiceTask\sideOutAnalysis';
%     localExportPath = 'C:\Users\Administrator\Documents\Data\ChoiceTask\sideOutAnalysis\_export';
    localExportPath = 'C:\Users\Administrator\Documents\Data\ChoiceTask\sideOutAnalysis\_exportndir';
end
% % localExportPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/sideOutAnalysis/_exportndir';
excludeSessions = {'R0117_20160504a','R0142_20161207a','R0117_20160508a','R0117_20160510a'}; % corrupt video
[sessionNames,IA] = unique(analysisConf.sessionNames);
neuronCount = 0;
tWindow = 1;
si_noseOut = [];
si_sideOut = [];
minTrials = 3;
% analyzeRange = 10:30; % t = 0 - 0.5s
requireSpikes = 1; % per bin

binMs = 20;
binS = binMs / 1000;
% 0.5 seconds after event
analyzeRange_noseOut = (tWindow / binS) : (tWindow / binS) + (0.25 / binS);
analyzeRange_sideOut = (tWindow / binS) : (tWindow / binS) + (0.5 / binS);
nBins_tWindow = [-tWindow:binS:tWindow];
nSmooth = 3;

% si_noseOut = zeros(numel(analysisConf.neurons),1);
% si_sideOut = zeros(numel(analysisConf.neurons),1);

% colors = parula(8);
scatter_colors = []; %zeros(numel(analysisConf.neurons),3);
for iNeuron = 1:numel(analysisConf.neurons)
    sessionConf = analysisConf.sessionConfs{iNeuron};
    if ismember(sessionConf.sessions__name,excludeSessions)
        continue;
    end
    % dirSel units
%     if ~dirSelNeurons(iNeuron)
%         continue;
%     end
%     ~dirSel units
    if dirSelNeurons(iNeuron)
        continue;
    end
    
    CSVpath = fullfile(localSideOutPath,[sessionConf.sessions__name,'_sideOutAnalysis.csv']);
    M = csvread(CSVpath);
    % make sure enough ipsi/contra trials
    if sum(M == 1) < minTrials || sum(M == 2) < minTrials
        continue;
    end
    % filter by class
% %     if ~ismember(primSec(iNeuron,1),4)
% %         continue;
% %     end
    
    neuronCount = neuronCount + 1;
    disp([num2str(neuronCount),': u',num2str(iNeuron)]);
% %     trials = all_trials{IA(iSession)};
% %     trialIdInfo = organizeTrialsById(trials);
    
    curTs = all_ts{iNeuron};
    curTrials = all_trials{iNeuron};
    z = zParams(curTs,curTrials);
    zBinMean = z.FRmean * (binMs/1000);
    zBinStd = z.FRstd * (binMs/1000);
    % skip if no counts, can't determine mean/std
    if zBinStd == 0 || zBinMean == 0
        continue;
    end
    
    trialIdInfo = organizeTrialsById(curTrials);
    
    % tsPeths for all trial types
    tsPeths = eventsPeth(curTrials,curTs,tWindow,eventFieldnames);
    
    % --- Nose Out
    noseOut_useTrials = trialIdInfo.correctContra;
    noseOut_hCounts = histcounts([tsPeths{noseOut_useTrials,4}],nBins_tWindow);
    if any(noseOut_hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    noseOut_contra_zscore = ((noseOut_hCounts / numel(noseOut_useTrials)) - zBinMean) / zBinStd;
    noseOut_contra_score = smooth(noseOut_hCounts ./ numel(noseOut_useTrials),nSmooth);
    
    noseOut_useTrials = trialIdInfo.correctIpsi;
    noseOut_hCounts = histcounts([tsPeths{noseOut_useTrials,4}],nBins_tWindow);
    if any(noseOut_hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    noseOut_ipsi_zscore = ((noseOut_hCounts / numel(noseOut_useTrials)) - zBinMean) / zBinStd;
    noseOut_ipsi_score = smooth(noseOut_hCounts ./ numel(noseOut_useTrials),nSmooth);
    
%     si_noseOut(neuronCount,:) = max((contra_zscore - ipsi_zscore) ./ (contra_zscore + ipsi_zscore));
%     si_noseOut_score = (noseOut_contra_zscore - noseOut_ipsi_zscore) / (abs(maxmag(noseOut_contra_zscore(analyzeRange_noseOut))) + abs(maxmag(noseOut_ipsi_zscore(analyzeRange_noseOut))));
    si_noseOut_score = (noseOut_contra_score - noseOut_ipsi_score) ./ (noseOut_contra_score + noseOut_ipsi_score);
    si_noseOut_score_range = si_noseOut_score(analyzeRange_noseOut);
    noseOutMax = maxmag(si_noseOut_score_range);
%     noseOutMax = mean(si_noseOut_score_range);
    si_noseOut(neuronCount) = noseOutMax;
    
    sideOut_useTrials = find(M == 1);
    sideOut_hCounts = histcounts([tsPeths{sideOut_useTrials,6}],nBins_tWindow);
    if any(sideOut_hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    sideOut_contra_zscore = ((sideOut_hCounts / numel(sideOut_useTrials)) - zBinMean) / zBinStd;
    sideOut_contra_score = smooth(sideOut_hCounts ./ numel(sideOut_useTrials),nSmooth);
    
    sideOut_useTrials = find(M == 2);
    sideOut_hCounts = histcounts([tsPeths{sideOut_useTrials,6}],nBins_tWindow);
    if any(sideOut_hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    sideOut_ipsi_zscore = ((sideOut_hCounts / numel(sideOut_useTrials)) - zBinMean) / zBinStd;
    sideOut_ipsi_score = smooth(sideOut_hCounts ./ numel(sideOut_useTrials),nSmooth);
    
%     si_sideOut(neuronCount,:) = max((contra_zscore - ipsi_zscore) ./ (contra_zscore + ipsi_zscore));
%     si_sideOut_score = (sideOut_contra_zscore - sideOut_ipsi_zscore) / (abs(maxmag(sideOut_contra_zscore(analyzeRange_sideOut))) + abs(maxmag(sideOut_ipsi_zscore(analyzeRange_sideOut))));
    si_sideOut_score = (sideOut_contra_score - sideOut_ipsi_score) ./ (sideOut_contra_score + sideOut_ipsi_score);
    si_sideOut_score_range = si_sideOut_score(analyzeRange_sideOut);
    sideOutMax = maxmag(si_sideOut_score_range);
%     sideOutMax = mean(si_sideOut_score_range);
    si_sideOut(neuronCount) = sideOutMax;
    
%     if noseOutMax > 0.25 && sideOutMax < -0.25
%         disp('here');
%     end
    
    scatter_colors(neuronCount,:) = [1 0 0];
    if dirSelNeurons(iNeuron)
        scatter_colors(neuronCount,:) = [0 0 0];
    end
    
    % skip if nan
    if isnan(si_noseOut(neuronCount)) || isnan(si_sideOut(neuronCount))
        neuronCount = neuronCount - 1;
        continue;
    end
    
    if doplot
        h = figuree(300,600);
        subplot(211);
        lns = [];
        lns(1) = plot(noseOut_contra_zscore,'lineWidth',3);
        hold on;
        lns(2) = plot(noseOut_ipsi_zscore,'lineWidth',3);
        lns(3) = plot(si_noseOut_score,'-','color',repmat(.5,1,3));
        title('Nose Out');
        ylabel('Z');
        ylim([-1.5 3]);
        yticks(sort([ylim -1 0 1]));
        xticks([1 round(numel(noseOut_contra_zscore)/2) numel(noseOut_contra_zscore)]);
        xticklabels([-1 0 1]);
        plot([min(analyzeRange_noseOut) min(analyzeRange_noseOut)],ylim,'r--');
        plot([max(analyzeRange_noseOut) max(analyzeRange_noseOut)],ylim,'r--');
        legend(lns,{'Contra','Ipsi','Si'},'location','northwest');
        legend boxoff;
        grid on;
        setFig;

        subplot(212);
        lns = [];
        lns(1) = plot(sideOut_contra_zscore,'lineWidth',3);
        hold on;
        lns(2) = plot(sideOut_ipsi_zscore,'lineWidth',3);
        lns(3) = plot(si_sideOut_score,'-','color',repmat(.5,1,3));
        title('Side Out');
        ylabel('Z');
        ylim([-1.5 3]);
        yticks(sort([ylim -1 0 1]));
        xticks([1 round(numel(sideOut_contra_zscore)/2) numel(sideOut_contra_zscore)]);
        xticklabels([-1 0 1]);
        xlabel('time (s)');
        plot([min(analyzeRange_sideOut) min(analyzeRange_sideOut)],ylim,'r--');
        plot([max(analyzeRange_sideOut) max(analyzeRange_sideOut)],ylim,'r--');
        legend(lns,{'Contra','Ipsi','Si'},'location','northwest');
        legend boxoff;
        grid on;
        setFig;

        saveas(h,fullfile(localExportPath,['unit',num2str(iNeuron,'%03d'),'.png']));
        close(h);
    end
    
%     if neuronCount > 20
%         disp('here');
%     end

% %     if any(ismember(primSec(iNeuron,:),4))
% %         scatter_colors(neuronCount,:) = [1 0 0];
% %     else
% %         scatter_colors(neuronCount,:) = [0 0 0];
% %     end
end
% handle end case
si_noseOut = si_noseOut(1:neuronCount);
si_sideOut = si_sideOut(1:neuronCount);

si_categories = zeros(size(si_sideOut));
si_categories(si_noseOut > 0 & si_sideOut > 0) = 1;
si_categories(si_noseOut > 0 & si_sideOut < 0) = 2;
si_categories(si_noseOut < 0 & si_sideOut > 0) = 3;
si_categories(si_noseOut < 0 & si_sideOut < 0) = 4;
[h,pVal] = chi2gof(si_categories,'NBins',4)

% % figuree(800,700);
% % bar(mean(si_noseOut),'edgecolor','none','facealpha',0.5);
% % hold on;
% % bar(mean(si_sideOut),'edgecolor','none','facealpha',0.5);
% % xlim([1 size(si_sideOut,2)]);
% % xticks([1 round(size(si_sideOut,2)/2) size(si_sideOut,2)]);
% % xticklabels([-1 0 1]);
% % xlabel('Time (s) from Nose Out');
% % % ylim([-0.06 0.06]);
% % % yticks(ylim);
% % yax = ylabel('$$\overline{Si}$$');
% % set(yax,'interpreter','latex');
% % legend({'Nose Out Movement','Side Out Movement'},'location','northwest');
% % title(['Mean Selectivity Index ($$\overline{Si}$$) of DirSel Units (',num2str(size(si_sideOut,1)),') at Nose Out'],'interpreter','latex');
% % 
% % set(gcf,'color','w');
% % set(gca,'fontSize',16);
% % grid on;


figuree(300,600);
subplot(211);
scatter(si_noseOut,si_sideOut,30,scatter_colors,'filled');
xlabel('si Nose Out');
ylabel('si Side Out');
xlim([-1 1]);
ylim([-1 1]);
xticks(sort([xlim 0]));
yticks(sort([ylim 0]));
grid on;
title(analysisTitle)
setFig;

subplot(212);
labels = {'Contra/Contra','Contra/Ipsi','Ipsi/Contra','Ipsi/Ipsi'};
si_quadrants = histcounts(si_categories,4);
explode = [1 1 1 1];
p = pie(si_quadrants,explode,labels);
p(1).FaceColor = [1 0 0];
p(3).FaceColor = repmat(0.5,1,3);
p(5).FaceColor = p(3).FaceColor;
p(7).FaceColor = p(3).FaceColor;
title(['p = ',num2str(pVal)]);
setFig;