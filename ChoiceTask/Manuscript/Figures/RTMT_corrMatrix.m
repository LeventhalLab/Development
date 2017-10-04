figuree(1400,800);
rows = 4;
cols = 3;
z_yLims = [-.5 2];

for iRow = 1:rows
    switch iRow
        case 1
            byRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_unTone_n49_movDirall_byRT_bins10_binMs2020171404.mat');
            byMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_unTone_n49_movDirall_byMT_bins10_binMs2020171404.mat');
            unitType = 'Tone';
        case 2
            byRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_unNose Out_n76_movDirall_byRT_bins10_binMs2020171404.mat');
            byMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_unNose Out_n76_movDirall_byMT_bins10_binMs2020171504.mat');
            unitType = 'Nose Out';
        case 3
            byRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n60_movDirall_byRT_bins10_binMs2020171504.mat');
            byMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n60_movDirall_byMT_bins10_binMs2020171604.mat');
            unitType = 'dirSel';
        case 4
            byRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n56_movDirall_byRT_bins10_binMs2020171604.mat');
            byMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n56_movDirall_byMT_bins10_binMs2020171604.mat');
            unitType = '~dirSel';
    end
    
    iCol = 1;
    subplot(rows,cols,((iRow*cols)-cols) + iCol);
    rt_meanColors = cool(numel(byRT.meanBinsSeconds)-1);
    lns = plot(byRT.mean_z','lineWidth',lineWidth);
    set(lns,{'color'},num2cell(rt_meanColors,2));
    title([unitType,' units, RT at nose out']);
    xlabel('time (s)');
    ylabel('Z score');
    ylim(z_yLims);
    xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
    xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
    grid on;
    
    iCol = 2;
    subplot(rows,cols,((iRow*cols)-cols) + iCol);
    mt_meanColors = summer(numel(byRT.meanBinsSeconds)-1);
    lns = plot(byMT.mean_z','lineWidth',lineWidth);
    set(lns,{'color'},num2cell(mt_meanColors,2));
    title([unitType,' units, MT at nose out']);
    xlabel('time (s)');
    ylabel('Z score');
    ylim(z_yLims);
    xticks([1 floor(size(allTrial_z,2)/2) size(allTrial_z,2)]);
    xticklabels({num2str(-tWindow),'0',num2str(tWindow)});
    grid on;
    
    iCol = 3;
    subplot(rows,cols,((iRow*cols)-cols) + iCol);
%     scatter(byRT.meanBinsSeconds(2:end),byRT.auc_max_z,markerSize,rt_meanColors,'filled');
%     hold on;
    f = fit(byRT.meanBinsSeconds(2:end)',byRT.auc_max_z','exp1');
    plot(f,byRT.meanBinsSeconds(2:end)',byRT.auc_max_z');
    hold on;
    
%     scatter(byMT.meanBinsSeconds(2:end),byMT.auc_max_z,markerSize,mt_meanColors,'filled');
    f = fit(byMT.meanBinsSeconds(2:end)',byMT.auc_max_z','exp1');
    plot(f,byMT.meanBinsSeconds(2:end)',byMT.auc_max_z');
    
    xlabel('RT/MT','interpreter','none');
    ylabel('maz Z','interpreter','none');
%     [RHO,PVAL] = corr(meanBinsSeconds(2:end)',auc_max');
%     title({[timingField,' vs. auc_max'],['RHO = ',num2str(RHO,2),', PVAL = ',num2str(PVAL,2)]},'interpreter','none');
    xlim([0 1]);
    grid on;
    
end

set(gcf,'color','w');

% inset
figuree(300,200);
plot(auc_min_z,auc_max_z,'k.','markerSize',20);
xlimVals = [-.5 .5];
xlim(xlimVals);
xticks(xlimVals)
ylimVals = [0.5 2];
ylim(ylimVals);
yticks(ylimVals);
set(gca,'fontsize',16);
ylabel('MAX Z');
xlabel('MIN Z');
[f,gof,output] = fit(auc_min_z',auc_max_z','poly1');
f = polyfit(auc_min_z',auc_max_z',1);
y = polyval(f,xlimVals);
hold on;
fitLine = plot(xlimVals,y,'r');
legend(fitLine,{['r^2 = ',num2str(gof.rsquare,2)]});
legend boxoff;
set(gcf,'color','w');


