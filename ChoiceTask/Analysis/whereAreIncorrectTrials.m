yLabels = {};
colors = lines(7);
figuree(900,400);
iSessions = 0;
lastSession = '';
lns = [];
lns_t = [];
for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);
    sessionConf = analysisConf.sessionConfs{iNeuron};
    if strcmp(lastSession,sessionConf.sessions__name)
        continue;
    end
    iSessions = iSessions + 1;
    lastSession = sessionConf.sessions__name;
    yLabels{iSessions} = sessionConf.sessions__name;
    
    markerSize = 13;
    hold on;
    lns_t = plot(trialIdInfo.correctContra,repmat(iSessions,[numel(trialIdInfo.correctContra),1]),'.','MarkerSize',markerSize,'color',colors(1,:));
    if ~isempty(lns_t)
        lns(1) = lns_t(1);
    end
    lns_t = plot(trialIdInfo.correctIpsi,repmat(iSessions,[numel(trialIdInfo.correctIpsi),1]),'.','MarkerSize',markerSize,'color',colors(6,:));
    if ~isempty(lns_t)
        lns(2) = lns_t(1);
    end
    lns_t = plot(trialIdInfo.incorrectContra,repmat(iSessions,[numel(trialIdInfo.incorrectContra),1]),'.','MarkerSize',markerSize,'color',colors(2,:));
    if ~isempty(lns_t)
        lns(3) = lns_t(1);
    end
    lns_t = plot(trialIdInfo.incorrectIpsi,repmat(iSessions,[numel(trialIdInfo.incorrectIpsi),1]),'.','MarkerSize',markerSize,'color',colors(7,:));
    if ~isempty(lns_t)
        lns(4) = lns_t(1);
    end
end
yticks([1:numel(analysisConf.neurons)]);
yticklabels(yLabels);
set(gca,'TickLabelInterpreter','none');
legend(lns,{'correctContra','correctIpsi','incorrectContra','incorrectIpsi'});