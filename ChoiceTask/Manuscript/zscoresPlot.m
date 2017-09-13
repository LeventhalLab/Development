colors = lines(7);
plotAllClasses = false;

unitClass_thresh = unitClassByThresh(unitEvents,2);

if false
    figuree(1200,400);
    lns = [];
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,7,iEvent);
        for iEvent2 = 1:numel(eventFieldnames)
            if ~plotAllClasses && iEvent ~= iEvent2
                continue;
            end
    %         plot(squeeze(all_zscores(:,iEvent,:))','LineWidth',.2,'Color',[colors(curColor,:) .05]);
    %         hold on;
            lns(iEvent2) = plot(mean(squeeze(all_zscores(unitClass_thresh == iEvent2,iEvent,:))),'LineWidth',1,'Color',colors(iEvent2,:));
            hold on;
            text(5,.2,num2str(numel(find(unitClasses == iEvent2))));
            xlim([1 size(all_zscores,3)]);
            xticks([1 round(size(all_zscores,3))/2 size(all_zscores,3)]);
            xticklabels({'-1','0','1'});
            ylim([-0.5 2]);
            grid on;
            title([eventFieldnames{iEvent}]);
            hold on;
        end
    end
    legend(lns,eventFieldnames);
end

if true
    figuree(1200,400);
    useEvent = 4;
    lns = [];
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,7,iEvent);
        lineWidth = 1;
        titleColor = 'k';
        if iEvent == useEvent
            lineWidth = 3;
            titleColor = colors(useEvent,:);
        end
        lns(1) = plot(mean(squeeze(all_zscores(unitClass_thresh == useEvent,iEvent,:))),'LineWidth',lineWidth,'Color',colors(useEvent,:));
        if iEvent == useEvent
            set(gca,'color',[colors(useEvent,:) 0.1]);
        end
        xlim([1 size(all_zscores,3)]);
        xticks([1 round(size(all_zscores,3))/2 size(all_zscores,3)]);
        xticklabels({'-1','0','1'});
        ylim([-0.5 2]);
        grid on;
        title([eventFieldnames{iEvent}],'color',titleColor);
        if iEvent == 1
            ylabel('Z score');
            xlabel('time (s)');
        end
        set(gca,'fontSize',16);
    end
    set(gcf,'color','white');
end