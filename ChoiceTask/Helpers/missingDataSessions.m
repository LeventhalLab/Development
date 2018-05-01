[C,ic] = unique(analysisConf.sessionNames);
% R0117_20160504a s7, 05a s8
% R0142_20161207a s16, 11a (1 trial) s20

dirOfTrials = [];
for iSession = 1:numel(C)
   iNeuron = ic(iSession); % first neuron in session
   sessionConf = analysisConf.sessionConfs{iNeuron};
   nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
   load(nexMatFile);
   logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
   logData = readLogData(logFile);
   curTrials = createTrialsStruct_simpleChoice(logData,nexStruct);
   
   nexStruct2 = fixMissingEvents(logData,nexStruct);
   
   orig_contra = numel(nexStruct.events{33,1}.timestamps);
   fix_contra = numel(nexStruct2.events{35,1}.timestamps);
   orig_ipsi = numel(nexStruct.events{33,1}.timestamps);
   fix_contra = numel(nexStruct2.events{35,1}.timestamps);
   
% %    trialIdInfo = organizeTrialsById(curTrials);
% %    contraTrials = [trialIdInfo.correctContra];
% %    ipsiTrials = [trialIdInfo.correctIpsi];
   dirOfTrials(iSession,:) = [orig_contra fix_contra orig_ipsi fix_contra];
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

subplot(211);
plot(dirOfTrials(:,3));
hold on;
plot(dirOfTrials(:,4));
legend({'ipsi orig','ipsi fix'});
xticks(1:size(dirOfTrials,1));
xticklabels(C);
set(gca,'TickLabelInterpreter','none');
xtickangle(90);

% R0117_20160504a s7, 05a s8
% R0142_20161207a s16, 11a (1 trial) s20