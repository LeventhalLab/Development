if false
    RTmin = 0;
    RTmax = median(all_rt) + std(all_rt);
    tWindow = 1;
    [unitEventsRTlow,all_zscoresRTlow] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,RTmin,RTmax);
    n_all_zscoresRTlow = numel(find(all_rt > RTmin & all_rt < RTmax));

    RTmin = median(all_rt) + std(all_rt);
    RTmax = 2;
    [unitEventsRThigh,all_zscoresRThigh] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,RTmin,RTmax);
    n_all_zscoresRThigh = numel(find(all_rt > RTmin & all_rt < RTmax));
end

if false
    figuree(1200,400);
    colors = lines(2);
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,7,iEvent);
        lns(1) = plot(smooth(nanmean(squeeze(all_zscoresRTlow(:,iEvent,:))),3),'LineWidth',1,'Color',colors(1,:));
        hold on;
        lns(2) = plot(smooth(nanmean(squeeze(all_zscoresRThigh(:,iEvent,:))),3),'LineWidth',1,'Color',colors(2,:));
        xlim([1 80]);
        xticks([1 40 80]);
        xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
        ylim([-2 8]);
        grid on;
        title([eventFieldnames{iEvent}]);
    end

    legend(lns,{['low RT ',num2str(n_all_zscoresRTlow)],['high RT ',num2str(n_all_zscoresRThigh)]});
end

if true
    colors = lines(2);
    y = [];
    yCount = 1;
    group = {};
    figuree(1300,400);
    for iNeuron = 1:size(all_zscoresRTlow,1)
        lowMax = max(all_zscoresRTlow(iNeuron,4,:));
        highMax = max(all_zscoresRThigh(iNeuron,4,:));
        lowStd = std(all_zscoresRTlow(iNeuron,4,:));
        highStd = std(all_zscoresRThigh(iNeuron,4,:));
        if lowMax > 40 || highMax > 40 || lowStd == 0 || highStd == 0
            continue;
        end
        for iEvent = 1:7
            subplot(2,7,iEvent);
            plot(smooth(squeeze(all_zscoresRTlow(iNeuron,iEvent,:)),3),'-','color',[colors(1,:) 0.15]);
            ylim([-15 30]);
            title({'RT Low',eventFieldnames{iEvent}});
            xticks([1 round(size(all_zscores,3))/2 size(all_zscores,3)]);
            xticklabels({'-1','0','1'});
            hold on;
            grid on;
            
            subplot(2,7,iEvent+7);
            plot(smooth(squeeze(all_zscoresRThigh(iNeuron,iEvent,:)),3),'-','color',[colors(2,:) 0.15]);
            ylim([-15 30]);
            title({'RT High',eventFieldnames{iEvent}});
            xticks([1 round(size(all_zscores,3))/2 size(all_zscores,3)]);
            xticklabels({'-1','0','1'});
            hold on;
            grid on;
            if iEvent == 1
                ylabel('z');
            end
        end
        
        y(yCount) = lowStd;
        group{yCount} = 'Low RT';
        yCount = yCount + 1;
        
        y(yCount) = highStd;
        group{yCount} = 'High RT';
        yCount = yCount + 1;
    end
    for iEvent = 1:7
        subplot(2,7,iEvent);
        plot(smooth(squeeze(mean(all_zscoresRTlow(:,iEvent,:))),3),'-','color',colors(1,:),'lineWidth',2);

        subplot(2,7,iEvent+7);
        plot(smooth(squeeze(mean(all_zscoresRThigh(:,iEvent,:))),3),'-','color',colors(2,:),'lineWidth',2);
    end
    numel(y)
    p = anova1(y,group);
end