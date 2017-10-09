doSave = true;
nMeanBins = 10;
binMs = 20;
binS = binMs / 1000;
tWindow = 1;
binEdges = -tWindow:binS:tWindow;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/permutationFigures';
sessionsPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions';
doBursts = false;
% for figure
binInc = 0.02;
z_smooth = 3;
auc_smooth = 3;
lineWidth = 2;
minZ = 0;

useOrdinary = true;
% RT_intercepts = ezReciprobit(all_rt,10);
% MT_intercepts = ezReciprobit(all_mt,10);
ordinaryRTmin = RT_intercepts(2);
ordinaryRTmax =  RT_intercepts(10);
ordinaryMTmax = MT_intercepts(10);


clear all_z_raw;

% % plotTypes = {'raster','bracketed','high/low'};
% % burstCriterias = {'none','Poisson','LTS'};

events = [4];
LRTHMT = false;
HRTLMT = false;
LRTLMT = false;
HRTHMT = false;
unitTypes = {eventFieldlabels{4},'dirSel','~dirSel'};
% unitTypes = {'dirSel'};
timingFields = {'RT','MT'};
movementDirs = {'ipsi','contra','all'};
    
for ii_events = 1:numel(events)
    useEvent = events(ii_events);

    for ii_unitTypes = 1:numel(unitTypes)
        filterBy_dirSel = false;
        excludeUnits = [];
        switch unitTypes{ii_unitTypes}
            case eventFieldlabels{1}
                useNeuronClass = 1;
                dirSel = false;
            case eventFieldlabels{2}
                useNeuronClass = 2;
                dirSel = false;
            case eventFieldlabels{3}
                useNeuronClass = 3;
                dirSel = false;
            case eventFieldlabels{4}
                useNeuronClass = 4;
                dirSel = false;
            case eventFieldlabels{5}
                useNeuronClass = 5;
                dirSel = false;
            case eventFieldlabels{6}
                useNeuronClass = 6;
                dirSel = false;
            case eventFieldlabels{7}
                useNeuronClass = 7;
                dirSel = false;
            case 'dirSel'
                % must have first or second class of nose out
                for iNeuron = 1:numel(analysisConf.neurons)
                    if ~isempty(unitEvents{iNeuron}.class) && ~any(ismember(unitEvents{iNeuron}.class(1:2),4))
                        excludeUnits = [excludeUnits iNeuron];
                    end
                end
                useNeuronClass = [1:7];
                filterBy_dirSel = true;
                dirSel = true;
            case '~dirSel'
                useNeuronClass = useEvent;
                filterBy_dirSel = true;
                dirSel = false;
            case 'tone_centerOut'
                useNeuronClass = [3,4];
                filterBy_dirSel = false;
                dirSel = false;
            case '~tone_centerOut'
                useNeuronClass = [1:7];
                filterBy_dirSel = false;
                dirSel = false;
                for iNeuron = 1:numel(analysisConf.neurons)
                    if ~isempty(unitEvents{iNeuron}.class) && any(ismember(unitEvents{iNeuron}.class(1:2),[3,4]))
                        excludeUnits = [excludeUnits iNeuron];
                    end
                end
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

                    if filterBy_dirSel
                        if (dirSel && ~dirSelNeurons(iNeuron)) || (~dirSel && dirSelNeurons(iNeuron))
                            continue;
                        end
                    end

                    if ~ismember(unitClasses(iNeuron),useNeuronClass)
                        continue;
                    end
                    
                    if ismember(iNeuron,excludeUnits)
                        continue;
                    end
                    
                    if unitEvents{iNeuron}.maxz(unitClasses(iNeuron)) < minZ
                        continue;
                    end

                    disp(['Using unit ',num2str(iNeuron),' (class=',num2str(unitClasses(iNeuron)),', maxz=',num2str(unitEvents{iNeuron}.maxz(unitClasses(iNeuron))),') ',neuronName]);
                    unitCount = unitCount + 1;
                    
                    curTrials = all_trials{iNeuron};
                    
                    [trialIds,allRT,allMT] = sortTrialsByRTMT(curTrials,timingField);
                    LH_RTMT_note = '';
                    useTrials = [];
                    if LRTHMT
                        LRTHMT_idx = allRT < median(all_rt) + std(all_rt) & allMT > median(all_mt);
                        allRT = allRT(LRTHMT_idx);
                        allMT = allMT(LRTHMT_idx);
                        useTrials = trialIds(LRTHMT_idx);
                        LH_RTMT_note = 'LRTHMT';
                    end
                    if HRTLMT
                        HRTLMT_idx = allMT < median(all_mt);
                        allRT = allRT(HRTLMT_idx);
                        allMT = allMT(HRTLMT_idx);
                        useTrials = trialIds(HRTLMT_idx);
                        LH_RTMT_note = 'HRTLMT';
                    end
                    if LRTLMT
                        LRTLMT_idx = allRT < .2 & allMT < median(all_mt);
                        allRT = allRT(LRTLMT_idx);
                        allMT = allMT(LRTLMT_idx);
                        useTrials = trialIds(LRTLMT_idx);
                        LH_RTMT_note = 'LRTLMT';
                    end
                    if HRTHMT
                        HRTHMT_idx = allRT > .2 & allMT > median(all_mt);
                        allRT = allRT(HRTHMT_idx);
                        allMT = allMT(HRTHMT_idx);
                        useTrials = trialIds(HRTHMT_idx);
                        LH_RTMT_note = 'HRTHMT';
                    end
                    if useOrdinary
                        ordinary_idx = allRT >= ordinaryRTmin & allRT < ordinaryRTmax & allMT < ordinaryMTmax;
                        allRT = allRT(ordinary_idx);
                        allMT = allMT(ordinary_idx);
                        useTrials = trialIds(ordinary_idx);
                        LH_RTMT_note = 'ORD';
                    end
                    
                    if isempty(allRT) || isempty(allMT)
                        continue;
                    end

                    switch timingField
                        case 'RT'
