if false
    % let's see how many units per session we have
    sessionName = '';
    groupedNeurons = {};
    iSession = 0;
    for iNeuron = 1:numel(analysisConf.neurons)
        if strcmp(sessionName,analysisConf.sessionNames{iNeuron}) == 0
            sessionName = analysisConf.sessionNames{iNeuron};
            iSession = iSession + 1;
            groupedNeurons{iSession} = [];
        end
        groupedNeurons{iSession} = [groupedNeurons{iSession} iNeuron];
    end
    
    n = 8;
    criteraCount = 0;
    unitsPerSession = [];
    for iSession = 1:numel(groupedNeurons)
        unitsPerSession(iSession) = numel(groupedNeurons{iSession});
        if numel(groupedNeurons{iSession}) >= 8
            criteraCount = criteraCount + 1;
        end
    end
    disp(criteraCount);
    figure;
    histogram(unitsPerSession,100);
    ylabel('number of sessions');
    xlabel('units per session');
    set(gcf,'color','w');
end

doSetup = false;
iSession = 18;
groupNeurons = groupedNeurons{iSession};
sessionConf = analysisConf.sessionConfs{groupNeurons(1)};
neuronName = analysisConf.neurons{groupNeurons(1)};
nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
if doSetup
    load(nexMatFile);

    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    if strcmp(neuronName(1:5),'R0154')
        nexStruct = fixMissingEvents(logData,nexStruct);
    end
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    timingField = 'RT';
    [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
end

iEvent = 4;
tWindow = 1;

for iNeuron = 1:numel(inSession)
    tsPeths = eventsPeth(trials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
    z = zParams(ts,trials);
    % turn tsPethds into z-scores
    % ultimately: z-score x neuron for each trial (i.e. RT) x each time bin
    % bin
end



% % if FR < minFR
% %     disp([num2str(iNeuron),' FR too low']);
% %     continue;
% % end
        
% for iBin = 1:size(all_zscores,3)
%     figure;
%     plot(all_zscores(groupedNeurons{iSession},iEvent,iBin));
%     
% end