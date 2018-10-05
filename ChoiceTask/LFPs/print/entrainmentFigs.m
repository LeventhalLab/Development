savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/entrainmentFigure';
doSave = true;
useSurr = false;

colors = [0 0 0;120 120 120;...
        0 198 23;158 204 163;...
        187 0 0;209 158 158]./255;
tickLabels = {'All IN','All OUT','dirSel IN','dirSel OUT','ndirSel IN','ndirSel OUT'};
rows = 2;
cols = 7;
pThresh = 0.001;
rlimVals = [0 0.10];

if useSurr
    surrLabel = 'SURR';
    use_all_spikeHist_pvals = squeeze(mean(all_spikeHist_pvals_surr));
    use_all_spikeHist_rs = squeeze(mean(all_spikeHist_rs_surr));
    use_all_spikeHist_mus = squeeze(mean(all_spikeHist_mus_surr));
    use_all_spikeHist_angles = squeeze(circ_mean(all_spikeHist_angles_surr));
    use_all_spikeHist_alphas = all_spikeHist_alphas; % not critical right now
% %     use_all_spikeHist_alphas = squeeze(mean(all_spikeHist_alphas_surr));
else
    surrLabel = 'NOTSURR';
    use_all_spikeHist_pvals = all_spikeHist_pvals;
    use_all_spikeHist_rs = all_spikeHist_rs;
    use_all_spikeHist_mus = all_spikeHist_mus;
    use_all_spikeHist_angles = all_spikeHist_angles;
    use_all_spikeHist_alphas = all_spikeHist_alphas;
end


