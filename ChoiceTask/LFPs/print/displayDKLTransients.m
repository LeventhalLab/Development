doCompile = false;
doPlot = true;

sevFile = '';
iEvent = 4;
tWindow = 1;
medianMult = 6;
timingField = 'RT';
freqList = {[8 15;15 25;25 45;1 200]};

if doCompile
    locs_dkl_all = {};
    locs_jones_all = {};
    allTimes_all = {};
    f = waitbar(0,'Processing LFP Data...');
    for iNeuron = 1:numel(LFPfiles_local)
        % only unique sev files
        if strcmp(sevFile,LFPfiles_local{iNeuron})
            continue;
        end
        waitbar(iNeuron/numel(LFPfiles_local),f);
        disp(num2str(iNeuron));
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,timingField);
        allTimes_all{iNeuron} = allTimes;

        [sev,header] = read_tdt_sev(sevFile);
        decimateFactor = 10;
        sevFilt = decimate(double(sev),decimateFactor);
        clear sev;

        Fs = header.Fs / decimateFactor;
        LFP = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        [locs_dkl,locs_jones] = lfpPeakDetect(LFP(:,:,:,1:3),iEvent,medianMult);
        locs_dkl_all{iNeuron} = locs_dkl;
        locs_jones_all{iNeuron} = locs_jones;
    end
    close(f);
end

if doPlot 
    % compile all locs/RT to do sort
    compiled_locs_dkl = [];
    sortTimes_dkl = [];
    compiled_locs_jones = [];
    sortTimes_jones = [];
    trialCount = 0;
    sortArr = [];
    for iNeuron = 1:numel(allTimes_all)
    if isempty(allTimes_all)
        continue;
    end
    for iTrial = 1:numel(allTimes_all{iNeuron})
        trialCount = trialCount + 1;
        sortArr(trialCount) = allTimes_all{iNeuron}(iTrial);
        compiled_locs_dkl{trialCount} = (locs_dkl_all{iNeuron}{iTrial}/size(LFP,2)*2) - 1;
        compiled_locs_jones{trialCount} = (locs_jones_all{iNeuron}{iTrial}/size(LFP,2)*2) - 1;
    end
    end

    % first build the scatter structures, then do deciles
    [v,k] = sort(sortArr);
    compiled_locs_dkl_sorted = compiled_locs_dkl(k);
    compiled_locs_jones_sorted = compiled_locs_jones(k);
    x_dkl = [];
    y_dkl = [];
    x_jones = [];
    y_jones = [];
    for iTrial = 1:numel(k)
        x_dkl = [x_dkl compiled_locs_dkl_sorted{iTrial}];
        y_dkl = [y_dkl repmat(iTrial,size(compiled_locs_dkl_sorted{iTrial}))];
        x_jones = [x_jones compiled_locs_jones_sorted{iTrial}];
        y_jones = [y_jones repmat(iTrial,size(compiled_locs_jones_sorted{iTrial}))];
    end

    methodLabels = {'DKL','Jones'};
    figuree(700,700);
    for iPlot = 1:2
        subplot(2,2,iPlot);
        if iPlot == 1
            usex = x_dkl;
            usey = y_dkl;
        else
            usex = x_jones;
            usey = y_jones;
        end
        scatter(usex,usey,4,'k','filled');
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        ylim([1 numel(compiled_locs_jones_sorted)]);
        yticks(ylim);
        ylabel('SLOW \leftarrow trials \rightarrow FAST');
        set(gca,'YDir','reverse');
        title(methodLabels{iPlot});
        grid on;
    end
    
    x_dkl = [];
    y_dkl = [];
    x_jones = [];
    y_jones = [];
    for iTrial = 1:numel(k)
        x_dkl = [x_dkl compiled_locs_dkl_sorted{iTrial}];
        y_dkl = [y_dkl repmat(v(iTrial),size(compiled_locs_dkl_sorted{iTrial}))];
        x_jones = [x_jones compiled_locs_jones_sorted{iTrial}];
        y_jones = [y_jones repmat(v(iTrial),size(compiled_locs_jones_sorted{iTrial}))];
    end
    nBins = 5;
    histBins = -1:0.05:1;
    colors = cool(nBins);
    for iPlot = 1:2
        subplot(2,2,iPlot+2);
        if iPlot == 1
            usex = x_dkl;
        else
            usex = x_jones;
        end
        timeIntervals = floor(linspace(1,numel(usex),nBins+1));
        for iBin = 1:nBins
            theseLocs = usex(timeIntervals(iBin):timeIntervals(iBin+1));
            counts = histcounts(theseLocs,histBins);
            plot(linspace(-1,1,numel(histBins)-1),smooth(counts,3),'color',colors(iBin,:),'lineWidth',2);
            hold on;
        end
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        ylim([0 400]);
        yticks(ylim);
        ylabel('bin count');
        grid on;
    end 
end