test_binMs = [10 20 50 100 500];
tWindow_zbaseline = 2;

for iNeuron = 1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['classifyUnitsToEvents: ',neuronName]);
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);

    useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
    tsPeths = eventsPeth(curTrials(useTrials),all_ts{iNeuron},tWindow_zbaseline,eventFieldnames);
    
    figure;
    
    all_std = [];
    all_mean = [];
    for iTests = 1:numel(test_binMs)
        cur_binMs = test_binMs(iTests);
        binS = cur_binMs / 1000;

        % skip if empty (incorrect)
        if ~any(size(tsPeths))
            continue;
        end
    %     ts_event1 = [tsPeths{:,1}];
        all_hValues = [];
        nBins_tWindow_zbaseline = [-tWindow_zbaseline:binS:0];
        for iTrial = 1:size(tsPeths,1)
            ts_event1 = tsPeths{iTrial,1};
            h = histogram(ts_event1,nBins_tWindow_zbaseline);
            all_hValues(iTrial,:) = h.Values / binS; % FR in spikes/sec
        end
        zStd = std(mean(all_hValues));
        zMean = mean(mean(all_hValues));
        all_std(iTests) = zStd;
        all_mean(iTests) = zMean;
    end
    
    subplot(211);
    plot(all_mean);
    title({neuronName,'','mean'});
    xticks(1:numel(test_binMs));
    xticklabels({'10 ms','20 ms','50 ms','100 ms','500 ms'});
    subplot(212);
    plot(all_std);
    title('std');
    xticks(1:numel(test_binMs));
    xticklabels({'10 ms','20 ms','50 ms','100 ms','500 ms'});
    hold on;
    
    % random samples
    figure;
    
    sampleTests = [10 100 200 500 1000];
    cur_binMs = 50;
    binS = cur_binMs / 1000;
    a = 0;
    b = max(all_ts{iNeuron});

    tsPeths = {};
    for iTests = 1:numel(sampleTests)
        r = (b-a).*rand(sampleTests(iTests),1) + a;
        for iir = 1:numel(r)
            tsPeths{iir,1} = tsPeth(all_ts{iNeuron},r(iir),tWindow_zbaseline);
        end
        all_hValues = [];
        nBins_tWindow_zbaseline = [-tWindow_zbaseline:binS:0];
        for iTrial = 1:size(tsPeths,1)
            ts_event1 = tsPeths{iTrial,1};
            h = histogram(ts_event1,nBins_tWindow_zbaseline);
            all_hValues(iTrial,:) = h.Values / binS; % FR in spikes/sec
        end
        zStd = std(mean(all_hValues));
        zMean = mean(mean(all_hValues));
        all_std(iTests) = zStd;
        all_mean(iTests) = zMean;
    end
    
    subplot(211);
    plot(all_mean);
    title({neuronName,'50ms bins','mean'});
    xticks(1:numel(sampleTests));
    xticklabels({'10','100','200','500','1000'});
    subplot(212);
    plot(all_std);
    title('std');
    xticks(1:numel(sampleTests));
    xticklabels({'10','100','200','500','1000'});
    hold on;
end