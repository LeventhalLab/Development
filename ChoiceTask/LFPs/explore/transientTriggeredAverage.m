doPlot = true;

freqList = [3.5,8,12,20,50,80,100];
iFreq = 5;
if iFreq == 4
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientTiming/TTA/20 Hz';
else
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientTiming/TTA/50 Hz';
end
useEvents = [3,4];
iEvent = 2; % Nose Out
tWindow = 2; % for tsPeths
tWindow_vis = 1; % because W is +/- 1s
all_TTA = [];
condLabels = {'-1s to 0s','0s to 1s','-1s to 1s'};
for iNeuron = 1:numel(LFPfiles_local)
    disp(num2str(iNeuron));
    if ~isempty(find(W_key(:,1) == iNeuron,1))
        useNeuron = iNeuron;
    end
    curPower = squeeze(squeeze(W_power(iFreq,iEvent,W_key(:,1) == useNeuron,:)));
    trials = all_trials{iNeuron};
    [trialIds,allTimesRT] = sortTrialsBy(trials,'RT');
    ts = all_ts{iNeuron};
    tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
    
    cutoffPower = mean(W_median(:,iFreq)) * 6;
    periTrialTs = {};
    sumLocs = [];
    for iCond = 1:3
        periTrialTs{iCond} = [];
        sumLocs(iCond) = 0;
        for iTrial = 1:size(tsPeths,1)
            trialTs = tsPeths{iTrial,iEvent};
            [locs,pks] = peakseek(curPower(iTrial,:),round(size(curPower,2)/2/freqList(iFreq)),cutoffPower);
            locsTs = (locs/size(curPower,2)*2) - 1;
            switch iCond
                case 1
                    locsTs = locsTs(locsTs <= 0);
                case 2
                    locsTs = locsTs(locsTs > 0);
            end
            sumLocs(iCond) = sumLocs(iCond) + numel(locsTs);
            for iTs = 1:numel(trialTs)
                periTrialTs{iCond} = [periTrialTs{iCond} locsTs + trialTs(iTs)];
            end
        end
    end
    nBins = 100;
    t = linspace(-tWindow,tWindow,nBins);
    nSmooth = 3;
    binEdges = linspace(-tWindow,tWindow,nBins+1);
    colors = [0 1 0;1 0 0;0 0 0];
    if doPlot
        h = figuree(800,500);
    end
    for iCond = 1:3
        counts = histcounts(periTrialTs{iCond},binEdges);
        counts_inRange = counts(nBins/4:(nBins/4)*3);
        counts_z = smooth((counts - mean(counts_inRange)) ./ std(counts_inRange),nSmooth);
        all_TTA(iNeuron,iCond,:) = counts_z;
        if doPlot
            plot(t,counts_z,'-','lineWidth',2,'color',colors(iCond,:));
            hold on;
        end
    end
    
    if doPlot
        xlim([-tWindow_vis tWindow_vis]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        ylim([-3 3]);
        yticks(sort([ylim,0]));
        ylabel('z-score');
        grid on;
        title({...
            ['u',num2str(iNeuron,'%03d'),' spike times'],...
            [num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
            [eventFieldnames{useEvents(iEvent)},' (trials = ',num2str(size(tsPeths,1)),')']...
            });
        legend({[condLabels{1},' (n = ',num2str(sumLocs(1)),')']...
            [condLabels{2},' (n = ',num2str(sumLocs(2)),')']...
            [condLabels{3},' (n = ',num2str(sumLocs(3)),')']});

        set(gcf,'color','w');
        saveFile = ['u',num2str(iNeuron,'%03d'),'_',num2str(freqList(iFreq)),'Hz_',eventFieldnames{useEvents(iEvent)},'.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end

figuree(800,500);
for iCond = 1:3
    plot(t,nanmedian(squeeze(all_TTA(:,iCond,:))),'-','lineWidth',2,'color',colors(iCond,:));
    hold on;
end
xlim([-tWindow_vis tWindow_vis]);
xticks(sort([xlim 0]));
xlabel('time (s)');
ylim([-0.5 0.5]);
yticks(sort([ylim,0]));
ylabel('firing rate z-score');
grid on;
title({...
    [num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
    [eventFieldnames{useEvents(iEvent)}]...
    });
legend(condLabels);