for iFreq = 1%:numel(freqList)
    dir_rs_in = [];
    ndir_rs_in = [];
    all_rs_in = [];
    dir_rs_out = [];
    ndir_rs_out = [];
    all_rs_out = [];
    
    dir_pvalThresh_in = [];
    ndir_pvalThresh_in = [];
    all_pvalThresh_in = [];
    dir_pvalThresh_out = [];
    ndir_pvalThresh_out = [];
    all_pvalThresh_out = [];
    for iNeuron = 1:numel(all_ts)
        these_alphas_out = use_all_spikeHist_alphas{iNeuron,iFreq};
        these_alphas_in = all_spikeHist_inTrial_alphas{iNeuron,iFreq};
        if isempty(these_alphas_out) || isempty(these_alphas_in)
            continue;
        end
        if ismember(iNeuron,dirSelUnitIds)
            dir_rs_in = [dir_rs_in;all_spikeHist_inTrial_rs(iNeuron,iFreq)];
            dir_rs_out = [dir_rs_out;use_all_spikeHist_rs(iNeuron,iFreq)];
            dir_pvalThresh_in = [dir_pvalThresh_in;all_spikeHist_inTrial_pvals(iNeuron,iFreq)];
            dir_pvalThresh_out = [dir_pvalThresh_out;use_all_spikeHist_pvals(iNeuron,iFreq)];
        elseif ismember(iNeuron,ndirSelUnitIds)
            ndir_rs_in = [ndir_rs_in;all_spikeHist_inTrial_rs(iNeuron,iFreq)];
            ndir_rs_out = [ndir_rs_out;use_all_spikeHist_rs(iNeuron,iFreq)];
            ndir_pvalThresh_in = [ndir_pvalThresh_in;all_spikeHist_inTrial_pvals(iNeuron,iFreq)];
            ndir_pvalThresh_out = [ndir_pvalThresh_out;use_all_spikeHist_pvals(iNeuron,iFreq)];
        end
        all_rs_in = [all_rs_in;all_spikeHist_inTrial_rs(iNeuron,iFreq)];
        all_rs_out = [all_rs_out;use_all_spikeHist_rs(iNeuron,iFreq)];
        all_pvalThresh_in = [all_pvalThresh_in;all_spikeHist_inTrial_pvals(iNeuron,iFreq)];
        all_pvalThresh_out = [all_pvalThresh_out;use_all_spikeHist_pvals(iNeuron,iFreq)];
    end
    
    h = ff(1200,400);
    
    all_pvalThresh_in_res = sum(all_pvalThresh_in < pThresh) / sum(~isnan(all_pvalThresh_in));
    all_pvalThresh_out_res = sum(all_pvalThresh_out < pThresh) / sum(~isnan(all_pvalThresh_out));
    dir_pvalThresh_in_res = sum(dir_pvalThresh_in < pThresh) / sum(~isnan(dir_pvalThresh_in));
    dir_pvalThresh_out_res = sum(dir_pvalThresh_out < pThresh) / sum(~isnan(dir_pvalThresh_out));
    ndir_pvalThresh_in_res = sum(ndir_pvalThresh_in < pThresh) / sum(~isnan(ndir_pvalThresh_in));
    ndir_pvalThresh_out_res = sum(ndir_pvalThresh_out < pThresh) / sum(~isnan(ndir_pvalThresh_out));
    
    subplot(rows,cols,[1 2 8 9]);
    hb = bar([all_pvalThresh_in_res all_pvalThresh_out_res,...
        dir_pvalThresh_in_res dir_pvalThresh_out_res,...
        ndir_pvalThresh_in_res ndir_pvalThresh_out_res],'EdgeColor','none');
    ylim([0 0.6]);
    yticks(ylim);
    ylabel(['fraction p < ',num2str(pThresh,'%1.3f')]);
    xticklabels(tickLabels);
    xtickangle(30);
    hb.FaceColor = 'flat';
    hb.CData = colors;
    title('Fraction of Entrained Units');
    
    x = [all_rs_in;all_rs_out;dir_rs_in;dir_rs_out;ndir_rs_in;ndir_rs_out];
    x_c = {all_rs_in;all_rs_out;dir_rs_in;dir_rs_out;ndir_rs_in;ndir_rs_out};
    g = [1*ones([numel(all_rs_in) 1]);2*ones([numel(all_rs_in) 1]);3*ones([numel(dir_rs_in) 1]);4*ones([numel(dir_rs_in) 1]);...
        5*ones([numel(ndir_rs_in) 1]);6*ones([numel(ndir_rs_in) 1])];
    
    subplot(rows,cols,[3 4 10 11]);
    hb = boxplot(x,g,'color','k','Symbol','','BoxStyle','filled','MedianStyle','target');
    ylim(rlimVals);
    yticks(ylim);
    ylabel('MRL');
    xticklabels(tickLabels);
    xtickangle(30);
    
    a = get(get(gca,'children'),'children');
    t = get(a,'tag');
    
    box_idx = flip(find(strcmpi(t,'box')==1));
    whisker_idx = flip(find(strcmpi(t,'whisker')==1));
    set(a(box_idx),'linewidth',15);
    for ii = 1:6
        set(a(box_idx(ii)),'Color',colors(ii,:));
        set(a(whisker_idx(ii)),'Color',repmat(0.7,[1,3]));
    end
    
    sigGroups = {};
    sigStats = [];
    iiArr = [1,3,5,1,1,3,2,2,4];
    jjArr = [2,4,6,3,5,5,4,6,6];
    for ii = 1:numel(iiArr)
        pval = anova1([x_c{iiArr(ii)};x_c{jjArr(ii)}],[1*ones([numel(x_c{iiArr(ii)}) 1]);2*ones([numel(x_c{jjArr(ii)}) 1])],'off');
        if pval < 0.001
            sigGroups{numel(sigGroups)+1} = [iiArr(ii),jjArr(ii)];
            sigStats(numel(sigGroups)) = pval;
        end
    end
    H = sigstar(sigGroups,sigStats,0);
    text(3.5,0.14,{'***only showing p < 0.001 bars','1-WAY ANOVA','IN x OUT','ALL x DIR x NDIR'},'HorizontalAlignment','center');
    title('MRL Distribution (rtest p <= 1)');
    
    all_angles_out = use_all_spikeHist_angles(:,:,iFreq);
    all_angles_in = all_spikeHist_inTrial_angles(:,:,iFreq);
    all_angles_mean_out = mean(nanmean(all_angles_out));
    all_angles_std_out = std(nanmean(all_angles_out));
    all_angles_mean_in = mean(nanmean(all_angles_in));
    all_angles_std_in = std(nanmean(all_angles_in));
    
    dir_angles_out = use_all_spikeHist_angles(dirSelUnitIds,:,iFreq);
    dir_angles_in = all_spikeHist_inTrial_angles(dirSelUnitIds,:,iFreq);
    dir_angles_mean_out = mean(nanmean(dir_angles_out));
    dir_angles_std_out = std(nanmean(dir_angles_out));
    dir_angles_mean_in = mean(nanmean(dir_angles_in));
    dir_angles_std_in = std(nanmean(dir_angles_in));
    
    ndir_angles_out = use_all_spikeHist_angles(ndirSelUnitIds,:,iFreq);
    ndir_angles_in = all_spikeHist_inTrial_angles(ndirSelUnitIds,:,iFreq);
    ndir_angles_mean_out = mean(nanmean(ndir_angles_out));
    ndir_angles_std_out = std(nanmean(ndir_angles_out));
    ndir_angles_mean_in = mean(nanmean(ndir_angles_in));
    ndir_angles_std_in = std(nanmean(ndir_angles_in));
    
    lineWidth = 3;
    
    subplot(rows,cols,[5 6 7]);
    lns = [];
    all_angles_in_Z = (nanmean(all_angles_in) - all_angles_mean_in) ./ all_angles_std_in;
    lns(1) = plot([all_angles_in_Z all_angles_in_Z],'color',colors(1,:),'lineWidth',lineWidth);
    hold on;
    dir_angles_in_Z = (nanmean(dir_angles_in) - dir_angles_mean_in) ./ dir_angles_std_in;
    lns(2) = plot([dir_angles_in_Z dir_angles_in_Z],'color',colors(3,:),'lineWidth',lineWidth);
    ndir_angles_in_Z = (nanmean(ndir_angles_in) - ndir_angles_mean_in) ./ ndir_angles_std_in;
    lns(3) = plot([ndir_angles_in_Z ndir_angles_in_Z],'color',colors(5,:),'lineWidth',lineWidth);
    xticks([1,6.5,12.5,18.5,24]);
    xticklabels([0 180 360 540 720]);
    xtickangle(270);
