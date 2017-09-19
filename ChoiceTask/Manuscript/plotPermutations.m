nMeanBins = 7;
binMs = 20;
binS = binMs / 1000;
tWindow = 1;
binEdges = -tWindow:binS:tWindow;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/permutationFigures';

% % plotTypes = {'raster','bracketed','high/low'};
% % burstCriterias = {'none','Poisson','LTS'};

events = [3,4];
unitTypes = {eventFieldlabels{3},eventFieldlabels{4},'dirSel'};
timingFields = {'RT','MT'};
% movementDirs = {'all','contra','ipsi'};
movementDirs = {'all'};
    
for ii_events = 1:numel(events)
    useEvent = events(ii_events);

    for ii_unitTypes = 1:numel(unitTypes)
        switch unitTypes{ii_unitTypes}
            case eventFieldlabels{3}
                useNeuronClass = 3;
                useDirSel = false;
            case eventFieldlabels{4}
                useNeuronClass = 4;
                useDirSel = false;
            case 'dirSel'
                useNeuronClass = [3,4];
                useDirSel = true;
        end

        for ii_movementDirs = 1:numel(movementDirs)
            movementDir = movementDirs{ii_movementDirs};

            for ii_timingFields = 1:numel(timingFields)
                timingField = timingFields{ii_timingFields};
                
                % reset all variables
                unitCount = 0;
                trialCount = 1;
                allTrial_tsPeths = {};
                allTrial_PoissonPeths = {};
                allTrial_LTSPeths = {};
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
                
                for iNeuron = 1:numel(analysisConf.neurons)
                    neuronName = analysisConf.neurons{iNeuron};
                    sessionName = analysisConf.sessionConfs{iNeuron}.sessions__name;
                    subjectName = analysisConf.sessionConfs{iNeuron}.subjects__name;

                    if useDirSel && ~dirSelNeurons(iNeuron)
                        continue;
                    end

                    if ~ismember(unitClasses(iNeuron),useNeuronClass)
                        continue;
                    end

                    disp(['Using unit ',num2str(iNeuron),' (class=',num2str(unitClasses(iNeuron)),', maxz=',num2str(unitEvents{iNeuron}.maxz(unitClasses(iNeuron))),') ',neuronName]);
                    unitCount = unitCount + 1;
                    
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
                        tsIdx = find(ts == tsPoisson(iBurst));
                        tsPoisson_inclusive = [tsPoisson_inclusive;ts(tsIdx:tsIdx+poisson_n(iBurst)-1)];
                    end
                    tsPeths_Poisson = eventsPeth(curTrials(useTrials),tsPoisson_inclusive,tWindow,eventFieldnames);
                    % LTS
                    tsLTS_inclusive = [];
                    for iBurst = 1:numel(tsLTS)
                        tsIdx = find(ts == tsLTS(iBurst));
                        tsLTS_inclusive = [tsLTS_inclusive;ts(tsIdx:tsIdx+LTS_n(iBurst)-1)];
                    end
                    tsPeths_LTS = eventsPeth(curTrials(useTrials),tsLTS_inclusive,tWindow,eventFieldnames);

                    z = zParams(ts,curTrials);
                    zBinMean = z.FRmean * (binMs/1000);
                    zBinStd = z.FRstd * (binMs/1000);
                    tsPeths = eventsPeth(curTrials(useTrials),ts,tWindow,eventFieldnames);

                    switch movementDir
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
                        curTs = usePeths{iTrial,useEvent};
                        if numel(curTs) < 3; continue; end;

                        counts = histcounts(curTs,binEdges);
                        curZ = smooth((counts - zBinMean) / zBinStd,3);
                        allTrial_z(trialCount,:) = curZ;

                        curUseTime = useTimes(iTrial);

                        allTrial_useTime(trialCount) = curUseTime;
                        allTrial_tsPeths{trialCount} = curTs;

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
                        tempPeth = tsPeths_Poisson{iTrial,useEvent};
                        if isempty(tempPeth)
                            allTrial_PoissonPeths{trialCount} = NaN;
                        else
                            allTrial_PoissonPeths{trialCount} = tempPeth;
                        end
                        tempPeth = tsPeths_LTS{iTrial,useEvent};
                        if isempty(tempPeth)
                            allTrial_LTSPeths{trialCount} = NaN;
                        else
                            allTrial_LTSPeths{trialCount} = tempPeth;
                        end

                        allTrial_unitClasses(trialCount) = unitClasses(iNeuron);
                        trialCount = trialCount + 1;
                    end
                end
                
                % --- figure
                rows = 3;
                cols = 3;
                nSmooth = 3;
                lineWidth = 1.5;
                plotMargins = [.08 .08];
                xlimVals = [-tWindow tWindow];
                n_rasterReadable = 15;
                h = figuree(1400,800);
                [all_useTime_sorted,k] = sort(allTrial_useTime);
                
                allTrial_z_sorted = allTrial_z(k,:);
                allTrial_tsPeths_sorted = allTrial_tsPeths(k);
                allTrial_PoissonPeths_sorted = allTrial_PoissonPeths(k);
                allTrial_LTSPeths_sorted = allTrial_LTSPeths(k);
                
                doRasters = {allTrial_tsPeths_sorted,allTrial_PoissonPeths_sorted,allTrial_LTSPeths_sorted};
                rasterLabels = {'all spikes','Poisson spikes','LTS spikes'};
                rasterSubplots = [1,4,7];
                for ii_doRasters = 1:numel(doRasters)
                    subplot_tight(rows,cols,rasterSubplots(ii_doRasters),plotMargins);
                    curRaster = doRasters{ii_doRasters};
                    curRaster_sorted_readable = makeRasterReadable(curRaster',n_rasterReadable);
                    plotSpikeRaster(curRaster_sorted_readable,'PlotType','scatter','AutoLabel',false); hold on;
                    plot([0 0],[1 numel(curRaster)],'r-');
                    xlim(xlimVals);
                    xlabel('time (s)');
                    ylabel('trial');
                    title(rasterLabels{ii_doRasters});
                    if useEvent == 3
                        toneLine = plot(all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                        legend(toneLine,timingField);
                    elseif useEvent == 4
                        if strcmp(timingField,'RT')
                            toneLine = plot(0-all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                        elseif strcmp(timingField,'MT')
                            toneLine = plot(all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                        end
                        legend(toneLine,timingField);
                    end
                end
                
                % make mean z-score bins
                meanBins = floor(linspace(1,numel(allTrial_tsPeths),nMeanBins+1));
                meanColors = cool(numel(meanBins)-1);
                mean_z = [];
                mean_Poisson = [];
                mean_PoissonFraction = [];
                mean_LTS = [];
                mean_LTSFraction = [];
                bracketLegendText = {};

                tMean = linspace(xlimVals(1),xlimVals(2),size(allTrial_z_sorted,2));
                for iBin = 1:numel(meanBins)-1
                    mean_z(iBin,:) = smooth(mean(allTrial_z_sorted(meanBins(iBin):meanBins(iBin+1),:)),nSmooth);
                    
                    cur_ts = [allTrial_tsPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
                    cur_Poisson = [allTrial_PoissonPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
                    cur_LTS = [allTrial_LTSPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
                    
                    mean_Poisson(iBin,:) = smooth(histcounts(cur_Poisson,binEdges),nSmooth);
                    mean_LTS(iBin,:) = smooth(histcounts(cur_LTS,binEdges),nSmooth);
                    
                    cur_ts_count = histcounts(cur_ts,binEdges);
                    mean_PoissonFraction(iBin,:) = smooth(mean_Poisson(iBin,:) ./ cur_ts_count,nSmooth);
                    mean_LTSFraction(iBin,:) = smooth(mean_LTS(iBin,:) ./ cur_ts_count,nSmooth);
                    
                    bracketLegendText{iBin} = [timingField,' < ',num2str(all_useTime_sorted(meanBins(iBin+1)),2),' s'];
                end
                
                % Z score
                subplot_tight(rows,cols,2,plotMargins);
                lns = plot(mean_z','lineWidth',lineWidth);
                set(lns,{'color'},num2cell(meanColors,2));
                title('Z score');
                xlabel('time (s)');
                ylabel('Z');
                ylim([-.5 2]);
                xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
                xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
                grid on;
                
                subplot(rows,cols,3);
                lns = plot(mean_z');
                set(lns,{'color'},num2cell(meanColors,2));
                ylim([100 101]);
                xlim([100 101]);
                yticks([]);
                xticks([]);
                legend(bracketLegendText,'location','south');
                legend boxoff;
                set(gca,'Visible','off')
                set(gca,'fontsize',16);
                
                % Prevalence
                subplot_tight(rows,cols,5,plotMargins);
                lns = plot(mean_Poisson','lineWidth',lineWidth);
                set(lns,{'color'},num2cell(meanColors,2));
                title('Poisson prevalence');
                xlabel('time (s)');
                ylabel('burst count');
                xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
                xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
                grid on;
                
                subplot_tight(rows,cols,8,plotMargins);
                lns = plot(mean_LTS','lineWidth',lineWidth);
                set(lns,{'color'},num2cell(meanColors,2));
                title('LTS prevalence');
                xlabel('time (s)');
                ylabel('burst count');
                xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
                xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
                grid on;
                
                % Fraction
                subplot_tight(rows,cols,6,plotMargins);
                lns = plot(mean_PoissonFraction','lineWidth',lineWidth);
                set(lns,{'color'},num2cell(meanColors,2));
                title('Poisson fraction');
                xlabel('time (s)');
                ylabel('burst spikes / all spikes');
                xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
                xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
                grid on;
                
                subplot_tight(rows,cols,9,plotMargins);
                lns = plot(mean_LTSFraction','lineWidth',lineWidth);
                set(lns,{'color'},num2cell(meanColors,2));
                title('LTS fraction');
                xlabel('time (s)');
                ylabel('burst spikes / all spikes');
                xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
                xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
                grid on;
                
                set(gcf,'color','w');
                
                noteText = {['event: ',eventFieldlabels{useEvent}],['class: ',unitTypes{ii_unitTypes}],['units: ',num2str(unitCount)]...
                    ['move: ',movementDir],['sortBy: ',timingField]};
                addNote(h,noteText);
                
                saveFile = [eventFieldlabels{useEvent},' units_',unitTypes{ii_unitTypes},' event_n',num2str(unitCount),'_movDir ',movementDir,'_sortBy ',timingField];
                
                set(h,'PaperOrientation','landscape');
                set(h,'PaperUnits','normalized');
                set(h,'PaperPosition', [0 0 1 1]);
                print(gcf,'-dpdf', fullfile(savePath,[strrep(saveFile,' ','-'),'.pdf']));
                close(h);
            end
        end
    end
end







% figure;
% plot(all_subjectCount(k),all_curUseTime_sorted,'.');

%  RT
h = figuree(1200,800);
rows = 2;
cols = 3;

subplot_tight(rows,cols,1);
plot(all_useTime_sorted,1:numel(all_useTime_sorted),'k');
set(gca,'YDir','reverse');
ylim([1 numel(all_useTime_sorted)]);
xlim([0 1.5]);
xticks([0 0.25 0.5 0.75 1.05 1.35]);
xticklabels({'0','0.25','0.5','0.75','Subjects','Sessions'});
xlabel('time (s)');
title({[timingField,' where t0 ~> ',eventFieldnames{useEvent}],['units from: ',strjoin(eventFieldnames(useNeuronClass),',')],[num2str(binMs),'ms bins, ',num2str(nMeanBins),' brackets'],['trial filter: ',limitToSide],['only dirSel? ',dirSelNote]});
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
for iTrial = 1:numel(all_useTime_sorted)
    curTime = all_useTime_sorted(iTrial);
    plot(sessionSpan(all_sessionCount_sorted(iTrial)),iTrial,'.','markerSize',1,'color',sessionColors(all_sessionCount_sorted(iTrial),:));
    plot(subjectSpan(all_subjectCount_sorted(iTrial)),iTrial,'.','markerSize',1,'color',subjectColors(all_subjectCount_sorted(iTrial),:));
end


% spike raster
subplot_tight(rows,cols,2);
allTrial_tsPeths_sorted = allTrial_tsPeths(k);
allTrial_tsPeths_sorted_readable = makeRasterReadable(allTrial_tsPeths_sorted',15);
plotSpikeRaster(allTrial_tsPeths_sorted_readable,'PlotType','scatter','AutoLabel',false); hold on;
plot([0 0],[1 numel(allTrial_tsPeths_sorted)],'r:');
xlimVals = [-tWindow tWindow];
xlim(xlimVals);
xlabel('time (s)');
title([timingField,' spikes']);

% make mean z-score bins
meanBins = floor(linspace(1,numel(allTrial_tsPeths_sorted),nMeanBins+1));
makeyStart = floor(linspace((numel(allTrial_tsPeths_sorted)*.1),numel(allTrial_tsPeths_sorted)-(numel(allTrial_tsPeths_sorted)*.05),nMeanBins));
meanColors = cool(numel(meanBins)-1);
allTrial_z_sorted = allTrial_z(k,:);
mean_z = [];
std_z = [];
meanCentersIdx = [];
xneg = [];
xpos = [];
area_z = [];
tMean = linspace(xlimVals(1),xlimVals(2),size(allTrial_z_sorted,2));
for iBin = 1:numel(meanBins)-1
    mean_z(iBin,:) = mean(allTrial_z_sorted(meanBins(iBin):meanBins(iBin+1),:));
    std_z(iBin,:) = std(allTrial_z_sorted(meanBins(iBin):meanBins(iBin+1),:));
    meanCentersIdx(iBin) = round((meanBins(iBin) + meanBins(iBin+1)) / 2);
    
    areaIdxs = floor(numel(tMean)/2):find(tMean <= areaUnderS,1,'last');
    area_z(iBin) = trapz(mean_z(iBin,areaIdxs));
    % plot
    makey = (makeyStart(iBin) + mean_z(iBin,:) * -(numel(allTrial_tsPeths_sorted)*.1)); % -1 for orientation
    plot(tMean,makey,'linewidth',1.5,'color',[meanColors(iBin,:),0.9]);
end

% heatmap
subplot_tight(rows,cols,3);
imagesc(allTrial_z_sorted);
colormap(jet);
xticks([1 floor(size(allTrial_z_sorted,2)/2) size(allTrial_z_sorted,2)]);
xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
caxis([-1 5]);
title([timingField,' z-score']);
xlabel('time (s)');
colorbar;

maxIdxs = floor(size(allTrial_z_sorted,2)/2):floor(size(allTrial_z_sorted,2)/2)+floor(size(allTrial_z_sorted,2)/4);
minIdxs = floor(size(allTrial_z_sorted,2)/8):floor(size(allTrial_z_sorted,2)/2);

% scatter all max z-scores
markerSize = 3;
subplot_tight(rows,cols,4);
% yyaxis left;
lns = [];
[maxv,maxk] = max(allTrial_z_sorted(:,maxIdxs)');
[minv,mink] = min(allTrial_z_sorted(:,minIdxs)');
lns(1) = plot(all_useTime_sorted,maxv,'g.','MarkerSize',markerSize);
hold on;
lns(2) = plot(all_useTime_sorted,minv,'r.','MarkerSize',markerSize);
% ylim([-40 120]);
ylabel('trial z-score');
xlabel('time (s)');
legend(lns,{'max z ~t0','min z < t0'});
grid on;

yyaxis right;
lns(3) = plot(all_useTime_sorted+1,trapz(allTrial_z_sorted(:,areaIdxs)'),'b.','MarkerSize',markerSize);
xlim([0 2]);
xticks([0 1 2]);
xticklabels({'0','1/0','1'});

[RHO_zxt,PVAL_zxt] = corr(all_useTime_sorted',maxv');
[RHO_axt,PVAL_axt] = corr(all_useTime_sorted',trapz(allTrial_z_sorted(:,areaIdxs)')');
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
subplot_tight(rows,cols,5);
yyaxis left;
[maxv,maxk] = max(mean_z(:,maxIdxs)');
[minv,mink] = min(mean_z(:,minIdxs)');

errorbar(all_useTime_sorted(meanCentersIdx),maxv,mean(std_z'),mean(std_z'),...
    all_useTime_sorted(meanCentersIdx)-all_useTime_sorted(meanBins(1:end-1)),...
    all_useTime_sorted(meanBins(2:end))-all_useTime_sorted(meanCentersIdx),'.','Color',[.7 .7 .7]);
hold on;
lns(1) = plot(all_useTime_sorted(meanCentersIdx),maxv,'g.','MarkerSize',markerSize); hold on;
set(gca,'yColor','g');

% errorbar(all_curUseTime_sorted(meanCentersIdx),minv,mean(std_z'),mean(std_z'),...
%     all_curUseTime_sorted(meanCentersIdx)-all_curUseTime_sorted(meanBins(1:end-1)),...
%     all_curUseTime_sorted(meanBins(2:end))-all_curUseTime_sorted(meanCentersIdx),'.','Color',[.7 .7 .7]);
lns(2) = plot(all_useTime_sorted(meanCentersIdx),minv,'r.','MarkerSize',markerSize);

ylabel('min max z');
xlim([0 1]);
% ylim([-10 50]);
xlabel('time (s)');
grid on;

% hold on;
% [f,gof] = fit(all_curUseTime_sorted(meanBins(2:end))',maxv','exp2');
% plot(f,all_curUseTime_sorted(meanBins(2:end))',maxv');

yyaxis right;
lns(3) = plot(all_useTime_sorted(meanCentersIdx),area_z,'b.','MarkerSize',markerSize);
set(gca,'yColor','b');
ylabel('area z');

[RHO_zxt,PVAL_zxt] = corr(all_useTime_sorted(meanCentersIdx)',maxv');
[RHO_axt,PVAL_axt] = corr(all_useTime_sorted(meanCentersIdx)',area_z');
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

subplot_tight(rows,cols,6);
bracketLegendText = {};
lns = [];

for ii = 1:size(mean_z,1)
    lns(ii) = plot(smooth(mean_z(ii,:),nSmoothz),'color',meanColors(ii,:));
    hold on;
    bracketLegendText{ii} = [num2str(all_useTime_sorted(meanCentersIdx(ii))),' ms'];
end
legend(lns,bracketLegendText,'Location','eastoutside');
xlim([1 size(allTrial_z_sorted,2)]);
xticks([1 floor(size(allTrial_z_sorted,2)/2) size(allTrial_z_sorted,2)]);
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
subplot_tight(211);
allTrial_tsPeths_sorted = allTrial_tsPeths(k);
allTrial_tsPeths_sorted_readable = makeRasterReadable(allTrial_tsPeths_sorted',20);
plotSpikeRaster(allTrial_tsPeths_sorted_readable,'PlotType','scatter','AutoLabel',false); hold on;
hold on;
if useEvent == 3
    toneLine = plot(all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
    
elseif useEvent == 4
    toneLine = plot(0-all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
end
plot([0 0],[1 numel(all_useTime_sorted)],'g:','linewidth',1);
if show200ms
    plot([-1 1],[find(all_useTime_sorted >= .200,1) find(all_useTime_sorted >= .200,1)],'y-');
    text(-1,find(all_useTime_sorted >= .200,1),'200 ms','BackgroundColor','y');
end
xlimVals = [-tWindow tWindow];
xlim(xlimVals);
ylabel('trials');
title({['e:',eventFieldlabels{useEvent},', s:',eventFieldlabels{useNeuronClass}],'All Spikes'});
legend(toneLine,'Tone');
set(gca,'fontSize',16);

subplot_tight(212)
[xPoints, yPoints] = plotSpikeRaster(all_burstTs_sorted,'PlotType','scatter','AutoLabel',false);
hold on;
if useEvent == 3
    toneLine = plot(all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
elseif useEvent == 4
    toneLine = plot(0-all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
end
plot([0 0],[1 numel(all_useTime_sorted)],'g:','linewidth',1);
if show200ms
    plot([-1 1],[find(all_useTime_sorted >= .200,1) find(all_useTime_sorted >= .200,1)],'y-');
    text(-1,find(all_useTime_sorted >= .200,1),'200 ms','BackgroundColor','y');
end
title({['e:',eventFieldlabels{useEvent},', s:',eventFieldlabels{useNeuronClass}],'Only Bursts'});
xlabel('time (s)');
ylabel('trials');
set(gca,'fontSize',16);
set(gcf,'color','w');



% all brackets as colored lines
figure;
mean_burstHist = [];
mean_burstFraction = [];
nSmooth = 3;
bracketLegendText = {};
for iBin = 1:numel(meanBins)-1
    curTsBurst = [all_burstTs_sorted{meanBins(iBin):meanBins(iBin+1)}];
    curTs = [allTrial_tsPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
    mean_burstHist(iBin,:) = histcounts(curTsBurst,binEdges);
    mean_burstFraction(iBin,:) = mean_burstHist(iBin,:) ./ histcounts(curTs,binEdges);
    plot(binEdges(2:end),smooth(mean_burstHist(iBin,:),nSmooth),'color',meanColors(iBin,:),'lineWidth',2); hold on;
    bracketLegendText{iBin} = [timingField,' > ',num2str(all_useTime_sorted(meanCentersIdx(iBin)),2),' s'];
end
grid on;
xlim([-1 1]);
xlabel('time (s)');
ylabel('bursts in RT segement');
title('Prevalence of Bursting');
legend(bracketLegendText,'Location','eastoutside');
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