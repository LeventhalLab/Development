% % timingField = 'RT';
% % [sorted_petz,sorted_times] = sortEventPetz(all_eventPetz,allTrials,timingField,[]);
% % all_r = [];
% % for iEvent = 1:size(sorted_petz,2)
% %     eventPetz = sorted_petz{1,iEvent};
% %     for iTrial = 1:size(eventPetz,1)
% %         trialPetz = eventPetz(iTrial,:);
% %         x = linspace(-tWindow,tWindow,size(trialPetz,2));
% %         norm = normpdf(x,0,.25);
% %         r = xcorr(norm,trialPetz);
% %         all_r(iEvent,iTrial) = mean(r);
% %     end
% % end
% % 
[~,k] = max(all_r);
% figure;
% hist(k,size(all_r,1));

[v,k2] = sort(k);
figure('position',[0 0 1000 700]);
for ii=1:2
    subplot(1,3,ii);
    if ii==1
        imagesc(all_r');
        title('sorted by RT');
        ylabel('trials');
    else
        imagesc(all_r(:,k2)');
        title('sorted by event');
    end
    colormap(jet);
    colorbar;
    caxis([-600 600]);
    xticks(1:8);
    xlabel('event');
end
subplot(133);
[counts,centers] = hist(k,8);
bar(centers,counts);
xticks(centers);
xticklabels([1:8]);
xlim([1 8]);
xlabel('event');
title('event distribution');
grid on;