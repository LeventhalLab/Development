function sideOutAnalysis_results(analysisConf,all_trials)

excludeSessions = {'R0142_20161207a','R0117_20160508a','R0117_20160510a'}; % corrupt video
[sessionNames,IA] = unique(analysisConf.sessionNames);
sessionCount = 0;

totalContraTrials = 0;
contraAgreementTrials = 0;
totalIpsiTrials = 0;
ipsiAgreementTrials = 0;

for iSession = 12:numel(sessionNames)
    sessionConf = analysisConf.sessionConfs{IA(iSession)};
    if ismember(sessionConf.sessions__name,excludeSessions)
        continue;
    end
    sessionCount = sessionCount + 1;
    leventhalPaths = buildLeventhalPathsv2(sessionConf);
    trials = all_trials{IA(iSession)};
    trialIdInfo = organizeTrialsById(trials);
    savePath = fullfile(leventhalPaths.graphs,'sideOutScreenshots');
    CSVpath = fullfile(savePath,[sessionConf.sessions__name,'_sideOutAnalysis.csv']);
    M = csvread(CSVpath);
    totalContraTrials = totalContraTrials + numel(trialIdInfo.correctContra);
    contraAgreementTrials = contraAgreementTrials + numel(find(M(trialIdInfo.correctContra) == 1));
    totalIpsiTrials = totalIpsiTrials + numel(trialIdInfo.correctIpsi);
    ipsiAgreementTrials = ipsiAgreementTrials + numel(find(M(trialIdInfo.correctIpsi) == 2));
end

y = [contraAgreementTrials,totalContraTrials-contraAgreementTrials;ipsiAgreementTrials,totalIpsiTrials-ipsiAgreementTrials];
figure;
bar(y,'stacked');
xticklabels({'contra','ipsi'});
title('Trial Type vs. Side Out Agreement');
ylabel('trials');