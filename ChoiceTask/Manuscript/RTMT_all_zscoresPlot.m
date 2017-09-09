colors = lines(7);
plotAllClasses = false;

figuree(1200,400);
curColor = 1;
lns = [];
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    for iEvent2 = 1:numel(eventFieldnames)
        if ~plotAllClasses && iEvent ~= iEvent2
            continue;
        end
%         plot(squeeze(all_zscores(:,iEvent,:))','LineWidth',.2,'Color',myColorMap(curColor,:));
%         hold on;
        lns(iEvent2) = plot(smooth(nanmean(squeeze(all_zscores(find(unitClasses == iEvent2),iEvent,:))),3),'LineWidth',1,'Color',colors(iEvent2,:));
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