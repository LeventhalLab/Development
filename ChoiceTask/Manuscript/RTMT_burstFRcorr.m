doSetup = true;
timingField = 'RT';
limitToSide = 'N/A';
useDirSel = false;
nMeanBins = 10;
binMs = 20;
requireZ = 1.0;
areaUnderS = .200; % or within MT window?
tWindow = 1;
nSmoothz = 1;

useEventPeth = 3;
useNeuronClasses = [3];

if doSetup
    binS = binMs / 1000;
    binEdges = [-tWindow:binS:tWindow];
    all_curUseTime_sorted = [];
    trialCount = 1;
    allTrial_rasters = {};
    allTrial_z = [];
    allTrial_unitClasses = [];
    allTrial_useTime = [];
    
    allTrial_sessionNames = {};
    sessionCount = 0;
    lastSession = '';
    allTrial_sessionCount = [];
    
    allTrial_subjectNames = {};
    subjectCount = 0;
    lastSubject = '';
    allTrial_subjectCount = [];

    useSubject = analysisConf.subjects{iSubject};
    for iNeuron = 1:numel(analysisConf.neurons)
        if plotBySubject && ~strcmp(analysisConf.sessionConfs{iNeuron}.subjects__name,useSubject)
            continue;
        end

        neuronName = analysisConf.neurons{iNeuron};
        sessionName = analysisConf.sessionConfs{iNeuron}.sessions__name;
        subjectName = analysisConf.sessionConfs{iNeuron}.subjects__name;
        dirSelNote = 'NO';
        if useDirSel && ~dirSelNeurons(iNeuron)
            dirSelNote = 'YES';
            continue;
        end

        if ~ismember(unitClasses(iNeuron),useNeuronClasses)
            continue;
        end

        if unitEvents{iNeuron}.maxz(unitClasses(iNeuron)) <= requireZ
            continue;
        end

        disp(['Using neuron ',num2str(iNeuron),' (class=',num2str(unitClasses(iNeuron)),', maxz=',num2str(unitEvents{iNeuron}.maxz(unitClasses(iNeuron))),') ',neuronName]);

        curTrials = all_trials{iNeuron};
        [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
        trialIdInfo = organizeTrialsById(curTrials);

        t_useTrials = [];
        t_allTimes = [];
        tc = 1;
        for iTrial = 1:numel(useTrials)
            if ismember(useTrials(iTrial),trialIdInfo.correctContra)
                t_useTrials(tc) = useTrials(iTrial);
                t_allTimes(tc) = allTimes(iTrial);
                tc = tc + 1;
            end
        end
        markContraTrials = tc - 1;
        for iTrial = 1:numel(useTrials)
            if ismember(useTrials(iTrial),trialIdInfo.correctIpsi)
                t_useTrials(tc) = useTrials(iTrial);
                t_allTimes(tc) = allTimes(iTrial);
                tc = tc + 1;
            end
        end
        useTrials = t_useTrials;
        allTimes = t_allTimes;

        tsPeths = {};
        ts = all_ts{iNeuron};
        [tsISI,tsLTS,tsPoisson,tsPoissonLTS,ISI_n,LTS_n,poisson_n,poissonLTS_n] = tsBurstFilters(ts);
        % Poisson
        tsPoisson_inclusive = [];
        for iBurst = 1:numel(tsPoisson)
            tsPoisson_inclusive = [tsPoisson_inclusive;ts(tsPoisson(iBurst):tsPoisson(iBurst)+poisson_n(iBurst)-1)];
        end
        tsPeths_poisson = eventsPeth(curTrials(useTrials),tsPoisson_inclusive,tWindow,eventFieldnames);
        % LTS
        tsLTS_inclusive = [];
        for iBurst = 1:numel(tsLTS)
            tsLTS_inclusive = [tsLTS_inclusive;ts(tsLTS(iBurst):tsLTS(iBurst)+LTS_n(iBurst)-1)];
        end
        tsPeths_LTS = eventsPeth(curTrials(useTrials),tsLTS_inclusive,tWindow,eventFieldnames);

        z = zParams(ts,curTrials);
        zBinMean = z.FRmean * (binMs/1000);
        zBinStd = z.FRstd * (binMs/1000);
        tsPeths = eventsPeth(curTrials(useTrials),ts,tWindow,eventFieldnames);

        switch limitToSide
            case 'contra'
                usePeths = tsPeths(1:markContraTrials,:);
                useTimes = allTimes(1:markContraTrials);
            case 'ipsi'
                usePeths = tsPeths(markContraTrials+1:end,:);
                useTimes = allTimes(markContraTrials+1:end);
            otherwise                  
                usePeths = tsPeths;
                useTimes = allTimes;
        end

        curZ = [];
        for iTrial = 1:numel(useTimes)
            curTs = usePeths{iTrial,useEventPeth};
            if numel(curTs) < 3; continue; end;

            counts = histcounts(curTs,binEdges);
            curZ = smooth((counts - zBinMean) / zBinStd,3);
            allTrial_z(trialCount,:) = curZ;

            curUseTime = useTimes(iTrial);

            allTrial_useTime(trialCount) = curUseTime;
            allTrial_rasters{trialCount} = curTs;

            if ~strcmp(lastSession,sessionName)
                sessionCount = sessionCount + 1;
                lastSession = sessionName;
            end
            allTrial_sessionNames{trialCount} = sessionName;
            allTrial_sessionCount(trialCount) = sessionCount;

            if ~strcmp(lastSubject,subjectName)
                subjectCount = subjectCount + 1;
                lastSubject = subjectName;
            end
            allTrial_subjectNames{trialCount} = subjectName;
            allTrial_subjectCount(trialCount) = subjectCount;

            % !! if peth isempty() fill with NaN for raster?
            tempPeth = tsPeths_poisson{iTrial,useEventPeth};
            if isempty(tempPeth)
                allTrial_poissonPeths{trialCount} = NaN;
            else
                allTrial_poissonPeths{trialCount} = tempPeth;
            end
            tempPeth = tsPeths_LTS{iTrial,useEventPeth};
            if isempty(tempPeth)
                allTrial_LTSPeths{trialCount} = NaN;
            else
                allTrial_LTSPeths{trialCount} = tempPeth;
            end

            allTrial_unitClasses(trialCount) = unitClasses(iNeuron);
            trialCount = trialCount + 1;
        end
    end
end

% compile from per-subject
[v,k] = sort(allTrial_useTime);
all_curUseTime_sorted = [all_curUseTime_sorted vs];




% figure;
% plot(all_subjectCount(k),all_curUseTime_sorted,'.');

%  RT
h = figuree(1200,800);
rows = 2;
cols = 3;

subplot(rows,cols,1);
plot(all_curUseTime_sorted,1:numel(all_curUseTime_sorted),'k');
set(gca,'YDir','reverse');
ylim([1 numel(all_curUseTime_sorted)]);
xlim([0 1.5]);
xticks([0 0.25 0.5 0.75 1.05 1.35]);
xticklabels({'0','0.25','0.5','0.75','Subjects','Sessions'});
xlabel('time (s)');
title({[timingField,' where t0 ~> ',eventFieldnames{useEventPeth}],['units from: ',strjoin(eventFieldnames(useNeuronClasses),',')],[num2str(binMs),'ms bins, ',num2str(nMeanBins),' brackets'],['trial filter: ',limitToSide],['only dirSel? ',dirSelNote]});
ylabel('trials');
grid on;
hold on;

all_sessionCount_sorted = allTrial_sessionCount(k);
all_subjectCount_sorted = allTrial_subjectCount(k);
uniqueSessions = numel(unique(allTrial_sessionCount));
uniqueSubjects = numel(unique(allTrial_subjectCount));
sessionSpan = linspace(1.2,1.5,uniqueSessions);
subjectSpan = linspace(1,1.1,uniqueSubjects);
sessionColors = jet(uniqueSessions);
subjectColors = lines(uniqueSubjects);
for iTrial = 1:numel(all_curUseTime_sorted)
    curTime = all_curUseTime_sorted(iTrial);
    plot(sessionSpan(all_sessionCount_sorted(iTrial)),iTrial,'.','markerSize',1,'color',sessionColors(all_sessionCount_sorted(iTrial),:));
    plot(subjectSpan(all_subjectCount_sorted(iTrial)),iTrial,'.','markerSize',1,'color',subjectColors(all_subjectCount_sorted(iTrial),:));
end


% spike raster
subplot(rows,cols,2);
allRasters_sorted = allTrial_rasters(k);
allRasters_sorted_readable = makeRasterReadable(allRasters_sorted',15);
plotSpikeRaster(allRasters_sorted_readable,'PlotType','scatter','AutoLabel',false); hold on;
plot([0 0],[1 numel(allRasters_sorted)],'r:');
xlimVals = [-tWindow tWindow];
xlim(xlimVals);
xlabel('time (s)');
title([timingField,' spikes']);

% make mean z-score bins
meanBins = floor(linspace(1,numel(allRasters_sorted),nMeanBins+1));
makeyStart = floor(linspace((numel(allRasters_sorted)*.1),numel(allRasters_sorted)-(numel(allRasters_sorted)*.05),nMeanBins));
meanColors = cool(numel(meanBins)-1);
all_z_sorted = allTrial_z(k,:);
mean_z = [];
std_z = [];
meanCentersIdx = [];
xneg = [];
xpos = [];
area_z = [];
tMean = linspace(xlimVals(1),xlimVals(2),size(all_z_sorted,2));
for iBin = 1:numel(meanBins)-1
    mean_z(iBin,:) = mean(all_z_sorted(meanBins(iBin):meanBins(iBin+1),:));
    std_z(iBin,:) = std(all_z_sorted(meanBins(iBin):meanBins(iBin+1),:));
    meanCentersIdx(iBin) = round((meanBins(iBin) + meanBins(iBin+1)) / 2);
    
    areaIdxs = floor(numel(tMean)/2):find(tMean <= areaUnderS,1,'last');
    area_z(iBin) = trapz(mean_z(iBin,areaIdxs));
    % plot
    makey = (makeyStart(iBin) + mean_z(iBin,:) * -(numel(allRasters_sorted)*.1)); % -1 for orientation
    plot(tMean,makey,'linewidth',1.5,'color',[meanColors(iBin,:),0.9]);
end

% heatmap
subplot(rows,cols,3);
imagesc(all_z_sorted);
colormap(jet);
xticks([1 floor(size(all_z_sorted,2)/2) size(all_z_sorted,2)]);
xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
caxis([-1 5]);
title([timingField,' z-score']);
xlabel('time (s)');
colorbar;

maxIdxs = floor(size(all_z_sorted,2)/2):floor(size(all_z_sorted,2)/2)+floor(size(all_z_sorted,2)/4);
minIdxs = floor(size(all_z_sorted,2)/8):floor(size(all_z_sorted,2)/2);

% scatter all max z-scores
markerSize = 3;
subplot(rows,cols,4);
% yyaxis left;
lns = [];
[maxv,maxk] = max(all_z_sorted(:,maxIdxs)');
[minv,mink] = min(all_z_sorted(:,minIdxs)');
lns(1) = plot(all_curUseTime_sorted,maxv,'g.','MarkerSize',markerSize);
hold on;
lns(2) = plot(all_curUseTime_sorted,minv,'r.','MarkerSize',markerSize);
% ylim([-40 120]);
ylabel('trial z-score');
xlabel('time (s)');
legend(lns,{'max z ~t0','min z < t0'});
grid on;

yyaxis right;
lns(3) = plot(all_curUseTime_sorted+1,trapz(all_z_sorted(:,areaIdxs)'),'b.','MarkerSize',markerSize);
xlim([0 2]);
xticks([0 1 2]);
xticklabels({'0','1/0','1'});

[RHO_zxt,PVAL_zxt] = corr(all_curUseTime_sorted',maxv');
[RHO_axt,PVAL_axt] = corr(all_curUseTime_sorted',trapz(all_z_sorted(:,areaIdxs)')');
[RHO_zxz,PVAL_zxz] = corr(minv',maxv');
title({[timingField,' bracketed z-score'],...
    ['corr maxz x t = ',num2str(RHO_zxt),', p = ',num2str(PVAL_zxt)]...
    ['corr areaz (',num2str(areaUnderS),') x t = ',num2str(RHO_axt),', p = ',num2str(PVAL_axt)]...
    ['corr minz x maxz = ',num2str(RHO_zxz),', p = ',num2str(PVAL_zxz)]...
    });

legend(lns,{'max z ~t0','min z < t0',['z area <= ',num2str(areaUnderS)]});
% % plot(all_curUseTime_sorted,(maxk+(maxIdxs(1)-1)-20)*binMs,'.');
% % ylabel('max bin (ms)');

lns = [];
markerSize = 20;
subplot(rows,cols,5);
yyaxis left;
[maxv,maxk] = max(mean_z(:,maxIdxs)');
[minv,mink] = min(mean_z(:,minIdxs)');

errorbar(all_curUseTime_sorted(meanCentersIdx),maxv,mean(std_z'),mean(std_z'),...
    all_curUseTime_sorted(meanCentersIdx)-all_curUseTime_sorted(meanBins(1:end-1)),...
    all_curUseTime_sorted(meanBins(2:end))-all_curUseTime_sorted(meanCentersIdx),'.','Color',[.7 .7 .7]);
hold on;
lns(1) = plot(all_curUseTime_sorted(meanCentersIdx),maxv,'g.','MarkerSize',markerSize); hold on;
set(gca,'yColor','g');

% errorbar(all_curUseTime_sorted(meanCentersIdx),minv,mean(std_z'),mean(std_z'),...
%     all_curUseTime_sorted(meanCentersIdx)-all_curUseTime_sorted(meanBins(1:end-1)),...
%     all_curUseTime_sorted(meanBins(2:end))-all_curUseTime_sorted(meanCentersIdx),'.','Color',[.7 .7 .7]);
lns(2) = plot(all_curUseTime_sorted(meanCentersIdx),minv,'r.','MarkerSize',markerSize);

ylabel('min max z');
xlim([0 1]);
% ylim([-10 50]);
xlabel('time (s)');
grid on;

% hold on;
% [f,gof] = fit(all_curUseTime_sorted(meanBins(2:end))',maxv','exp2');
% plot(f,all_curUseTime_sorted(meanBins(2:end))',maxv');

yyaxis right;
lns(3) = plot(all_curUseTime_sorted(meanCentersIdx),area_z,'b.','MarkerSize',markerSize);
set(gca,'yColor','b');
ylabel('area z');

[RHO_zxt,PVAL_zxt] = corr(all_curUseTime_sorted(meanCentersIdx)',maxv');
[RHO_axt,PVAL_axt] = corr(all_curUseTime_sorted(meanCentersIdx)',area_z');
[RHO_zxz,PVAL_zxz] = corr(minv',maxv');
title({[timingField,' bracketed z-score'],...
    ['corr maxz x t = ',num2str(RHO_zxt),', p = ',num2str(PVAL_zxt)]...
    ['corr areaz (',num2str(areaUnderS),') x t = ',num2str(RHO_axt),', p = ',num2str(PVAL_axt)]...
    ['corr minz x maxz = ',num2str(RHO_zxz),', p = ',num2str(PVAL_zxz)]...
    });

legend(lns,{'max z ~t0','min z < t0',['z area <= ',num2str(areaUnderS)]});

% % plot(all_curUseTime_sorted(meanBins(2:end)),(maxk+(maxIdxs(1)-1)-20)*binMs,'.','MarkerSize',markerSize);
% % ylabel('max bin (ms)');
% % ylim([0 300]);

subplot(rows,cols,6);
legendText = {};
lns = [];

for ii = 1:size(mean_z,1)
    lns(ii) = plot(smooth(mean_z(ii,:),nSmoothz),'color',meanColors(ii,:));
    hold on;
    legendText{ii} = [num2str(all_curUseTime_sorted(meanCentersIdx(ii))),' ms'];
end
legend(lns,legendText,'Location','eastoutside');
xlim([1 size(all_z_sorted,2)]);
xticks([1 floor(size(all_z_sorted,2)/2) size(all_z_sorted,2)]);
xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
xlabel('time (s)');
grid on;
ylim([-1 2]);




% experimental
% prepare for raster
all_burstTs_sorted = all_burstTs(k);
for iTrial = 1:size(all_burstTs_sorted,2)
    spikevect = all_burstTs_sorted{iTrial};
    if isempty(spikevect)
        all_burstTs_sorted{iTrial} = NaN;
    end
end



% all ts and burst rasters
show200ms = false;
figuree(500,800);
subplot(211);
allRasters_sorted = allTrial_rasters(k);
allRasters_sorted_readable = makeRasterReadable(allRasters_sorted',20);
plotSpikeRaster(allRasters_sorted_readable,'PlotType','scatter','AutoLabel',false); hold on;
hold on;
if useEventPeth == 3
    toneLine = plot(all_curUseTime_sorted,1:numel(all_curUseTime_sorted),'g','linewidth',2);
    
elseif useEventPeth == 4
    toneLine = plot(0-all_curUseTime_sorted,1:numel(all_curUseTime_sorted),'g','linewidth',2);
end
plot([0 0],[1 numel(all_curUseTime_sorted)],'g:','linewidth',1);
if show200ms
    plot([-1 1],[find(all_curUseTime_sorted >= .200,1) find(all_curUseTime_sorted >= .200,1)],'y-');
    text(-1,find(all_curUseTime_sorted >= .200,1),'200 ms','BackgroundColor','y');
end
xlimVals = [-tWindow tWindow];
xlim(xlimVals);
ylabel('trials');
title({['e:',eventFieldlabels{useEventPeth},', s:',eventFieldlabels{useNeuronClasses}],'All Spikes'});
legend(toneLine,'Tone');
set(gca,'fontSize',16);

subplot(212)
[xPoints, yPoints] = plotSpikeRaster(all_burstTs_sorted,'PlotType','scatter','AutoLabel',false);
hold on;
if useEventPeth == 3
    toneLine = plot(all_curUseTime_sorted,1:numel(all_curUseTime_sorted),'g','linewidth',2);
elseif useEventPeth == 4
    toneLine = plot(0-all_curUseTime_sorted,1:numel(all_curUseTime_sorted),'g','linewidth',2);
end
plot([0 0],[1 numel(all_curUseTime_sorted)],'g:','linewidth',1);
if show200ms
    plot([-1 1],[find(all_curUseTime_sorted >= .200,1) find(all_curUseTime_sorted >= .200,1)],'y-');
    text(-1,find(all_curUseTime_sorted >= .200,1),'200 ms','BackgroundColor','y');
end
title({['e:',eventFieldlabels{useEventPeth},', s:',eventFieldlabels{useNeuronClasses}],'Only Bursts'});
xlabel('time (s)');
ylabel('trials');
set(gca,'fontSize',16);
set(gcf,'color','w');



% all brackets as colored lines
figure;
mean_burstHist = [];
mean_burstFraction = [];
% binEdges = linspace(-1,1,41);
nSmooth = 3;
legendText = {};
for iBin = 1:numel(meanBins)-1
    curTsBurst = [all_burstTs_sorted{meanBins(iBin):meanBins(iBin+1)}];
    curTs = [allRasters_sorted{meanBins(iBin):meanBins(iBin+1)}];
    mean_burstHist(iBin,:) = histcounts(curTsBurst,binEdges);
    mean_burstFraction(iBin,:) = mean_burstHist(iBin,:) ./ histcounts(curTs,binEdges);
    plot(binEdges(2:end),smooth(mean_burstHist(iBin,:),nSmooth),'color',meanColors(iBin,:),'lineWidth',2); hold on;
    legendText{iBin} = [timingField,' > ',num2str(all_curUseTime_sorted(meanCentersIdx(iBin)),2),' s'];
end
grid on;
xlim([-1 1]);
xlabel('time (s)');
ylabel('bursts in RT segement');
title('Prevalence of Bursting');
legend(legendText,'Location','eastoutside');
set(gca,'fontSize',16);
set(gcf,'color','w');



% bar plot
nSmooth = 1;
lns = [];
figure;
lns(1) = bar(binEdges(2:end),smooth(mean(mean_burstFraction(1:7,:)),nSmooth),'facecolor','r','edgecolor','none','facealpha',.3);
hold on;
lns(2) = bar(binEdges(2:end),smooth(mean(mean_burstFraction(8:10,:)),nSmooth),'facecolor','k','edgecolor','none','facealpha',.3);
xlim([-1 1]);
xlabel('time (s)');
ylabel('All Spikes / Spike Bursts');
grid on;
title('Fraction of Spikes in Bursts');
legend({'RT < 0.2 s','RT > 0.2 s'},'Location','northeast');
set(gca,'fontSize',16);
set(gcf,'color','w');


% burst occurence with z-score lines low/high RT
nSmooth = 1;
lns = [];
figuree(500,400);

yyaxis left;
lns(1) = bar(binEdges(2:end),smooth(mean(mean_burstHist(1:7,:)),nSmooth),'facecolor','r','edgecolor','none','facealpha',.3);
hold on;
lns(2) = bar(binEdges(2:end),smooth(mean(mean_burstHist(8:10,:)),nSmooth),'facecolor','k','edgecolor','none','facealpha',.3);
xlim([-1 1]);
xlabel('time (s)');
ylabel('Poisson bursts');
title('Poisson bursts vs. Low/High RT');
grid on;

yyaxis right;
lns = [];
lns(3) = plot(binEdges(2:end),smooth(mean(mean_z(1:7,:)),nSmooth),'-','color',meanColors(1,:),'lineWidth',2);
hold on
lns(4) = plot(binEdges(2:end),smooth(mean(mean_z(8:10,:)),nSmooth),'-','color',meanColors(8,:),'lineWidth',2);
xlim([-1 1])
grid on;
ylabel('bracketed z-score');

legend('BURST Low RT (<200ms)','BURST High RT','Z Low RT (<200ms)','Z High RT','location','northwest');
legend('boxoff');