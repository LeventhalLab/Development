% directionally selectivity index
% Zleft-Zright / Zleft+Zright
% scatter for all units: Nose Out Y, Side Out X
analysisTitle = 'Tone Units';

localSideOutPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/sideOutAnalysis';
excludeSessions = {'R0117_20160504a','R0142_20161207a','R0117_20160508a','R0117_20160510a'}; % corrupt video
[sessionNames,IA] = unique(analysisConf.sessionNames);
neuronCount = 0;
tWindow = 1;
si_noseOut = [];
si_sideOut = [];
minTrials = 3;
analyzeRange = 10:30; % t = 0 - 0.5s
requireSpikes = 3; % per bin

binMs = 50;
binS = binMs / 1000;
% 0.5 seconds after event
analyzeRange = (tWindow / binS) : (tWindow / binS) + (0.5 / binS);
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
%     if ~dirSelNeurons(iNeuron)
%         continue;
%     end
    CSVpath = fullfile(localSideOutPath,[sessionConf.sessions__name,'_sideOutAnalysis.csv']);
    M = csvread(CSVpath);
    % make sure enough ipsi/contra trials
    if sum(M == 1) < minTrials || sum(M == 2) < minTrials
        continue;
    end
%     if ~ismember(primSec(iNeuron,1),3)
%         continue;
%     end
    
    neuronCount = neuronCount + 1;
% %     trials = all_trials{IA(iSession)};
% %     trialIdInfo = organizeTrialsById(trials);
    
    curTs = all_ts{iNeuron};
    curTrials = all_trials{iNeuron};
% %     z = zParams(curTs,curTrials);
% %     zBinMean = z.FRmean * (binMs/1000);
% %     zBinStd = z.FRstd * (binMs/1000);
    trialIdInfo = organizeTrialsById(curTrials);
    
    % tsPeths for all trial types
    tsPeths = eventsPeth(curTrials,curTs,tWindow,eventFieldnames);
    
    % --- Nose Out
    useTrials = trialIdInfo.correctContra;
    peths = [tsPeths{useTrials,4}];
    hCounts = histcounts(peths,nBins_tWindow);
    if any(hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    contra_score = smooth(hCounts / numel(useTrials),nSmooth);
    
    useTrials = trialIdInfo.correctIpsi;
    peths = [tsPeths{useTrials,4}];
    hCounts = histcounts(peths,nBins_tWindow);
    if any(hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    ipsi_score = smooth(hCounts / numel(useTrials),nSmooth);
%     si_noseOut(neuronCount,:) = ((contra_score - ipsi_score) ./ (contra_score + ipsi_score));
    si_noseOut(neuronCount,1) = max((contra_score(analyzeRange) - ipsi_score(analyzeRange)) ./ (contra_score(analyzeRange) + ipsi_score(analyzeRange)));
    
    useTrials = find(M == 1);
    peths = [tsPeths{useTrials,6}];
    hCounts = histcounts(peths,nBins_tWindow);
    if any(hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    contra_score = smooth(hCounts / numel(useTrials),nSmooth);
    
    useTrials = find(M == 2);
    peths = [tsPeths{useTrials,6}];
    hCounts = histcounts(peths,nBins_tWindow);
    if any(hCounts <= requireSpikes)
        neuronCount = neuronCount - 1;
        continue;
    end
    ipsi_score = smooth(hCounts / numel(useTrials),nSmooth);
%     si_sideOut(neuronCount,:) = ((contra_score - ipsi_score) ./ (contra_score + ipsi_score));
    si_sideOut(neuronCount,1) = max((contra_score(analyzeRange) - ipsi_score(analyzeRange)) ./ (contra_score(analyzeRange) + ipsi_score(analyzeRange)));
    
    scatter_colors(neuronCount,:) = [0 0 0];
    if dirSelNeurons(iNeuron)
        scatter_colors(neuronCount,:) = [1 0 0];
    end
    
    % skip if nan
    if isnan(si_noseOut(neuronCount,1)) || isnan(si_sideOut(neuronCount,1))
        neuronCount = neuronCount - 1;
        continue;
    end

% %     if any(ismember(primSec(iNeuron,:),4))
% %         scatter_colors(neuronCount,:) = [1 0 0];
% %     else
% %         scatter_colors(neuronCount,:) = [0 0 0];
% %     end
end

si_categories = zeros(size(si_sideOut));
si_categories(si_noseOut > 0 & si_sideOut > 0) = 1;
si_categories(si_noseOut > 0 & si_sideOut < 0) = 2;
si_categories(si_noseOut < 0 & si_sideOut > 0) = 3;
si_categories(si_noseOut < 0 & si_sideOut < 0) = 4;
[h,pVal] = chi2gof(si_categories,'NBins',4)

figuree(300,600);
subplot(211);
scatter(si_noseOut,si_sideOut,30,scatter_colors,'filled');
xlabel('si Nose Out');
ylabel('si Side Out');
xlim([-1 1]);
ylim([-1 1]);
xticks([-1 0 1]);
yticks([-1 0 1]);
grid on;
title(analysisTitle)
setFig;

subplot(212);
labels = {'NO & SO > 0','NO > 0 & SO < 0','NO < 0 & SO > 0','NO & SO < 0'};
si_quadrants = histcounts(si_categories,4);
explode = [1 1 1 1];
p = pie(si_quadrants,explode,labels);
p(1).FaceColor = [1 0 0];
p(3).FaceColor = repmat(0.5,1,3);
p(5).FaceColor = p(3).FaceColor;
p(7).FaceColor = p(3).FaceColor;
title(['p = ',num2str(pVal)]);
setFig;