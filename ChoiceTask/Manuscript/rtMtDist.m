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
        
%         corrIdx = find(logData.outcome == 0);
%         corrIdx_trials = find([trials(:).correct] == 1);
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);

        timingField = 'RT';
        [trialIds,rt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_rt = [all_rt rt];
        all_rt_c{iCount} = rt;
        mt = [];
        for iTrial = 1:numel(trialIds)
            curTrial = trialIds(iTrial);
            mt(iTrial) = getfield(trials(curTrial).timing,'MT');
        end
        all_mt = [all_mt mt];
        all_mt_c{iCount} = mt;
        
        all_subjects__id = [all_subjects__id sessionConf.subjects__id];
        iCount = iCount + 1;
        disp(['Session: ',num2str(iCount)]);
    end
end

% let's try per-subject RT/MT line histograms
RTcounts = [];
histInt = .01;
xlimVals = [0 1];
subjects__ids = unique(all_subjects__id);
RTcounts = [];
MTcounts = [];
nSmooth = 5;
for iSubject = 1:numel(subjects__ids)
    curSubject = subjects__ids(iSubject);
    curRTsessions = all_rt_c(all_subjects__id == curSubject);
    curRT = [curRTsessions{:}];
    curMTsessions = all_mt_c(all_subjects__id == curSubject);
    curMT = [curMTsessions{:}];
    [counts,~] = hist(curRT,[xlimVals(1):histInt:xlimVals(2)]+histInt);
    RTcounts(iSubject,:) = smooth(interp(normalize(counts),nSmooth),nSmooth);
    [counts,~] = hist(curMT,[xlimVals(1):histInt:xlimVals(2)]+histInt);
    MTcounts(iSubject,:) = smooth(interp(normalize(counts),nSmooth),nSmooth);
end

% looks like trash, deprecate
% % figure;
% % plot(RTcounts','lineWidth',2);
% % 
% % figure;
% % plot(MTcounts','lineWidth',2);

nSmooth = 5;
lineWidth = 4;
adjLabel = 15;
h = figuree(600,300);
[rt_counts,rt_centers] = hist(all_rt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
[mt_counts,mt_centers] = hist(all_mt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
x = interp(rt_centers,nSmooth);
y = abs(interp(rt_counts,nSmooth));
% % lns_rt = colormapline(x,y,[],cool(1000));
% % set(lns_rt,'lineWidth',lineWidth);
plot(x,y,'k','lineWidth',lineWidth);
hold on;
[v,k] = max(y);
text(x(k),v + adjLabel,'RT','fontSize',16,'HorizontalAlignment','Center');
x = interp(mt_centers,nSmooth);
y = abs(interp(mt_counts,nSmooth));
% % lns_mt = colormapline(x,y,[],summer(1000));
% % set(lns_mt,'lineWidth',lineWidth);
lns = plot(x,y,'k','lineWidth',lineWidth);
[v,k] = max(y);
text(x(k),v + adjLabel,'MT','fontSize',16,'HorizontalAlignment','Center');
ylim([0 220]);
yticks(ylim);
xlim([0 1]);
xticks(xlim);
setFig('Time (s)','Trials');

exportEPS(h,figPath,'RTMT_distribution');

figuree(1200,250);
cols = 3;

histInt = .01;
xlimVals = [0 1];
subplot(1,cols,1);
[counts,centers] = hist(all_rt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
bar(centers,counts,'faceColor','k','edgeColor','k');
xlabel('RT (s)');
xlim(xlimVals);
xticks(xlimVals);
ylim([0 200]);
yticks(ylim);
ylabel('trials');
set(gca,'fontSize',16);
% title(['RT Distribution, ',num2str(numel(all_rt)),' trials, ',num2str(histInt*1000),' ms bins']);

[counts,centers] = hist(all_mt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
subplot(1,cols,2);
bar(centers,counts,'faceColor','k','edgeColor','k');
xlabel('MT (s)');
xlim(xlimVals);
xticks(xlimVals);
ylim([0 200]);
yticks(ylim);
ylabel('trials');
set(gca,'fontSize',16);
% title(['MT Distribution, ',num2str(numel(all_mt)),' trials, ',num2str(histInt*1000),' ms bins']);

subplot(1,cols,3);
subjects__ids = unique(all_subjects__id);
colors = lines(numel(subjects__ids));
curSubject = all_subjects__id(1);
curColor = 1;
lns = [];
for iSession = 1:numel(all_subjects__id)
    if curSubject ~= all_subjects__id(iSession)
        curColor = curColor + 1;
        curSubject = all_subjects__id(iSession);
    end
    plot(all_rt_c{iSession},all_mt_c{iSession},'.','color',colors(curColor,:),'MarkerSize',10);
    hold on;
end
for iSubject = 1:numel(subjects__ids)
    lns(iSubject) = plot(-1,-1,'.','color',colors(iSubject,:),'MarkerSize',40);
end
xlim(xlimVals);
xticks(xlimVals);
ylim([0 1]);
yticks(ylim);
xlabel('RT (s)');
ylabel('MT (s)');
% title(['by subject, n = ',num2str(numel(subjects__ids))]);
% % legend(lns,num2str(subjects__ids(:)));
% % legend boxoff;
set(gca,'fontSize',16);

if cols > 3
    % RT-MT correlation
    subplot(1,cols,4);
    colors = jet(numel(all_mt_c));
    for iSession = 1:numel(all_rt_c)
        plot(all_rt_c{iSession},all_mt_c{iSession},'.','color',colors(iSession,:),'MarkerSize',10);
        hold on;
    end
    grid on;
    xlim(xlimVals);
    ylim([0 1]);
    xlabel('RT (s)');
    ylabel('MT (s)');
    title(['by session, N = ',num2str(numel(all_mt_c))]);
    set(gca,'fontSize',16);
end

set(gcf,'color','w');
tightfig;
