% function rtMtDist(analysisConf)
if false
    all_rt = [];
    all_rt_c = {};
    all_mt = [];
    all_mt_c = {};
    all_subjects__id = [];
    lastSession = '';
    iCount = 1;
    for iNeuron = 1:size(analysisConf.neurons,1)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if strcmp(sessionConf.sessions__name,lastSession)
            continue;
        end
        lastSession = sessionConf.sessions__name;
        logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
        logData = readLogData(logFile);
        neuronName = analysisConf.neurons{iNeuron};
        nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
        load(nexMatFile);
        if strcmp(neuronName(1:5),'R0154')
            nexStruct = fixMissingEvents(logData,nexStruct);
        end
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);

        timingField = 'RT';
        [trialIds,rt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_rt = [all_rt rt];
        all_rt_c{iCount} = rt;
        
        timingField = 'MT';
        [trialIds,mt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_mt = [all_mt mt];
        all_mt_c{iCount} = mt;
        
        all_subjects__id = [all_subjects__id sessionConf.subjects__id];
        iCount = iCount + 1;
    end
end
figure('position',[0 0 900 700]);

histInt = .02;
xlimVals = [0 1];
subplot(221);
[counts,centers] = hist(all_rt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
bar(centers,counts,'r');
xlabel('Reaction time (s)');
xlim(xlimVals);
ylabel('trials');
title(['RT Distribution, ',num2str(numel(all_rt)),' trials, ',num2str(histInt*1000),' ms bins']);
grid on;

[counts,centers] = hist(all_mt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
subplot(222);
bar(centers,counts,'b');
xlabel('Movement time (s)');
xlim(xlimVals);
ylabel('trials');
title(['MT Distribution, ',num2str(numel(all_mt)),' trials, ',num2str(histInt*1000),' ms bins']);
grid on;

% RT-MT correlation
subplot(223);
colors = jet(numel(all_mt_c));
for iSession = 1:numel(all_rt_c)
    plot(all_rt_c{iSession},all_mt_c{iSession},'.','color',colors(iSession,:),'MarkerSize',10);
    hold on;
end
grid on;
xlim(xlimVals);
ylim([.1 1]);
xlabel('RT (s)');
ylabel('MT (s)');
title(['by session, N = ',num2str(numel(all_mt_c))]);

subplot(224);
subjects__ids = unique(all_subjects__id);
colors = summer(numel(subjects__ids));
curSubject = all_subjects__id(1);
curColor = 1;
ln = [];
for iSession = 1:numel(all_subjects__id)
    if curSubject ~= all_subjects__id(iSession)
        curColor = curColor + 1;
        curSubject = all_subjects__id(iSession);
    end
    ln(curColor) = plot(all_rt_c{iSession},all_mt_c{iSession},'.','color',colors(curColor,:),'MarkerSize',10);
    hold on;
end
grid on;
xlim(xlimVals);
ylim([.1 1]);
xlabel('RT (s)');
ylabel('MT (s)');
title(['by subject, n = ',num2str(numel(subjects__ids))]);
legend(ln,num2str(subjects__ids(:)));