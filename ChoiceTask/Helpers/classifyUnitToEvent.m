timingField = 'RT';
subjects__name = 'R0088';
% eventFieldnames = fieldnames(trials(2).timestamps);
tWindow = 2;
[sorted_petz,sorted_times] = sortEventPetz(all_eventPetz,allTrials,timingField,[]);
all_r = [];
for iEvent = 1:size(sorted_petz,2)
    iEventPetz = sorted_petz{1,iEvent};
    for iTrial = 1:size(iEventPetz,1)
        trialPetz = iEventPetz(iTrial,:);
        x = linspace(-tWindow,tWindow,size(trialPetz,2));
        norm = normpdf(x,0,.25);
        r = xcorr(norm,trialPetz);
        all_r(iEvent,iTrial) = mean(r);
    end
end

[~,k] = max(all_r);
% figure;
% hist(k,size(all_r,1));

[v,k2] = sort(k);
figure('position',[0 0 1000 700]);
for ii=1:2
    subplot(1,3,ii);
    if ii==1
        imagesc(all_r');
        title({subjects__name,'sorted by RT'});
        ylabel('trials');
    else
        imagesc(all_r(:,k2)');
        title('sorted by event');
    end
    colormap(jet);
    colorbar;
    caxis([-600 600]);
    xticks(1:8);
    xticklabels(eventFieldnames);
    xtickangle(90);
end
subplot(133);
[counts,centers] = hist(k,8);
bar(centers,counts);
xticks(centers);
xticklabels([1:8]);
xlim([1 8]);
xticklabels(eventFieldnames);
xtickangle(90);
title('event distribution');
grid on;