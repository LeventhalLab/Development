% function rtMtDist(analysisConf)
if false
    all_rt = [];
    all_mt = [];
    lastSession = '';
    for iNeuron = 1:size(analysisConf.neurons,1)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if strcmp(sessionConf.sessions__name,lastSession)
            continue;
        end
        lastSession = sessionConf.sessions__name;
        logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
        logData = readLogData(logFile);
        neuronName = analysisConf.neurons{iNeuron};
        if strcmp(neuronName(1:5),'R0154')
            nexStruct = fixMissingEvents(logData,nexStruct);
        end
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);

        timingField = 'RT';
        [trialIds,rt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_rt = [all_rt rt];

        timingField = 'MT';
        [trialIds,mt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_mt = [all_mt mt];
    end
end


histInt = .02;
xlimVals = [0 1];
figure('position',[0 0 900 300]);
subplot(121);
[counts,centers] = hist(all_rt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
bar(centers,counts,'r');
xlabel('Reaction time (s)');
xlim(xlimVals);
ylabel('trials');
title(['RT Distribution, ',num2str(numel(all_rt)),' trials, ',num2str(histInt*1000),' ms bins']);

[counts,centers] = hist(all_mt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
subplot(122);
bar(centers,counts,'b');
xlabel('Movement time (s)');
xlim(xlimVals);
ylabel('trials');
title(['MT Distribution, ',num2str(numel(all_mt)),' trials, ',num2str(histInt*1000),' ms bins']);