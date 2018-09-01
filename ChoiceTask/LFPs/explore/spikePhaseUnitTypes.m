% /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/print/Leventhal2012_Fig6_spikePhaseHist.m
% load('session_20180516_FinishedResubmission.mat', 'ndirSelUnitIds')
% load('session_20180516_FinishedResubmission.mat', 'primSec')
% load('session_20180516_FinishedResubmission.mat', 'dirSelUnitIds')

% all_spikeHist_pvals = NaN(numel(all_ts),1);
% all_spikeHist_angles = NaN(numel(all_ts),nBins);
% all_spikeHist_inTrial_pvals = NaN(numel(all_ts),1);
% all_spikeHist_inTrial_angles = NaN(numel(all_ts),nBins);
% all_spikeHist_outTrial_pvals = NaN(numel(all_ts),1);
% all_spikeHist_outTrial_angles = NaN(numel(all_ts),nBins);
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseUnitTypes';
rows = 3;
cols = 4;
dirLabels = {'dir','~dir'};
rowLabels = {'ALL','IN TRIAL','OUT TRIAL'};
ylim_pval = [0 1];
ylim_frac = [0 1];
primSec_pnNaN = primSec;
primSec_pnNaN(isnan(primSec_pnNaN(:,1)),1) = 8;
eventFieldnames_nan = {eventFieldnames{:} 'NaN'};

h = figuree(900,900);
% dirSel
for iRow = 1:3 
    switch iRow
        case 1
            dirVals = all_spikeHist_pvals(dirSelUnitIds);
            ndirVals = all_spikeHist_pvals(ndirSelUnitIds);
        case 2
            dirVals = all_spikeHist_inTrial_pvals(dirSelUnitIds);
            ndirVals = all_spikeHist_inTrial_pvals(ndirSelUnitIds);
        case 3
            dirVals = all_spikeHist_outTrial_pvals(dirSelUnitIds);
            ndirVals = all_spikeHist_outTrial_pvals(ndirSelUnitIds);
    end
    
    subplot(rows,cols,prc(cols,[iRow,1]));
    dirVals = dirVals(~isnan(dirVals));
    ndirVals = ndirVals(~isnan(ndirVals));
    x = [dirVals;ndirVals];
    g = [zeros(numel(dirVals),1);ones(numel(ndirVals),1)];
    pval = anova1(x,g,'off');
    boxplot(x,g,'PlotStyle','compact');
    xticks(1:2);
    xticklabels(dirLabels);
    ylim(ylim_pval);
    yticks(ylim);
    ylabel('mean pval');
    title({rowLabels{iRow},['p_a_n_o_v_a = ',num2str(pval,2)]});
    
    subplot(rows,cols,prc(cols,[iRow,2]));
    x = [dirVals(dirVals < 0.05);ndirVals(ndirVals < 0.05)];
    g = [zeros(sum(dirVals < 0.05),1);ones(sum(ndirVals < 0.05),1)];
    pval = anova1(x,g,'off');
    bar([sum(dirVals < 0.05) / numel(dirVals);sum(ndirVals < 0.05) / numel(ndirVals)],'k');
    xticks(1:2);
    xticklabels(dirLabels);
    ylim(ylim_frac);
    yticks(ylim);
    ylabel('fraction p < 0.05');
    title({rowLabels{iRow},['p_a_n_o_v_a = ',num2str(pval,2)]});
end

% events
for iRow = 1:3
    eventVals = {};
    switch iRow
        case 1
            for iEvent = 1:8
                eventVals{iEvent} = all_spikeHist_pvals(primSec_pnNaN(:,1) == iEvent);
                eventVals{iEvent} = eventVals{iEvent}(~isnan(eventVals{iEvent}));
            end
        case 2
            for iEvent = 1:8
                eventVals{iEvent} = all_spikeHist_inTrial_pvals(primSec_pnNaN(:,1) == iEvent);
                eventVals{iEvent} = eventVals{iEvent}(~isnan(eventVals{iEvent}));
            end
        case 3
            for iEvent = 1:8
                eventVals{iEvent} = all_spikeHist_outTrial_pvals(primSec_pnNaN(:,1) == iEvent);
                eventVals{iEvent} = eventVals{iEvent}(~isnan(eventVals{iEvent}));
            end
    end
    
    subplot(rows,cols,prc(cols,[iRow,3]));
    x = [];
    g = [];
    for iEvent = 1:8
        x = [x;eventVals{iEvent}];
        g = [g;ones(numel(eventVals{iEvent}),1)*iEvent];
    end
    pval = anova1(x,g,'off');
    boxplot(x,g,'PlotStyle','compact');
    xticks(1:8);
    xticklabels(eventFieldnames_nan);
    xtickangle(270);
    ylim(ylim_pval);
    yticks(ylim);
    ylabel('mean pval');
    title({rowLabels{iRow},['p_a_n_o_v_a = ',num2str(pval,2)]});
    
    subplot(rows,cols,prc(cols,[iRow,4]));
    x = [];
    g = [];
    barVals = [];
    for iEvent = 1:8
        theseVals = eventVals{iEvent};
        x = [x;theseVals(theseVals < 0.05)];
        g = [g;ones(sum(theseVals < 0.05),1)*iEvent];
        barVals(iEvent) = sum(theseVals < 0.05) / numel(theseVals);
    end
    pval = anova1(x,g,'off');
    bar(barVals,'k');
    xticks(1:8);
    xticklabels(eventFieldnames_nan);
    xtickangle(270);
    ylim(ylim_frac);
    yticks(ylim);
    ylabel('fraction p < 0.05');
    title({rowLabels{iRow},['p_a_n_o_v_a = ',num2str(pval,2)]});
end
set(gcf,'color','w');
if doSave
    saveFile = 'spikePhaseUnitTypes_dirSel_eventClass.png';
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end