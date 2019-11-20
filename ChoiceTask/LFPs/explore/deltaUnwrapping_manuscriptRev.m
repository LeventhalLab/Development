% close all;
doPlot1 = false;
doPlot2 = true;
savePath = '/Users/matt/Desktop/unwrapped';
if doPlot1
    useEvents = 4;
    useTrials = 1:10;
    rows = 4;
    cols = 2;
    for iEvent = useEvents
        h = ff(600,800);
        thisPhase = squeeze(dataPhase(iEvent,:,:));

        natPhase = (2*pi)/(size(thisPhase,2)/(tWindow*2)/freqList);

        t = linspace(-tWindow,tWindow,size(thisPhase,2));
        for iTrial = useTrials
            subplot(rows,cols,prc(cols,[1,1]));
            plot(t,thisPhase(iTrial,:));
            hold on;
        end
        xlabel('time (s)');
        ylabel('phase');
        title({['showing ',num2str(max(useTrials)),' trials'],['event ',num2str(iEvent)]});

        t = linspace(-tWindow,tWindow,size(thisPhase,2));
        for iTrial = useTrials
            subplot(rows,cols,prc(cols,[2,1]));
            plot(t,unwrap(thisPhase(iTrial,:)));
            hold on;
        end
        xlabel('time (s)');
        title('1. unwrapped');
        ylabel('~phase');

        t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
        for iTrial = useTrials
            subplot(rows,cols,prc(cols,[3,1]));
            plot(t,diff(unwrap(thisPhase(iTrial,:))));
            hold on;
        end
        xlabel('time (s)');
        title('2. diff(unwrapped)');
        ylabel('~phase');
        ylim([-.05 .05]);

        t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
        for iTrial = useTrials
            subplot(rows,cols,prc(cols,[4,1]));
            plot(t,diff(unwrap(thisPhase(iTrial,:))) - natPhase);
            hold on;
        end
        xlabel('time (s)');
        title({'3. diff(unwrapped) - 2.5 Hz baseline'});
        ylabel('~phase');
        ylim([-.05 .05]);
        plot(xlim,[-natPhase,-natPhase],'r:');
        plot(xlim,[natPhase,natPhase],'r:');

        t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
        for iTrial = useTrials
            subplot(rows,cols,prc(cols,[1,2]));
            plot(t,abs(diff(unwrap(thisPhase(iTrial,:))) - natPhase));
            hold on;
        end
        xlabel('time (s)');
        title({'4. abs(diff(unwrapped) - 2.5 Hz baseline)'});
        ylabel('~phase');
        ylim([0 .05]);

        t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
        vals = [];
        for iTrial = useTrials
            subplot(rows,cols,prc(cols,[2,2]));
            vals(iTrial,:) = abs(diff(unwrap(thisPhase(iTrial,:))) - natPhase);
        % %     plot(t,vals(iTrial,:));
        % %     hold on;
        end
        plot(t,mean(vals),'k','linewidth',2);
        legend({'mean'});
        xlabel('time (s)');
        title({'5. mean(abs(diff(unwrapped) - 2.5 Hz baseline))'});
        ylabel('~phase');
        ylim([0 .005]);
        ax = gca;
        ax.YAxis.Exponent = 0;

        % hz = phaseShiftToHz(tWindow,size(thisPhase,2),yvals)
        thresh = hzToPhaseShift(tWindow,size(thisPhase,2),freqList);
        t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
        all_pos = [];
        all_neg = [];
        for iTrial = useTrials
            t = diff(unwrap(thisPhase(iTrial,:))) - natPhase;
            pos_locs = peakseek(t,size(thisPhase,2)/10,thresh);
            neg_locs = peakseek(-t,size(thisPhase,2)/10,thresh);
            all_pos = [all_pos,pos_locs];
            all_neg = [all_neg,neg_locs];
        end
        nBins = 41;
        subplot(rows,cols,prc(cols,[4,2]));
        counts = histcounts(all_pos,linspace(1,size(t,2),nBins));
        bar(linspace(-tWindow,tWindow,nBins-1),counts/max(useTrials),'facecolor','k','edgecolor','none');
        hold on;
        counts = histcounts(all_neg,linspace(1,size(t,2),nBins));
        bar(linspace(-tWindow,tWindow,nBins-1),-counts/max(useTrials),'facecolor','m','edgecolor','none');
        ylabel({'fraction of trials','w/ phase reset'})
        ylim auto;
        maxy = max(abs(ylim))+.005;
        ylim([-maxy maxy]);
        title({'Phase "resets" (>2x \delta)'});
        saveas(h,fullfile(savePath,['viewPhaseReset_event',num2str(iEvent),'_',...
            num2str(max(useTrials)),'trials.fig']));
        close(h);
    end
end

if doPlot2
    h = ff(1400,600);
    rows = 2;
    cols = 8;
    for iEvent = 1:8
        thisPhase = squeeze(dataPhase(iEvent,:,:));
        thresh = hzToPhaseShift(tWindow,size(thisPhase,2),freqList);
        t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
        all_pos = [];
        all_neg = [];
        for iTrial = 1:size(thisPhase,1)
            t = diff(unwrap(thisPhase(iTrial,:))) - natPhase;
            pos_locs = peakseek(t,size(thisPhase,2)/10,thresh);
            neg_locs = peakseek(-t,size(thisPhase,2)/10,thresh);
            all_pos = [all_pos,pos_locs];
            all_neg = [all_neg,neg_locs];
        end
        nBins = 21;
        subplot(rows,cols,prc(cols,[1,iEvent]));
        counts = histcounts(all_pos,linspace(1,size(t,2),nBins));
        bar(linspace(-tWindow,tWindow,nBins-1),counts/size(thisPhase,1),'facecolor','k','edgecolor','none');
        hold on;
        counts = histcounts(all_neg,linspace(1,size(t,2),nBins));
        bar(linspace(-tWindow,tWindow,nBins-1),-counts/size(thisPhase,1),'facecolor','m','edgecolor','none');
        ylim([-.02 .02]);
        title({eventFieldnames_wFake{iEvent},'Phase "resets"','(>2x \delta)'});
        if iEvent == 1
            ylabel({'fraction of trials','w/ phase reset'})
        end
        if iEvent == 8
            legend({'fwd reset','rev reset'});
            legend boxoff;
        end
        
        subplot(rows,cols,prc(cols,[2,iEvent]));
        pos_counts = histcounts(all_pos,linspace(1,size(t,2),nBins));
        neg_counts = histcounts(all_neg,linspace(1,size(t,2),nBins));
        plot(linspace(-tWindow,tWindow,nBins-1),pos_counts/size(thisPhase,1),'k','linewidth',1);
        hold on;
        plot(linspace(-tWindow,tWindow,nBins-1),neg_counts/size(thisPhase,1),'m','linewidth',1);
        plot(linspace(-tWindow,tWindow,nBins-1),(pos_counts+neg_counts)/size(thisPhase,1),'b','linewidth',2);
        ylim([0 .03]);
        if iEvent == 1
            ylabel({'fraction of trials','w/ phase reset'})
        end
        if iEvent == 8
            legend({'fwd reset','rev reset','both'});
            legend boxoff;
        end
    end
    tightfig;
    saveas(h,fullfile(savePath,'viewPhaseReset_allEvents_allTrials.fig'));
    close(h);
end