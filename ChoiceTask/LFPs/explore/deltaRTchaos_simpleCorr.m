if ~exist('selectedLFPFiles')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'all_trials')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
end
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allTrials';

doSetup = false;
doSetup2 = false;
doSave = true;
zThresh = 5;
tWindow = 1;
freqList = {[1 4;4 8;13 30;30 70]};
freqList = 2.5;
Wlength = 400;
midId = round(Wlength/2);
eventFieldnames_wFake = {eventFieldnames{:} 'interTrial'};

cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/magma.png';
cmap = mycmap(cmapPath);

if false
    cueNoseOut = [];
    trialCount = 0;
    for iNeuron = selectedLFPFiles'
        sevFile = LFPfiles_local{iNeuron};
        trials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        trials = trials(trialIds);
        for iTrial = 1:numel(trials)
            trialCount = trialCount + 1;
            cueNoseOut(trialCount) = trials(iTrial).timestamps.centerOut - trials(iTrial).timestamps.cueOn;
        end
    end
    disp(['Cue to Nose Out -> mean: ',num2str(mean(cueNoseOut),2),', std: ',num2str(std(cueNoseOut),2)]);
end

if doSetup2
    nSurr = 20;
    allMids = [];
    for iSurr = 1:nSurr
        trial_Wz_phase = [];
        trialCount = 0;
        iSession = 0;
        for iNeuron = selectedLFPFiles'
            iSession = iSession + 1;
            disp(iSession);
            sevFile = LFPfiles_local{iNeuron};
            trials = all_trials{iNeuron};
            trials = addEventToTrials(trials,'interTrial');
            [trialIds,allTimes] = sortTrialsBy(trials,'RT');
            [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
            sevFilt = artifactThresh(sevFilt,[1],2000);
            sevFilt = sevFilt - mean(sevFilt);

            [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow*2,Fs,freqList,{eventFieldnames_wFake{8}});
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
            
            trialCount = trialCount + size(Wz_power,3);
            % iEvent, iTrial, iTime, iFreq
            if iSession == 1
                trial_Wz_phase = Wz_phase;
            else
                trial_Wz_phase(:,:,size(trial_Wz_phase,3)+1:trialCount,:) = Wz_phase;
            end
        end
        allMids(iSurr) = circ_r(squeeze(trial_Wz_phase(1,midId,:)));
    end
end

if doSetup
    trial_Wz_power = [];
    trial_Wz_phase = [];
    session_Wz_rayleigh_pval = [];
    compiledRTs = [];
    iSession = 0;
    trialCount = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        sevFile = LFPfiles_local{iNeuron};
        trials = all_trials{iNeuron};
        trials = addEventToTrials(trials,'interTrial');
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        sevFilt = artifactThresh(sevFilt,[1],2000);
        sevFilt = sevFilt - mean(sevFilt);
        
        [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow*2,Fs,freqList,eventFieldnames_wFake);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        compiledRTs = [compiledRTs allTimes(keepTrials)];
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
        
        trialCount = trialCount + size(Wz_power,3);
        % iEvent, iTrial, iTime, iFreq
        if iSession == 1
            trial_Wz_power = Wz_power;
            trial_Wz_phase = Wz_phase;
        else
            trial_Wz_power(:,:,size(trial_Wz_power,3)+1:trialCount,:) = Wz_power;
            trial_Wz_phase(:,:,size(trial_Wz_phase,3)+1:trialCount,:) = Wz_phase;
        end
    end
    data_source = {trial_Wz_power trial_Wz_phase};
end

% % save('deltaRTchaos_data_source_20181208','trial_Wz_power','trial_Wz_phase','compiledRTs');

[RTv,RTk] = sort(compiledRTs);
bandLabels = {'\delta','\theta','\beta','\gamma'};
titleLabels = {'power','phase'};

pThresh = .001;
intv = 100;
useRange = intv:intv:numel(RTv);

% > plots
if false
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/collapse';
    doPlot_catchRange = false;
    doPlot_collapse = true;
    catchRange = closest(useRange,900); % catch ~40% of RT

    for iCond = 1:2
        if doPlot_catchRange || doPlot_collapse
            h = ff(1500,800);
            rows = 4;
            cols = 7;
        end
        useData = data_source{iCond};
        eventCount = 0;
        for iEvent = 1:7
            eventCount = eventCount + 1;
            for iFreq = 1:4
                thisData = squeeze(useData(iEvent,:,RTk,iFreq)); % !! Add RTk here
                pCollapse = NaN(numel(useRange),numel(useRange));
                pMat = [];
                range_log = [];
                for iRange = 1:numel(useRange)-1
                    disp(iRange);
                    curRange = useRange(iRange);
                    centerCount = 0;
                    for RTcenter = useRange(iRange:end-iRange)
                        centerCount = centerCount + 1;
                        RTrange = (RTcenter - curRange + 1) : (RTcenter + curRange);
                        range_log = [range_log numel(RTrange)];
                        all_pval = [];
                        all_rho = [];
                        for iTime = 1:size(thisData,1)
                            if iCond == 1
                                [rho,pval] = corr(thisData(iTime,RTrange)',RTv(RTrange)');
                            else
                                [rho,pval] = circ_corrcl(thisData(iTime,RTrange)',RTv(RTrange)');
                            end
                            all_pval(iTime) = pval;
                            all_rho(iTime) = rho;
                        end
                        pCollapse(find(useRange == curRange),find(useRange == RTcenter)) = sum(all_pval < pThresh);
                        if iRange == catchRange
                            pMat(centerCount,:) = all_pval;
                        end
                    end
                end
                % do plot
                if doPlot_catchRange
                    subplot(rows,cols,prc(cols,[iFreq,iEvent]));
                    imagesc(pMat);
                    colormap(magma);
                    set(gca,'ydir','normal');
                    caxis([0 .001]);
                    title([bandLabels{iFreq},'-',titleLabels{iCond},' at ',eventFieldnames{iEvent}]);
                    drawnow;
                end
                if doPlot_collapse
                    xInt = 5;
                    
                    subplot(rows,cols,prc(cols,[iFreq,iEvent])); % eventCount
                    imagesc((100*pCollapse/numel(all_pval))');
                    colormap(magma);
                    caxis([0 100]);
                    cb = colorbar;
                    cb.Ticks = caxis;
                    cb.Label.String = ['p < ',num2str(pThresh,'%1.3f'),' (% window)'];
                    xlabel('RT range (%)');
                    ylabel('RT center (s)');

                    xtickVals = floor(linspace(0,numel(unique(range_log)),xInt));
                    xticks(xtickVals);
                    xtickLabelVals = linspace(0,100,xInt);
                    xticklabels(compose('%3.0f',xtickLabelVals));
                    xtickangle(270);
                    xlim([1 max(xtickVals)]);

                    yInt = 11;
                    ytickVals = floor(linspace(1,numel(useRange),yInt));
                    yticks(ytickVals);
                    yticklabels(compose('%1.2f',RTv(useRange(ytickVals))));
                    set(gca,'ydir','normal');
                    title([bandLabels{iFreq},'-',titleLabels{iCond},' at ',eventFieldnames{iEvent}]);
        % %             set(gca,'fontSize',14);
                    drawnow;
                end
            end
        end
        if doPlot_collapse || doPlot_catchRange
            set(gcf,'color','w');
            if doSave
                saveas(h,fullfile(savePath,['collapseRT_',titleLabels{iCond},'.png']));
                close(h);
            end
        end
    end
end

% all phase/power peri-event plots
if true
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allTrials';
    rows = 1;%size(trial_Wz_power,4);
    useEvents = 1:7;
    cols = numel(useEvents);
    cmaps = {'jet','parula'};
    caxisVals = {[-2 4],[-pi pi]};
    for iCond = 2%1:2
        for iFreq = 1:size(trial_Wz_power,4)
            h = ff(1400,800);
            useData = data_source{iCond};
            for iEvent = useEvents
                subplot(rows,cols,prc(cols,[1,iEvent]));
                thisData = squeeze(useData(iEvent,:,RTk,iFreq));
                imagesc(linspace(-tWindow,tWindow,size(thisData,1)),1:numel(RTv),thisData');
                colormap(gca,cmaps{iCond});
                caxis(caxisVals{iCond});
                title({[eventFieldnames{iEvent},' - ',titleLabels{iCond}],bandLabels{iFreq}});
                if iEvent == 1
                    ylabel('RT (s)');
                    yticklabels(compose('%1.2f',RTv(yticks)));
                else
                    yticklabels([]);
                end
                xticks([-tWindow,0,tWindow]);
                xlabel('Time (s)');
                grid on;
            end
            set(gcf,'color','w');
            if doSave
                filename = strjoin({titleLabels{iCond},strrep(bandLabels{iFreq},'\','')},'_');
                saveas(h,fullfile(savePath,[filename,'.png']));
                close(h);
            end
        end
    end
end

if false
    iCond = 2;
    iFreq = 1;
    allStds = [];
    for iEvent = 1:8
        useData = data_source{iCond};
        thisData = squeeze(useData(iEvent,:,RTk,iFreq));
        allStds(iEvent) = circ_r(thisData(midId,:)');
    end
    h = ff(500,300);
    bar(allStds,'k');
    hold on
    for iEvent = 1:numel(allStds)
        text(iEvent,allStds(iEvent)+0.05,num2str(allStds(iEvent),2),'horizontalAlignment','center');
    end
    plot(xlim,[min(allMids) min(allMids)],'r-');
    lns = plot(xlim,[max(allMids) max(allMids)],'r-');
    set(gcf,'color','w');
    xticklabels(eventFieldnames_wFake);
    xtickangle(30);
    ylim([0 0.6]);
    yticks(ylim);
    ylabel('MRL');
    title('MRL at t = 0');
    legend(lns,{'chance (n = 20)'});
    if doSave
        saveas(h,fullfile(savePath,['deltaMRL_wChanceLines.png']));
        close(h);
    end
end