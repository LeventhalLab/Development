savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientLFPevents/aggregate';
doSave = true;
doSetup = false;

sevFile = '';
timingFields = {'RT','MT'};
tWindow = 1;
medianMult = 6;
freqList = {[8 12;13 35;35 50]}; % beta

cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);

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

        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);

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

figuree(1200,500);
rows = 2;
cols = 4;
nBins = 10;
for iTiming = 1:2
    if iTiming == 1
        iEvent = 4;
    else
        iEvent = 6;
    end
    x_ff = [];
    y_ff = [];
    x_cv = [];
    y_cv = [];
    for iSession = 1:size(compiledTimes,1)
        allTimes = compiledTimes{iSession,iTiming};
        locs_dkl = compiledDKL{iSession,iTiming,iEvent};
%         locs_dkl = compiledJones{iSession,iTiming,iEvent};
        for iTrial = 1:numel(locs_dkl)
            if numel(locs_dkl{iTrial}) > 1
                x_cv = [x_cv allTimes(iTrial)];
                y_cv = [y_cv mean(diff(locs_dkl{iTrial}))];
            end
            x_ff = [x_ff allTimes(iTrial)];
            y_ff = [y_ff numel(locs_dkl{iTrial})];
        end
    end
    [x_cv_sorted,x_cv_key] = sort(x_cv);
    y_cv_sorted = y_cv(x_cv_key);
    binIdxs = floor(linspace(1,numel(x_cv),nBins+1));
    data_mean = [];
    data_std = [];
    data_var = [];
    for iBin = 1:nBins
        data_mean(iBin) = mean(y_cv_sorted(binIdxs(iBin):binIdxs(iBin+1)));
        data_std(iBin) = std(y_cv_sorted(binIdxs(iBin):binIdxs(iBin+1)));
        data_var(iBin) = var(y_cv_sorted(binIdxs(iBin):binIdxs(iBin+1)));
    end
    subplot(rows,cols,prc(cols,[iTiming,1]));
    errorbar(1:nBins,data_mean,data_std,'k');
    xlim([0 nBins+1]);
    xticks(0:nBins+1);
    xticklabels({'',1:nBins,''});
    title('IEI (samples) +/- std');
    xlabel([timingFields{iTiming},' bracket']);
    ylim([0 1200]);
    ylabel(eventFieldnames{iEvent});
    grid on;
    
    subplot(rows,cols,prc(cols,[iTiming,2]));
    plot(data_var./(data_mean.^2),'k');
    xlim([0 nBins+1]);
    xticks(0:nBins+1);
    xticklabels({'',1:nBins,''});
    title('CV^2 (var/mean^2)');
    ylim([0.25 0.5]);
    xlabel([timingFields{iTiming},' bracket']);
    grid on;
    
    [x_ff_sorted,x_ff_key] = sort(x_ff);
    y_ff_sorted = y_ff(x_ff_key);
    binIdxs = floor(linspace(1,numel(x_ff),nBins+1));
    data_mean = [];
    data_std = [];
    data_var = [];
    for iBin = 1:nBins
        data_mean(iBin) = mean(y_ff_sorted(binIdxs(iBin):binIdxs(iBin+1)));
        data_std(iBin) = std(y_ff_sorted(binIdxs(iBin):binIdxs(iBin+1)));
        data_var(iBin) = var(y_ff_sorted(binIdxs(iBin):binIdxs(iBin+1)));
    end
    subplot(rows,cols,prc(cols,[iTiming,3]));
    errorbar(1:nBins,data_mean,data_std,'k');
    xlim([0 nBins+1]);
    xticks(0:nBins+1);
    xticklabels({'',1:nBins,''});
    ylim([1 6]);
    title('# events +/- std');
    xlabel([timingFields{iTiming},' bracket']);
    grid on;
    
    subplot(rows,cols,prc(cols,[iTiming,4]));
    plot(data_var./data_mean,'k');
    xlim([0 nBins+1]);
    xticks(0:nBins+1);
    xticklabels({'',1:nBins,''});
    title('FF (var/mean)');
    ylim([0.75 1.25]);
    xlabel([timingFields{iTiming},' bracket']);
    grid on;
end
set(gcf,'color','w');

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
        ylim([-5 25]);
        ylabel('z');
        grid on;
    end
    set(gcf,'color','w');
end
