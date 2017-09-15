doSetup = true;
useDirSel = true;
limitToSide = 'contra';
timingField = 'RT';
requireZ = 1.5;
useEventPeth = 4;
useNeuronClasses = [4];
binMs = 50;
binS = binMs / 1000;
tWindow = 1;
binEdges = [-tWindow:binS:tWindow];
[~,zeroIdx] = find(binEdges >= 0,1);

if doSetup
    all_RT = [];
    all_MT = [];
    theta_z = [];
    theta_allTs = [];
    theta_burstTs = [];
    theta_allTs_centerIn = [];
    theta_burstTs_centerIn = [];
    trialCount = 1;
    for iNeuron = 1:numel(analysisConf.neurons)
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

        disp(['Using neuron ',num2str(iNeuron),' (class=',num2str(unitClasses(iNeuron)),...
            ', maxz=',num2str(unitEvents{iNeuron}.maxz(unitClasses(iNeuron))),') ',neuronName]);

        curTrials = all_trials{iNeuron};
        [useTrials,allTimes] = sortTrialsBy(curTrials,timingField); % forces correct
        trialIdInfo = organizeTrialsById(curTrials);
        tsPeths = {};
        ts = all_ts{iNeuron};
        z = zParams(ts,curTrials);
        zBinMean = z.FRmean * (binMs/1000);
        zBinStd = z.FRstd * (binMs/1000);
        tsPeths = eventsPeth(curTrials(useTrials),ts,tWindow,eventFieldnames);
        
        [archive_burst_RS,archive_burst_length,archive_burst_start] = burst(ts);
%             ts_burstStart = ts(archive_burst_start);
        tsBurst = [];
        for iBurst = 1:numel(archive_burst_start)
            tsBurst = [tsBurst;ts(archive_burst_start(iBurst):archive_burst_start(iBurst)+archive_burst_length(iBurst)-1)];
        end
        tsPeths_burst = eventsPeth(curTrials(useTrials),tsBurst,tWindow,eventFieldnames);

        useTimes = allTimes;
        usePeths = tsPeths;
        for iTrial = 1:numel(useTimes)
            curTs = usePeths{iTrial,useEventPeth};
            if numel(curTs) < 3; continue; end;
            curTsBurst = tsPeths_burst{iTrial,useEventPeth};
            
            curTrial = curTrials(useTrials(iTrial));
            curRT = curTrial.timing.RT;
            all_RT(trialCount) = curRT;
            curMT = curTrial.timing.MT;
            all_MT(trialCount) = curMT;

            counts = histcounts(curTs,binEdges);
            curZ = smooth((counts - zBinMean) / zBinStd,3);

            MTbins = round(curMT / binS);
            polarLinspace = linspace(0,2*pi,MTbins);
            [maxv,maxk] = max(curZ(zeroIdx:zeroIdx+MTbins-1));

            theta_z(trialCount) = polarLinspace(maxk);
            
            
            % top half of plot
            curTs_centerIn = usePeths{iTrial,2};
            curTsBurst_centerIn = tsPeths_burst{iTrial,2};
            theta_allTs_centerIn = [theta_allTs_centerIn curTs_centerIn];
            theta_burstTs_centerIn = [theta_burstTs_centerIn curTsBurst_centerIn];
            
            % bottom half of plot
            theta_allTs = [theta_allTs curTs(curTs >= 0 & curTs < curMT)];
            theta_burstTs = [theta_burstTs curTsBurst(curTsBurst >= 0 & curTsBurst < curMT)];
            
            
            trialCount = trialCount + 1;
        end
    end
end

doplot1 = true;
doplot2 = false;

if doplot1
    colors = lines(4);
    nbins = 24;
    lowRT = .2;
    lowMT = .25;
    lowRTMT = lowRT + lowMT;
    faceAlpha = 0.3;

    figuree(800,800);
    subplot(221);
    polarhistogram(theta_z,nbins,'FaceColor',colors(2,:),'EdgeColor',colors(2,:),'FaceAlpha',faceAlpha,'normalization','probability');
    thetaticks([0]);
    thetaticklabels({'nose out \rightarrow side in'});
    title('Fraction of Trials, Max Spike Time');
    legend('All Trials','location','south');

    subplot(222);
    polarhistogram(theta_z(all_RT <= lowRT),nbins,'FaceColor',colors(1,:),'EdgeColor',colors(1,:),'FaceAlpha',faceAlpha,'normalization','probability');
    hold on;
    polarhistogram(theta_z(all_RT > lowRT),nbins,'FaceColor',colors(3,:),'EdgeColor',colors(3,:),'FaceAlpha',faceAlpha,'normalization','probability');
    thetaticks([0]);
    thetaticklabels({'nose out \rightarrow side in'});
    title('Fraction of Trials, Max Spike Time');
    legend({'Low RT','High RT'},'location','south');

    subplot(223);
    polarhistogram(theta_z(all_MT <= lowMT),nbins,'FaceColor',colors(1,:),'EdgeColor',colors(1,:),'FaceAlpha',faceAlpha,'normalization','probability');
    hold on;
    polarhistogram(theta_z(all_MT > lowMT),nbins,'FaceColor',colors(3,:),'EdgeColor',colors(3,:),'FaceAlpha',faceAlpha,'normalization','probability');
    thetaticks([0]);
    thetaticklabels({'nose out \rightarrow side in'});
    title('Fraction of Trials, Max Spike Time');
    legend({'Low MT','High MT'},'location','south');

    subplot(224);
    polarhistogram(theta_z(all_RT+all_MT <= lowRTMT),nbins,'FaceColor',colors(1,:),'EdgeColor',colors(1,:),'FaceAlpha',faceAlpha,'normalization','probability');
    hold on;
    polarhistogram(theta_z(all_RT+all_MT > lowRTMT),nbins,'FaceColor',colors(3,:),'EdgeColor',colors(3,:),'FaceAlpha',faceAlpha,'normalization','probability');
    thetaticks([0]);
    thetaticklabels({'nose out \rightarrow side in'});
    title('Fraction of Trials, Max Spike Time');
    legend({'Low RT+MT','High RT+MT'},'location','south');
end

if doplot2
    nbins = 12;
    % top half of plot
    counts_allTs_centerIn = histcounts(theta_allTs_centerIn,linspace(0,1,nbins));
    counts_allTsBurst_centerIn = histcounts(theta_burstTs_centerIn,linspace(0,1,nbins));
    burstFractionBins_centerIn = counts_allTs_centerIn - counts_allTsBurst_centerIn;
    
    % bottom half of plot
    counts_allTs = histcounts(theta_allTs,linspace(0,1,nbins));
    counts_allTsBurst = histcounts(theta_burstTs,linspace(0,1,nbins));
    burstFractionBins = counts_allTs - counts_allTsBurst;
    
    figuree(800,800);
    polarhistogram('BinEdges',linspace(0,pi,nbins),'BinCounts',burstFractionBins_centerIn,'FaceColor',colors(1,:),'EdgeColor',colors(3,:),'FaceAlpha',faceAlpha,'normalization','probability');
    hold on;
    polarhistogram('BinEdges',linspace(pi,2*pi,nbins),'BinCounts',burstFractionBins,'FaceColor',colors(3,:),'EdgeColor',colors(3,:),'FaceAlpha',faceAlpha,'normalization','probability');
    thetaticks([0 90 180]);
    thetaticklabels({'side in','nose in','nose out'});
    title('Fraction of spikes in burst');
%     legend('Fraction of spikes in burst','location','south');
end