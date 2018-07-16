savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientLFPevents/aggregate';
doSave = true;
doSetup = false;

sevFile = '';
timingFields = {'RT','MT'};
tWindow = 1;
medianMult = 6;
decimateFactor = 10;
freqList = {[8 15;15 25;25 45]}; % beta

if doSetup
    compiledDKL = {};
    compiledJones = {};
    compiledTimes = {};
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        curTrials = all_trials{iNeuron};

        [sev,header] = read_tdt_sev(sevFile);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        clear sev;

        for iTiming = 1:2
            [trialIds,allTimes] = sortTrialsBy(curTrials,timingFields{iTiming});
            LFP = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
            compiledTimes{iSession,iTiming} = allTimes;
            for iEvent  = 1:7
                [locs_dkl,locs_jones] = lfpPeakDetect(LFP,iEvent,medianMult);
                compiledDKL{iSession,iTiming,iEvent} = locs_dkl;
                compiledJones{iSession,iTiming,iEvent} = locs_jones;
            end
        end
    end
end

figuree(1400,900);
rows = 4;
cols = 7;
nLines = 3;
nBins = 30;
colors = cool(nLines);
for iTiming = 1:2
    if true
        useXT = [];
        allEventDKL = [];
        trialCount = zeros(7,1);
        x = {};
        y = {};
        for iSession = 1:size(compiledDKL,1)
            for iEvent = 1:7
                if iSession == 1
                    x{iEvent} = [];
                    y{iEvent} = [];
                    useXT{iEvent} = [];
                end
                theseDKL = compiledDKL{iSession,iTiming,iEvent};
                theseTimes = compiledTimes{iSession,iTiming};
                for iTrial = 1:numel(theseDKL)
                    trialCount(iEvent) = trialCount(iEvent) + 1;
                    for iPoint = 1:numel(theseDKL{iTrial})
                        x{iEvent} = [x{iEvent} (theseDKL{iTrial}(iPoint)/size(LFP,2)*2) - 1];
                        y{iEvent} = [y{iEvent} trialCount(iEvent)];
                        useXT{iEvent} = [useXT{iEvent} theseTimes(iTrial)];
                    end
                end
            end
        end
    end
    refCounts = [];
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[iTiming*2-1,iEvent]));
        theseXT = useXT{iEvent};
        [theseXT_sorted,kXT] = sort(theseXT);
        xkXT = x{iEvent}(kXT);
        scatter(xkXT,1:numel(kXT),4,'k','filled');
        hold on;
        if iTiming == 1
            if iEvent == 3
                plot(theseXT_sorted,1:numel(kXT),'b','linewidth',2);
                xlabel('(centerOut)','color','b');
            elseif iEvent == 4
                plot(-theseXT_sorted,1:numel(kXT),'b','linewidth',2);
                xlabel('(tone)','color','b');
            end
        else
            if iEvent == 4
                plot(theseXT_sorted,1:numel(kXT),'r','linewidth',2);
                xlabel('(sideIn)','color','r');
            elseif iEvent == 5
                plot(-theseXT_sorted,1:numel(kXT),'r','linewidth',2);
                xlabel('(centerOut)','color','r');
            end
        end
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        ylim([1 numel(kXT)]);
        yticks(ylim);
        yticklabels({['min ',timingFields{iTiming}],['max ',timingFields{iTiming}]});
        ytickangle(90);
        title({eventFieldnames{iEvent},['sorted by ',timingFields{iTiming}]});
        grid on;
        
        binEdges = floor(linspace(1,numel(kXT),nLines+1));
        subplot(rows,cols,prc(cols,[iTiming*2,iEvent]));
        for iBin = 1:nLines
            counts = histcounts(xkXT(binEdges(iBin):binEdges(iBin+1)),linspace(-1,1,nBins));
            if iEvent == 1
                refCounts = counts;
            end
            zCounts = (counts - mean(refCounts)) ./ std(refCounts);
            plot(linspace(-1,1,numel(counts)),zCounts,'lineWidth',2,'color',colors(iBin,:));
            hold on;
        end
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        ylim([-5 15]);
        ylabel('z');
        grid on;
    end
    set(gcf,'color','w');
end
