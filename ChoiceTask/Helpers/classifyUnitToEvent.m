% timingField = 'RT';
% eventFieldnames = fieldnames(trials(2).timestamps);
% tWindow = 2;

maxNeuronZ = [];
for iNeuron = 1:size(all_eventPetz,2)
    neuronPetz = all_eventPetz{iNeuron};
    figure('position',[500 0 1300 400]);
    for iEvent = 1:size(neuronPetz,1)
        neuronEventPetz = cell2mat(neuronPetz(iEvent,:)');
        meanPetz = mean(neuronEventPetz);
        maxNeuronZ(iEvent,iNeuron) = max(meanPetz);
        subplot(1,8,iEvent);
%         plot(neuronEventPetz','color',[.5 .5 .5 .5]);
%         hold on;
        plot(diff(meanPetz),'r','linewidth',3);
%         ylim([-1 6]);
    end
end
% close all;
[~,k] = max(maxNeuronZ);
[v,k2] = sort(k);
figure('position',[0 0 1000 700]);
for ii=1:2
    subplot(1,3,ii);
    if ii==1
        imagesc(maxNeuronZ');
        title({analysisConf.subjects__name,'sorted by RT'});
        ylabel('unit');
    else
        imagesc(maxNeuronZ(:,k2)');
        title('sorted by event');
    end
    colormap(jet);
    hcb = colorbar;
    title(hcb,'Z');
    caxis([-2 2]);
    xticks(1:8);
    xticklabels(eventFieldnames);
    xtickangle(90);
end
subplot(133);
[counts,centers] = hist(k,[1:8]);
bar(centers,counts);
xticks(centers);
xticklabels([1:8]);
xlim([0 9]);
xticklabels(eventFieldnames);
xtickangle(90);
title('event distribution');
grid on;