tidx_correct = find([trials.correct] == 1);
tidx_incorrect = find([trials.correct] == 0);
tidx_contra_correct = find([trials.movementDirection] == 1 & [trials.correct] == 1);
tidx_ipsi_correct = find([trials.movementDirection] == 2 & [trials.correct] == 1);
tidx_contra_incorrect = find([trials.movementDirection] == 1 & [trials.correct] == 0);
tidx_ipsi_incorrect = find([trials.movementDirection] == 2 & [trials.correct] == 0);

all_tidx_contra_correct = [];
all_tidx_ipsi_correct = [];
all_tidx_contra_incorrect = [];
all_tidx_ipsi_incorrect = [];

all_RT = [];
all_MT = [];
for iTrial = tidx_correct
    all_RT = [all_RT trials(iTrial).timing.RT];
    all_MT = [all_MT trials(iTrial).timing.MT];
end
tidx_lowRT = find(all_RT < (median(all_RT) - std(all_RT)));
tidx_lowRT_contra = tidx_lowRT(ismember(tidx_lowRT,tidx_contra_correct));
tidx_lowRT_ipsi = tidx_lowRT(ismember(tidx_lowRT,tidx_ipsi_correct));
tidx_highRT = find(all_RT > (median(all_RT) + std(all_RT)));
tidx_highRT_contra = tidx_highRT(ismember(tidx_highRT,tidx_contra_correct));
tidx_highRT_ipsi = tidx_highRT(ismember(tidx_highRT,tidx_ipsi_correct));

tidx_lowMT = find(all_MT < (median(all_MT) - std(all_MT)));
tidx_lowMT_contra = tidx_lowMT(ismember(tidx_lowMT,tidx_contra_correct));
tidx_lowMT_ipsi = tidx_lowMT(ismember(tidx_lowMT,tidx_ipsi_correct));
tidx_highMT = find(all_MT > (median(all_MT) + std(all_MT)));
tidx_highMT_contra = tidx_highMT(ismember(tidx_highMT,tidx_contra_correct));
tidx_highMT_ipsi = tidx_highMT(ismember(tidx_highMT,tidx_ipsi_correct));

nSmooth = 6;
x = linspace(-tWindow,tWindow,size(zCounts,3));
for iEvent = plotEventIds
    zCounts_co = squeeze(zCounts(iEvent,:,:));
    
    h = figure('position',[0 0 1600 800]);

    subplot(131);
    hold on;
    grid on;
    % plot(x,smooth(mean(zCounts_co(:,:)),nSmooth),'k','linewidth',2);
    tmp = mean(zCounts_co(tidx_contra_correct,:));
    all_tidx_contra_correct(iNeuron,iEvent,:,:) = tmp;
    plot(x,smooth(tmp,nSmooth),'linewidth',2);
    
    tmp = mean(zCounts_co(tidx_ipsi_correct,:));
    all_tidx_ipsi_correct(iNeuron,iEvent,:,:) = tmp;
    plot(x,smooth(tmp,nSmooth),'linewidth',2);
    
    tmp = mean(zCounts_co(tidx_contra_incorrect,:));
    all_tidx_contra_incorrect(iNeuron,iEvent,:,:) = tmp;
    plot(x,smooth(tmp,nSmooth),'linewidth',2);
    
    tmp = mean(zCounts_co(tidx_ipsi_incorrect,:));
    all_tidx_ipsi_incorrect(iNeuron,iEvent,:,:) = tmp;
    plot(x,smooth(tmp,nSmooth),'linewidth',2);

    ylimVals = [-1 2];
    plot([0 0],ylimVals,'r');
    ylim(ylimVals);
    legend(['contra correct (',num2str(numel(tidx_contra_correct)),')'],...
        ['ipsi correct (',num2str(numel(tidx_ipsi_correct)),')'],...
        ['contra incorrect (',num2str(numel(tidx_contra_incorrect)),')'],...
        ['ipsi incorrect (',num2str(numel(tidx_ipsi_incorrect)),')'],...
        'location','northoutside');
    title(eventFieldnames(iEvent));

    subplot(132);
    hold on;
    grid on;
    plot(x,smooth(mean(zCounts_co(tidx_lowRT,:)),nSmooth),'linewidth',2);
    plot(x,smooth(mean(zCounts_co(tidx_lowRT_contra,:)),nSmooth),'linewidth',1);
    plot(x,smooth(mean(zCounts_co(tidx_lowRT_ipsi,:)),nSmooth),'linewidth',1);
    plot(x,smooth(mean(zCounts_co(tidx_highRT,:)),nSmooth),'linewidth',2);
    plot(x,smooth(mean(zCounts_co(tidx_highRT_contra,:)),nSmooth),'linewidth',1);
    plot(x,smooth(mean(zCounts_co(tidx_highRT_ipsi,:)),nSmooth),'linewidth',1);
    ylimVals = [-1 2];
    plot([0 0],ylimVals,'r');
    ylim(ylimVals);
    legend(['Low RT (',num2str(numel(tidx_lowRT)),')'],...
        ['Low RT contra (',num2str(numel(tidx_lowRT_contra)),')'],...
        ['Low RT ipsi (',num2str(numel(tidx_lowRT_ipsi)),')'],...
        ['High RT (',num2str(numel(tidx_highRT)),')'],...
        ['High RT contra (',num2str(numel(tidx_highRT_contra)),')'],...
        ['High RT ipsi (',num2str(numel(tidx_highRT_ipsi)),')'],...
        'location','northoutside');
    title(eventFieldnames(iEvent));

    subplot(133);
    hold on;
    grid on;
    plot(x,smooth(mean(zCounts_co(tidx_lowMT,:)),nSmooth),'linewidth',2);
    plot(x,smooth(mean(zCounts_co(tidx_lowMT_contra,:)),nSmooth),'linewidth',1);
    plot(x,smooth(mean(zCounts_co(tidx_lowMT_ipsi,:)),nSmooth),'linewidth',1);
    plot(x,smooth(mean(zCounts_co(tidx_highMT,:)),nSmooth),'linewidth',2);
    plot(x,smooth(mean(zCounts_co(tidx_highMT_contra,:)),nSmooth),'linewidth',1);
    plot(x,smooth(mean(zCounts_co(tidx_highMT_ipsi,:)),nSmooth),'linewidth',1);
    ylimVals = [-1 2];
    plot([0 0],ylimVals,'r');
    ylim(ylimVals);
    legend(['Low MT (',num2str(numel(tidx_lowMT)),')'],...
        ['Low MT contra (',num2str(numel(tidx_lowMT_contra)),')'],...
        ['Low MT ipsi (',num2str(numel(tidx_lowMT_ipsi)),')'],...
        ['High MT (',num2str(numel(tidx_highMT)),')'],...
        ['High MT contra (',num2str(numel(tidx_highMT_contra)),')'],...
        ['High MT ipsi (',num2str(numel(tidx_highMT_ipsi)),')'],...
        'location','northoutside');
    title(eventFieldnames(iEvent));
    
    savePath = 'C:\Users\Administrator\Documents\MATLAB\Development\ChoiceTask\temp';
    saveas(h,fullfile(savePath,['ipsiContraLines_',neuronName,'_event',num2str(iEvent),'.jpg']));
    close(h);
end