%     xlabel('Spike phase (deg)');
    ylim([-2 2]);
    yticks(sort([ylim,0]));
    ylabel('Z-score');
    grid on;
    title({'Mean Entrainment Phase','IN Trial'});
    
    subplot(rows,cols,[12 13 14]);
    lns = [];
    all_angles_out_Z = (nanmean(all_angles_out) - all_angles_mean_out) ./ all_angles_std_out;
    lns(1) = plot([all_angles_out_Z all_angles_out_Z],'color',colors(2,:),'lineWidth',lineWidth);
    hold on;
    dir_angles_out_Z = (nanmean(dir_angles_out) - dir_angles_mean_out) ./ dir_angles_std_out;
    lns(2) = plot([dir_angles_out_Z dir_angles_out_Z],'color',colors(4,:),'lineWidth',lineWidth);
    ndir_angles_out_Z = (nanmean(ndir_angles_out) - ndir_angles_mean_out) ./ ndir_angles_std_out;
    lns(3) = plot([ndir_angles_out_Z ndir_angles_out_Z],'color',colors(6,:),'lineWidth',lineWidth);
    xticks([1,6.5,12.5,18.5,24]);
    xticklabels([0 180 360 540 720]);
    xtickangle(270);
    xlabel('Spike phase (deg)');
    ylim([-2 2]);
    yticks(sort([ylim,0]));
    ylabel('Z-score');
    grid on;
    title('OUT Trial');
    
    set(gcf,'color','w');
end
drawnow;

if doSave
    saveas(h,fullfile(savePath,['mainFigure_iFreq',num2str(iFreq,'%02d'),'_',surrLabel,'.png']));
    close(h);
end

h = ff(400,300);
for iNeuron = 1:numel(all_ts)
    subplot(2,3,1);
    polarplot([all_spikeHist_inTrial_mus(iNeuron,iFreq) all_spikeHist_inTrial_mus(iNeuron,iFreq)],...
        [0 all_spikeHist_inTrial_rs(iNeuron,iFreq)],'color',colors(1,:));
    hold on;
    subplot(2,3,4);
    polarplot([use_all_spikeHist_mus(iNeuron,iFreq) use_all_spikeHist_mus(iNeuron,iFreq)],...
        [0 use_all_spikeHist_rs(iNeuron,iFreq)],'color',colors(2,:));
    hold on;
    if ismember(iNeuron,dirSelUnitIds)
        subplot(2,3,2);
        polarplot([all_spikeHist_inTrial_mus(iNeuron,iFreq) all_spikeHist_inTrial_mus(iNeuron,iFreq)],...
            [0 all_spikeHist_inTrial_rs(iNeuron,iFreq)],'color',colors(3,:));
        hold on;
        subplot(2,3,5);
        polarplot([use_all_spikeHist_mus(iNeuron,iFreq) use_all_spikeHist_mus(iNeuron,iFreq)],...
            [0 use_all_spikeHist_rs(iNeuron,iFreq)],'color',colors(4,:));
        hold on;
    end
    
    if ismember(iNeuron,ndirSelUnitIds)
        subplot(2,3,3);
        polarplot([all_spikeHist_inTrial_mus(iNeuron,iFreq) all_spikeHist_inTrial_mus(iNeuron,iFreq)],...
            [0 all_spikeHist_inTrial_rs(iNeuron,iFreq)],'color',colors(5,:));
        hold on;
        subplot(2,3,6);
        polarplot([use_all_spikeHist_mus(iNeuron,iFreq) use_all_spikeHist_mus(iNeuron,iFreq)],...
            [0 use_all_spikeHist_rs(iNeuron,iFreq)],'color',colors(6,:));
        hold on;
    end
end

for ii = 1:6
    subplot(2,3,ii);
    ax = gca;
    ax.ThetaDir = 'counterclockwise';
    ax.ThetaZeroLocation = 'top';
    ax.ThetaTick = [0 90 180 270];
    rlim(rlimVals);
    rticks(rlimVals);
end
set(gcf,'color','w');
if doSave
    saveas(h,fullfile(savePath,['vectorsSubplot_iFreq',num2str(iFreq,'%02d'),'_',surrLabel,'.png']));
    close(h);
end