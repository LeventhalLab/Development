figure('position',[100 100 900 400]);
colorOrder = get(gca, 'ColorOrder');

hist_eventIds = {R0088_eventIds,R0117_eventIds,R0142_eventIds};
hist_titles = {'R0088','R0117','R0142'};
all_eventIds = [];
all_counts = [];
for iHist = 1:numel(hist_eventIds)+1
    subplot(1,numel(hist_eventIds)+1,iHist);
    if iHist ~= numel(hist_eventIds)+1
        cur_eventIds = hist_eventIds{iHist};
        all_eventIds = [all_eventIds;cur_eventIds];
        barColor = colorOrder(iHist,:);
        barTitle = hist_titles{iHist};
        
        [counts,centers] = hist(cur_eventIds,8);
        all_counts = [all_counts;normalize(counts)];
    else
        counts = mean(all_counts);
        barColor = [0 0 0];
        barTitle = 'Eq. Weight All';
    end
    
    bar(centers,counts,'edgeColor','none','faceColor',barColor);
    xticks(centers);
    xticklabels([1:8]);
    xlim([centers(1)-1 centers(end)+1]);
    ylim([0 max(counts) + max(counts) * .1]);
    title(barTitle);
end