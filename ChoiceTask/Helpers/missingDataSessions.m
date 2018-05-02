[C,ic] = unique(analysisConf.sessionNames);
% R0117_20160504a s7, 05a s8
% R0142_20161207a s16, 11a (1 trial) s20

dirOfTrials = [];
for iSession = 10%1:numel(C)
    disp(num2str(iSession));
    iNeuron = ic(iSession); % first neuron in session
    sessionConf = analysisConf.sessionConfs{iNeuron};
    nexMatFile = fixNasPath([sessionConf.leventhalPaths.nex,'.mat']);
    load(nexMatFile);
    dataDir = fixNasPath(sessionConf.leventhalPaths.rawdata);
    logFile = getLogPath(dataDir);
    
    logFile = fixNasPath(logFile);
    logData = readLogData(logFile);
    curTrials = createTrialsStruct_simpleChoice(logData,nexStruct);
    trialIdInfo = organizeTrialsById(curTrials);
    
    nexStruct2 = fixMissingEvents(logData,nexStruct);
    curTrials2 = createTrialsStruct_simpleChoice(logData,nexStruct2);
    trialIdInfo2 = organizeTrialsById(curTrials2);
    
    fix_contra = numel(trialIdInfo2.correctContra);
    fix_ipsi = numel(trialIdInfo2.correctIpsi);
    try
        orig_contra =  numel(trialIdInfo.correctContra);
        orig_ipsi =  numel(trialIdInfo.correctIpsi);
    catch ME
        orig_contra = NaN;
        orig_ipsi = NaN;
    end

    
    contraTrials = [trialIdInfo.correctContra];
    ipsiTrials = [trialIdInfo.correctIpsi];
    dirOfTrials(iSession,:) = [orig_contra fix_contra orig_ipsi fix_ipsi];
end

figure;
subplot(211);
plot(dirOfTrials(:,1));
hold on;
plot(dirOfTrials(:,2));
legend({'contra orig','contra fix'});
xticks(1:size(dirOfTrials,1));
xticklabels(C);
set(gca,'TickLabelInterpreter','none');
xtickangle(90);
ylim([1 80]);

subplot(212);
plot(dirOfTrials(:,3));
hold on;
plot(dirOfTrials(:,4));
legend({'ipsi orig','ipsi fix'});
xticks(1:size(dirOfTrials,1));
xticklabels(C);
set(gca,'TickLabelInterpreter','none');
xtickangle(90);
ylim([1 80]);

% R0117_20160504a s7, 05a s8
% R0142_20161207a s16, 11a (1 trial) s20