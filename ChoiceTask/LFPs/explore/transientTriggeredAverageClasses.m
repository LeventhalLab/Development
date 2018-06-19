% all_TTA_50Hz 366     3   100

for iFreq = 4:5
    if iFreq == 4
        all_TTA = all_TTA_20Hz;
    else
        all_TTA = all_TTA_50Hz;
    end

    % DIR SEL
    figuree(700,900);
    subplot(321);
    for iCond = 1:3
        plot(t,nanmean(squeeze(all_TTA(:,iCond,:))),'-','lineWidth',2,'color',colors(iCond,:));
        hold on;
    end
    xlim([-tWindow_vis tWindow_vis]);
    xticks(sort([xlim 0]));
    xlabel('time (s)');
    ylim([-0.75 0.75]);
    yticks(sort([ylim,0]));
    ylabel('firing rate z-score');
    grid on;
    title({...
        ['All Units ',num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
        [eventFieldnames{useEvents(iEvent)}]...
        });
    legend(condLabels);

    subplot(323);
    for iCond = 1:3
        plot(t,nanmean(squeeze(all_TTA(ndirSelUnitIds,iCond,:))),'-','lineWidth',2,'color',colors(iCond,:));
        hold on;
    end
    xlim([-tWindow_vis tWindow_vis]);
    xticks(sort([xlim 0]));
    xlabel('time (s)');
    ylim([-0.75 0.75]);
    yticks(sort([ylim,0]));
    ylabel('firing rate z-score');
    grid on;
    title({...
        ['~Dir Units ',num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
        [eventFieldnames{useEvents(iEvent)}]...
        });
    legend(condLabels);

    subplot(325);
    for iCond = 1:3
        plot(t,nanmean(squeeze(all_TTA(dirSelUnitIds,iCond,:))),'-','lineWidth',2,'color',colors(iCond,:));
        hold on;
    end
    xlim([-tWindow_vis tWindow_vis]);
    xticks(sort([xlim 0]));
    xlabel('time (s)');
    ylim([-0.75 0.75]);
    yticks(sort([ylim,0]));
    ylabel('firing rate z-score');
    grid on;
    title({...
        ['Dir Units ',num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
        [eventFieldnames{useEvents(iEvent)}]...
        });
    legend(condLabels);

    % UNIT CLASS
    subplot(322);
    for iCond = 1:3
        plot(t,nanmean(squeeze(all_TTA(:,iCond,:))),'-','lineWidth',2,'color',colors(iCond,:));
        hold on;
    end
    xlim([-tWindow_vis tWindow_vis]);
    xticks(sort([xlim 0]));
    xlabel('time (s)');
    ylim([-0.75 0.75]);
    yticks(sort([ylim,0]));
    ylabel('firing rate z-score');
    grid on;
    title({...
        ['All Units ',num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
        [eventFieldnames{useEvents(iEvent)}]...
        });
    legend(condLabels);

    subplot(324);
    for iCond = 1:3
        plot(t,nanmean(squeeze(all_TTA(primSec(:,1)==3|primSec(:,2)==3,iCond,:))),'-','lineWidth',2,'color',colors(iCond,:));
        hold on;
    end
    xlim([-tWindow_vis tWindow_vis]);
    xticks(sort([xlim 0]));
    xlabel('time (s)');
    ylim([-0.75 0.75]);
    yticks(sort([ylim,0]));
    ylabel('firing rate z-score');
    grid on;
    title({...
        ['Tone Units ',num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
        [eventFieldnames{useEvents(iEvent)}]...
        });
    legend(condLabels);

    subplot(326);
    for iCond = 1:3
        plot(t,nanmean(squeeze(all_TTA(primSec(:,1)==4|primSec(:,2)==4,iCond,:))),'-','lineWidth',2,'color',colors(iCond,:));
        hold on;
    end
    xlim([-tWindow_vis tWindow_vis]);
    xticks(sort([xlim 0]));
    xlabel('time (s)');
    ylim([-0.75 0.75]);
    yticks(sort([ylim,0]));
    ylabel('firing rate z-score');
    grid on;
    title({...
        ['Nose Out Units ',num2str(freqList(iFreq),'%2.1f'),' Hz transients'],...
        [eventFieldnames{useEvents(iEvent)}]...
        });
    legend(condLabels);
end