% %                             [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
                            allTimes = allRT;
                            allTimes2 = allMT;
                        case 'MT'
% %                             [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
                            allTimes = allMT;
                            allTimes2 = allRT;
% %                         case 'RTMT'
% %                             allTimes = allRT + allMT;
                        case 'pretone'
                            [useTrials,allTimes] = sortTrialsBy(curTrials,timingField);
                    end
                    if isempty(useTrials)
                        useTrials = trialIds;
                    end

% %                     [allTimes,k] = sort(allTimes);
% %                     useTrials = trialIds(k);

                    trialIdInfo = organizeTrialsById(curTrials);

                    t_useTrials = [];
                    t_allTimes = [];
                    t_allTimes2 = [];
                    tc = 1;
                    for iTrial = 1:numel(useTrials)
                        if ismember(useTrials(iTrial),trialIdInfo.correctContra)
                            t_useTrials(tc) = useTrials(iTrial);
                            t_allTimes(tc) = allTimes(iTrial);
                            t_allTimes2(tc) = allTimes2(iTrial);
                            tc = tc + 1;
                        end
                    end
                    markContraTrials = tc - 1;
                    for iTrial = 1:numel(useTrials)
                        if ismember(useTrials(iTrial),trialIdInfo.correctIpsi)
                            t_useTrials(tc) = useTrials(iTrial);
                            t_allTimes(tc) = allTimes(iTrial);
                            t_allTimes2(tc) = allTimes2(iTrial);
                            tc = tc + 1;
                        end
                    end
                    useTrials = t_useTrials;
                    allTimes = t_allTimes;
                    allTimes2 = t_allTimes2;

                    tsPeths = {};
                    ts = all_ts{iNeuron};
                    
                    if doBursts
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
                    end

                    z = zParams(ts,curTrials);
                    zBinMean = z.FRmean * (binMs/1000);
                    zBinStd = z.FRstd * (binMs/1000);
                    tsPeths = eventsPeth(curTrials(useTrials),ts,tWindow,eventFieldnames);

                    switch movementDir
                        case 'contra'
                            usePeths = tsPeths(1:markContraTrials,:);
                            useTimes = allTimes(1:markContraTrials);
                            useTimes2 = allTimes2(1:markContraTrials);
                        case 'ipsi'
                            usePeths = tsPeths(markContraTrials+1:end,:);
                            useTimes = allTimes(markContraTrials+1:end);
                            useTimes2 = allTimes(markContraTrials+1:end);
                        otherwise                  
                            usePeths = tsPeths;
                            useTimes = allTimes;
                            useTimes2 = allTimes2;
                    end

                    curZ = [];
                    for iTrial = 1:numel(useTimes)
                        curTs = usePeths{iTrial,useEvent};
                        if numel(curTs) < 3; continue; end;

                        counts = histcounts(curTs,binEdges);
                        curZ = smooth((counts - zBinMean) / zBinStd,3);
                        allTrial_z(trialCount,:) = curZ;

                        curUseTime = useTimes(iTrial);
                        curUseTime2 = useTimes2(iTrial);

                        allTrial_useTime(trialCount) = curUseTime;
                        allTrial_useTime2(trialCount) = curUseTime2;
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

                        if doBursts
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
                        end
                        allTrial_unitClasses(trialCount) = unitClasses(iNeuron);
                        trialCount = trialCount + 1;
                    end
                end
                
                % --- figure
                rows = 3;
                cols = 3;
                plotMargins = [.08 .08];
                xlimVals = [-tWindow tWindow];
                h = figuree(1300,800);
                [all_useTime_sorted,k] = sort(allTrial_useTime);
                
                allTrial_z_sorted = allTrial_z(k,:);
                allTrial_tsPeths_sorted = allTrial_tsPeths(k);
                if doBursts
                    allTrial_PoissonPeths_sorted = allTrial_PoissonPeths(k);
                    allTrial_LTSPeths_sorted = allTrial_LTSPeths(k);
                    doRasters = {allTrial_tsPeths_sorted,allTrial_PoissonPeths_sorted,allTrial_LTSPeths_sorted};
                end
                
                doRasters = {allTrial_tsPeths_sorted};
                rasterLabels = {'all spikes','Poisson spikes','LTS spikes'};
                rasterSubplots = [1,4,7];
                for ii_doRasters = 1:numel(doRasters)
                    subplot_tight(rows,cols,rasterSubplots(ii_doRasters),plotMargins);
                    curRaster = doRasters{ii_doRasters};
                    n_rasterReadable = round(100000 / numel(curRaster));
                    curRaster_sorted_readable = makeRasterReadable(curRaster',n_rasterReadable);
                    plotSpikeRaster(curRaster_sorted_readable,'PlotType','scatter','AutoLabel',false); hold on;
                    plot([0 0],[1 numel(curRaster)],'r-');
                    xlim(xlimVals);
                    xlabel('time (s)');
                    ylabel('trial');
                    title(rasterLabels{ii_doRasters});
                    if useEvent == 3
                        if strcmp(timingField,'RT')
                            toneLine = plot(all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                            legend(toneLine,timingField);
                        end
                    elseif useEvent == 4
                        if strcmp(timingField,'RT')
                            toneLine = plot(-all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                            legend(toneLine,timingField);
                        elseif strcmp(timingField,'MT')
                            toneLine = plot(all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                            legend(toneLine,timingField);
                        end
                    elseif useEvent == 5
                        if strcmp(timingField,'MT')
                            toneLine = plot(-all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                            legend(toneLine,timingField);
                        end
                    end
                    if strcmp(timingField,'RTMT')
                         toneLine = plot(all_useTime_sorted,1:numel(all_useTime_sorted),'g','linewidth',2);
                         legend(toneLine,timingField);
                    end
                end
                
                % make mean z-score bins
                switch timingField
                    case 'RT'
%                         meanBinsSeconds = [median(all_rt)-std(all_rt):binInc:median(all_rt)+std(all_rt)];
%                         meanBinsSeconds = [min(all_rt):binInc:max(all_rt)];
                        meanBinsSeconds = [min(all_rt),.12:binInc:.45,max(all_rt)];
%                         meanBinsSeconds = [min(all_rt):binInc:max(all_rt)];
                    case 'MT'
%                         meanBinsSeconds = [median(all_mt)-std(all_mt):binInc:median(all_mt)+std(all_mt)];
                        meanBinsSeconds = [min(all_mt):binInc:max(all_mt)];
                    case 'RTMT'
                        meanBinsSeconds = [0.3:binInc:max(all_rt+all_mt)];
                    case 'pretone'
                        meanBinsSeconds = [0.5:binInc:1];
                    otherwise
                        meanBinsSeconds = 0:binInc:max(all_useTime_sorted);
                end

                meanBins = [];
                for iBinSeconds = 1:numel(meanBinsSeconds)
                    [idx, val] = closest(all_useTime_sorted,meanBinsSeconds(iBinSeconds));
                    meanBins(iBinSeconds) = idx;
                end
                
%                 adj_meanBinsSeconds = [];
%                 for iBinSeconds = 1:numel(meanBinsSeconds)-1
%                     minIdx = find(meanBinsSeconds(iBinSeconds) < all_useTime_sorted,1,'first');
%                     adj_meanBinsSeconds(iBinSeconds) = meanBinsSeconds(iBinSeconds);
%                     if isempty(minIdx)
% %                         adj_meanBinsSeconds(iBinSeconds+1) = meanBinsSeconds(iBinSeconds+1);
%                         break;
%                     else
%                         meanBins(iBinSeconds) = minIdx;
%                     end
%                 end
%                 meanBins(iBinSeconds) = numel(all_useTime_sorted);
%                 meanBins = [1 meanBins];
%                 fixOnesIdx = find(meanBins == 1,1,'last');
%                 meanBins = meanBins(fixOnesIdx:end);
%                 meanBinsSeconds = adj_meanBinsSeconds(fixOnesIdx:end);
                
                meanBins = floor(linspace(1,numel(allTrial_tsPeths),nMeanBins+1));
                meanBinsSeconds = all_useTime_sorted(meanBins);
                meanColors = cool(numel(meanBins)-1);
                mean_z = [];
                z_raw = [];
                auc_min = [];
                auc_max = [];
                auc_max_t = [];
                auc_min_z = [];
                auc_max_z = [];
                cumsum_min = [];
                cumsum_max = [];
                mean_Poisson = [];
                mean_PoissonFraction = [];
                mean_LTS = [];
                mean_LTSFraction = [];
                bracketLegendText = {};

                tMean = linspace(xlimVals(1),xlimVals(2),size(allTrial_z_sorted,2));
                z_raw = NaN(numel(meanBins)-1,size(allTrial_z_sorted,2));
                mean_z = z_raw;
                for iBin = 1:numel(meanBins)-1
                    this_z = mean(allTrial_z_sorted(meanBins(iBin):meanBins(iBin+1),:));
                    
                    % --- init, this is a poor way, should use NaNs above,
                    % !! FIX
                    auc_min_z(iBin) = NaN;
                    auc_min(iBin) = NaN;
                    auc_max_z(iBin) = NaN;
                    auc_max_t(iBin) = NaN;
                    auc_max(iBin) = NaN;
                    cumsum_min(iBin) = NaN;
                    cumsum_max(iBin) = NaN;
                    % ---
                    if numel(this_z) > 1
                        z_raw(iBin,:) = this_z;
                        mean_z(iBin,:) = smooth(z_raw(iBin,:),z_smooth);
                        % area under curve, assumes tWindow = 1
                        z_curve = smooth(z_raw(iBin,:),auc_smooth);
                        min_start = round(.2/binS);
                        min_end = round(.7/binS);
                        min_curve = z_curve(min_start:min_end);
                        
                        min_curve_norm = min_curve - min_curve(1);
                        auc_min_z(iBin) = min(min_curve);
                        min_cumsum = cumsum(min_curve);
                        cumsum_min(iBin) = min_cumsum(end);
                        auc_min(iBin) = trapz(min_curve_norm(min_curve_norm <= 0));
                        

                        max_start = round(.8/binS);
                        max_end = round(1.2/binS);
                        max_curve = z_curve(max_start:max_end);
                        [max_v,max_k] = max(max_curve);

                        max_curve_norm = max_curve - max_curve(1);
                        auc_max_z(iBin) = max_v;
                        auc_max_t(iBin) = binEdges((max_start + max_k - 1));
                        max_cumsum = cumsum(max_curve);
                        cumsum_max(iBin) = max_cumsum(end);
                        auc_max(iBin) = trapz(max_curve_norm(max_curve_norm > 0));

                        % bursting
                        if doBursts
                            cur_ts = [allTrial_tsPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
                            cur_Poisson = [allTrial_PoissonPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
                            cur_LTS = [allTrial_LTSPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
                            mean_Poisson(iBin,:) = smooth(histcounts(cur_Poisson,binEdges),z_smooth);
                            mean_LTS(iBin,:) = smooth(histcounts(cur_LTS,binEdges),z_smooth);
                            cur_ts_count = histcounts(cur_ts,binEdges);
                            mean_PoissonFraction(iBin,:) = smooth(mean_Poisson(iBin,:) ./ cur_ts_count,z_smooth);
                            mean_LTSFraction(iBin,:) = smooth(mean_LTS(iBin,:) ./ cur_ts_count,z_smooth);
                        end
                    end
                    
                    bracketLegendText{iBin,1} = [num2str(all_useTime_sorted(meanBins(iBin)),2),'s < ',timingField,' < ',num2str(all_useTime_sorted(meanBins(iBin+1)),2),' s'];
                end
                
                meanBinCenters = (meanBinsSeconds(2:end)+meanBinsSeconds(1:end-1)) / 2;
                
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
                columnlegend(3,bracketLegendText,'location','east');
                set(gca,'Visible','off')
                set(gca,'fontsize',8);
                
                
                % area under curve
                markerSize = 30;
                subplot_tight(rows,cols,4,plotMargins);
                scatter(auc_min,auc_max,markerSize,meanColors,'filled');
                xlabel('auc_min','interpreter','none');
                ylabel('auc_max','interpreter','none');
                [f,gof] = fit(auc_min',auc_max','poly1');
                hold on;
                plot(auc_min,f(auc_min),'r','lineWidth',2);
                title({'auc_min vs. auc_max',['rsquare = ',num2str(gof.rsquare,3)]},'interpreter','none');
                grid on;
                
                markerSize = 30;
                subplot_tight(rows,cols,7,plotMargins);
                scatter(auc_min_z,auc_max_z,markerSize,meanColors,'filled');
                xlabel('auc_min_z','interpreter','none');
                ylabel('auc_max_z','interpreter','none');
                [f,gof] = fit(auc_min_z',auc_max_z','poly1');
                hold on;
                plot(auc_min_z,f(auc_min_z),'r','lineWidth',2);
                title({'auc_min_z vs. auc_max_z',['rsquare = ',num2str(gof.rsquare,3)]},'interpreter','none');
                grid on;
                
                subplot_tight(rows,cols,5,plotMargins);
                scatter(1:numel(auc_max),auc_max,markerSize,meanColors,'filled');
                xlabel([timingField,' Quantile'],'interpreter','none');
                ylabel('auc_max','interpreter','none');
                [f,gof] = fit([1:numel(auc_max)]',auc_max','poly1');
                hold on;
                plot(1:numel(auc_max),f(1:numel(auc_max)),'r','lineWidth',2);
                ci = confint(f);
                plot(1:numel(auc_max),[1:numel(auc_max)]*ci(1,1)+c(1,2),'r--');
                plot(1:numel(auc_max),[1:numel(auc_max)]*ci(2,1)+c(2,2),'r--');
                title({['auc_max vs. ',timingField],['rsquare = ',num2str(gof.rsquare,3)]},'interpreter','none');
% %                 grid on;
                xticks([1:numel(auc_max)]);
                xticklabels(compose('%1.3f',meanBinCenters));
                xtickangle(90);
                ylim([0,15]);
                
                subplot_tight(rows,cols,8,plotMargins);
                scatter(1:numel(auc_max_z),auc_max_z,markerSize,meanColors,'filled');
                xlabel([timingField,' Quantile'],'interpreter','none');
                ylabel('auc_max_z','interpreter','none');
                [f,gof] = fit([1:numel(auc_max_z)]',auc_max_z','poly1');
                hold on;
                plot(1:numel(auc_max_z),f(1:numel(auc_max_z)),'r','lineWidth',2);
                ci = confint(f);
                plot(1:numel(auc_max_z),[1:numel(auc_max_z)]*ci(1,1)+c(1,2),'r--');
                plot(1:numel(auc_max_z),[1:numel(auc_max_z)]*ci(2,1)+c(2,2),'r--');
                title({['auc_max_z vs. ',timingField],['rsquare = ',num2str(gof.rsquare,3)]},'interpreter','none');
% %                 grid on;
                xticks([1:numel(auc_max_z)]);
                xticklabels(compose('%1.3f',meanBinCenters));
                xtickangle(90);
                ylim([0,2]);
                
                % trying 1/timing corr
                x = -1./meanBinCenters;
                
                subplot_tight(rows,cols,6,plotMargins);
                scatter(x,auc_max,markerSize,meanColors,'filled');
                xlabel(['1/',timingField],'interpreter','none');
                ylabel('auc_max','interpreter','none');
                [f,gof] = fit(x',auc_max','poly1');
                hold on;
                plot(x,f(x),'r','lineWidth',2);
                ci = confint(f);
                plot(x,x*ci(1,1)+c(1,2),'r--');
                plot(x,x*ci(2,1)+c(2,2),'r--');
                title({['auc_max vs. ',timingField],['rsquare = ',num2str(gof.rsquare,3)]},'interpreter','none');
% %                 grid on;
                xticks(x);
                xticklabels(compose('%1.3f',x));
                xtickangle(90);
                ylim([0,15]);
                
                subplot_tight(rows,cols,9,plotMargins);
                scatter(x,auc_max_z,markerSize,meanColors,'filled');
                xlabel(['1/',timingField],'interpreter','none');
                ylabel('auc_max_z','interpreter','none');
                [f,gof] = fit(x',auc_max_z','poly1');
                hold on;
                plot(x,f(x),'r','lineWidth',2);
                ci = confint(f);
                plot(x,x*ci(1,1)+c(1,2),'r--');
                plot(x,x*ci(2,1)+c(2,2),'r--');
                title({['auc_max_z vs. ',timingField],['rsquare = ',num2str(gof.rsquare,3)]},'interpreter','none');
% %                 grid on;
                xticks(x);
                xticklabels(compose('%1.3f',x));
                xtickangle(90);
                ylim([0,2]);
                
                
                % --- burst quant START
                % Prevalence
% %                 subplot_tight(rows,cols,5,plotMargins);
% %                 lns = plot(mean_Poisson','lineWidth',lineWidth);
% %                 set(lns,{'color'},num2cell(meanColors,2));
% %                 title('Poisson prevalence');
% %                 xlabel('time (s)');
% %                 ylabel('burst count');
% %                 xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
% %                 xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
% %                 grid on;
% %                 
% %                 subplot_tight(rows,cols,8,plotMargins);
% %                 lns = plot(mean_LTS','lineWidth',lineWidth);
% %                 set(lns,{'color'},num2cell(meanColors,2));
% %                 title('LTS prevalence');
% %                 xlabel('time (s)');
% %                 ylabel('burst count');
% %                 xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
% %                 xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
% %                 grid on;
% %                 
% %                 % Fraction
% %                 subplot_tight(rows,cols,6,plotMargins);
% %                 lns = plot(mean_PoissonFraction','lineWidth',lineWidth);
% %                 set(lns,{'color'},num2cell(meanColors,2));
% %                 title('Poisson fraction');
% %                 xlabel('time (s)');
% %                 ylabel('burst spikes / all spikes');
% %                 xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
% %                 xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
% %                 grid on;
% %                 
% %                 subplot_tight(rows,cols,9,plotMargins);
% %                 lns = plot(mean_LTSFraction','lineWidth',lineWidth);
% %                 set(lns,{'color'},num2cell(meanColors,2));
% %                 title('LTS fraction');
% %                 xlabel('time (s)');
% %                 ylabel('burst spikes / all spikes');
% %                 xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
% %                 xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
% %                 grid on;
                % --- burst quant END
                
                set(gcf,'color','w');
                
                noteText = {['event: ',eventFieldlabels{useEvent}],['class: ',unitTypes{ii_unitTypes}],['units: ',num2str(unitCount)],...
                    ['move: ',movementDir],['sortBy: ',timingField],['bins: ',num2str(nMeanBins)],['binMs: ',num2str(binMs)],...
                    [LH_RTMT_note]};
                addNote(h,noteText);
                
                saveFile = ['ev',eventFieldlabels{useEvent},'_un',unitTypes{ii_unitTypes},'_n',num2str(unitCount),...
                    '_movDir',movementDir,'_by',timingField,'_bins',num2str(nMeanBins),'_binMs',num2str(binMs),LH_RTMT_note];

                all_z_raw.(genvarname(strrep(saveFile,' ',''))) = z_raw;
                all_allTrial_z_sorted.(genvarname(strrep(saveFile,' ',''))) = allTrial_z_sorted;
                
                set(h,'PaperOrientation','landscape');
                set(h,'PaperUnits','normalized');
                set(h,'PaperPosition', [0 0 1 1]);
                if doSave
                    export_fig(gcf,'-dpdf', fullfile(savePath,[saveFile,'.pdf']));
                    save(fullfile(sessionsPath,[saveFile,datestr(now,'YYYYMMDD')]),'z_raw','meanBinsSeconds','mean_z','auc_min','auc_max','auc_max_t','auc_min_z','auc_max_z');
                end
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
z_smooth = 3;
bracketLegendText = {};
for iBin = 1:numel(meanBins)-1
    curTsBurst = [all_burstTs_sorted{meanBins(iBin):meanBins(iBin+1)}];
    curTs = [allTrial_tsPeths_sorted{meanBins(iBin):meanBins(iBin+1)}];
    mean_burstHist(iBin,:) = histcounts(curTsBurst,binEdges);
    mean_burstFraction(iBin,:) = mean_burstHist(iBin,:) ./ histcounts(curTs,binEdges);
    plot(binEdges(2:end),smooth(mean_burstHist(iBin,:),z_smooth),'color',meanColors(iBin,:),'lineWidth',2); hold on;
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
z_smooth = 1;
lns = [];
figure;
lns(1) = bar(binEdges(2:end),smooth(mean(mean_burstFraction(1:7,:)),z_smooth),'facecolor','r','edgecolor','none','facealpha',.3);
hold on;
lns(2) = bar(binEdges(2:end),smooth(mean(mean_burstFraction(8:10,:)),z_smooth),'facecolor','k','edgecolor','none','facealpha',.3);
xlim([-1 1]);
xlabel('time (s)');
ylabel('All Spikes / Spike Bursts');
grid on;
title('Fraction of Spikes in Bursts');
legend({'RT < 0.2 s','RT > 0.2 s'},'Location','northeast');
set(gca,'fontSize',16);
set(gcf,'color','w');


% burst occurence with z-score lines low/high RT
z_smooth = 1;
lns = [];
figuree(500,400);

yyaxis left;
lns(1) = bar(binEdges(2:end),smooth(mean(mean_burstHist(1:7,:)),z_smooth),'facecolor','r','edgecolor','none','facealpha',.3);
hold on;
lns(2) = bar(binEdges(2:end),smooth(mean(mean_burstHist(8:10,:)),z_smooth),'facecolor','k','edgecolor','none','facealpha',.3);
xlim([-1 1]);
xlabel('time (s)');
ylabel('Poisson bursts');
title('Poisson bursts vs. Low/High RT');
grid on;

yyaxis right;
lns = [];
lns(3) = plot(binEdges(2:end),smooth(mean(mean_z(1:7,:)),z_smooth),'-','color',meanColors(1,:),'lineWidth',2);
hold on
lns(4) = plot(binEdges(2:end),smooth(mean(mean_z(8:10,:)),z_smooth),'-','color',meanColors(8,:),'lineWidth',2);
xlim([-1 1])
grid on;
ylabel('bracketed z-score');

legend('BURST Low RT (<200ms)','BURST High RT','Z Low RT (<200ms)','Z High RT','location','northwest');
legend('boxoff');