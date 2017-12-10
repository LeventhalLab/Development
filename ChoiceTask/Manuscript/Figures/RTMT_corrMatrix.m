function RTMT_corrMatrix()
    if ismac
        savePath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp';
        uSessionsPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions';
    else
        savePath = 'C:\Users\Administrator\Documents\MATLAB\Development\ChoiceTask\temp';
        uSessionsPath = 'C:\Users\Administrator\Documents\MATLAB\Development\ChoiceTask\temp\uSessions';
    end
    doSave = true;
    saveImage = true;
    imageExt = '.png';
    
    % Nose Out event, secondary
% %     ndirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n45_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     ndirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n45_movDirall_byMT_bins10_binMs20ORD20171031.mat');
% %     dirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n38_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     dirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n38_movDirall_byMT_bins10_binMs20ORD20171031.mat');
    
    % tone event, primary + secondary
% %     ndirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_un~dirSel_n93_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     ndirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_un~dirSel_n93_movDirall_byMT_bins10_binMs20ORD20171031.mat');
% %     dirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_undirSel_n72_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     dirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_undirSel_n72_movDirall_byMT_bins10_binMs20ORD20171031.mat');
    
    % tone event, primary only
% %     ndirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_un~dirSel_n48_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     ndirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_un~dirSel_n48_movDirall_byMT_bins10_binMs20ORD20171031.mat');
% %     dirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_undirSel_n34_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     dirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evTone_undirSel_n34_movDirall_byMT_bins10_binMs20ORD20171031.mat');

    % nose out event, primary + secondary
% %     ndirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n93_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     ndirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n93_movDirall_byMT_bins10_binMs20ORD20171031.mat');
% %     dirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n72_movDirall_byRT_bins10_binMs20ORD20171031.mat');
% %     dirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n72_movDirall_byMT_bins10_binMs20ORD20171031.mat');

    % nose out event, primary only
    ndirRT = load(fullfile(uSessionsPath,'evNose Out_un~dirSel_n64_movDirall_byRT_bins10_binMs20_NO20171208.mat'));
    ndirMT = load(fullfile(uSessionsPath,'evNose Out_un~dirSel_n64_movDirall_byMT_bins10_binMs20_NO20171208.mat'));
    dirRT = load(fullfile(uSessionsPath,'evNose Out_undirSel_n36_movDirall_byRT_bins10_binMs20_NO20171208.mat'));
    dirMT = load(fullfile(uSessionsPath,'evNose Out_undirSel_n36_movDirall_byMT_bins10_binMs20_NO20171208.mat'));
    
    % setup
    grayColor = [.8 .8 .8];
    rt_meanColors = [grayColor;cool(numel(ndirRT.auc_max)-2);grayColor];
    mt_meanColors = [summer(numel(ndirMT.auc_max)-1);grayColor];
%     rt_meanColors = cool(numel(ndirRT.auc_max));
%     mt_meanColors = summer(numel(ndirMT.auc_max));
    
    
    % plots
% %     timingField = 'RT';
% %     h = plot_type1(ndirRT,rt_meanColors,timingField);
% %     if doSave
% %         print(h,'-painters','-depsc',fullfile(savePath,['ndir',timingField,'.eps']));
% %         close(h);
% %     end
% %     
% %     timingField = 'MT';
% %     h = plot_type1(ndirMT,mt_meanColors,timingField);
% %     if doSave
% %         print(h,'-painters','-depsc',fullfile(savePath,['ndir',timingField,'.eps']));
% %         close(h);
% %     end
% %     
% %     timingField = 'RT';
% %     h = plot_type1(dirRT,rt_meanColors,timingField);
% %     if doSave
% %         print(h,'-painters','-depsc',fullfile(savePath,['dir',timingField,'.eps']));
% %         close(h);
% %     end
% %     
% %     timingField = 'MT';
% %     h = plot_type1(dirMT,mt_meanColors,timingField);
% %     if doSave
% %         print(h,'-painters','-depsc',fullfile(savePath,['dir',timingField,'.eps']));
% %         close(h);
% %     end
    
    % RASTERS
% %     timingField = 'RT';
% %     h = plot_typeRaster(ndirRT,timingField,rt_meanColors);
% %     print(h,'-painters','-depsc',fullfile(savePath,['ndir',timingField,'_raster','.eps']));
% %     close(h);
% %     
% %     timingField = 'MT';
% %     h = plot_typeRaster(ndirMT,timingField,mt_meanColors);
% %     print(h,'-painters','-depsc',fullfile(savePath,['ndir',timingField,'_raster','.eps']));
% %     close(h);
% %     
% %     timingField = 'RT';
% %     h = plot_typeRaster(dirRT,timingField,rt_meanColors);
% %     print(h,'-painters','-depsc',fullfile(savePath,['dir',timingField,'_raster','.eps']));
% %     close(h);
% %     
% %     timingField = 'MT';
% %     h = plot_typeRaster(dirMT,timingField,mt_meanColors);
% %     print(h,'-painters','-depsc',fullfile(savePath,['dir',timingField,'_raster','.eps']));
% %     close(h);
    
    if true
        all_loadData = {ndirRT,ndirMT,dirRT,dirMT};
        legendText = {'ndirRT','ndirMT','dirRT','dirMT'};

% %         plot_stackedRTCorrs(all_loadData,rt_meanColors,mt_meanColors);

        dirLabel = 'ndir'; % for 1&2
        % --- 1
        timingField = 'RT';
        h = plot_type1(ndirRT,rt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,imageExt]));
            end
            close(h);
        end

        x = [ndirRT.meanBinsSeconds(1:end-1) + diff(ndirRT.meanBinsSeconds)/2]';
        y = ndirRT.auc_min_z';
        ylabelText = 'min Z';
        ylimVals = [-0.5 0.5];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,ndirRT.meanBinsSeconds,rt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end

        x = [ndirRT.meanBinsSeconds(1:end-1) + diff(ndirRT.meanBinsSeconds)/2]';
        y = ndirRT.auc_max_z';
        ylabelText = 'max Z';
        ylimVals = [0 2];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,ndirRT.meanBinsSeconds,rt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end

        % --- 2
        timingField = 'MT';
        h = plot_type1(ndirMT,mt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,imageExt]));
            end
            close(h);
        end
        
        x = [ndirMT.meanBinsSeconds(1:end-1) + diff(ndirMT.meanBinsSeconds)/2]';
        y = ndirMT.auc_min_z';
        ylabelText = 'min Z';
        ylimVals = [-0.5 0.5];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,ndirMT.meanBinsSeconds,mt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end

        x = [ndirMT.meanBinsSeconds(1:end-1) + diff(ndirMT.meanBinsSeconds)/2]';
        y = ndirMT.auc_max_z';
        ylabelText = 'max Z';
        ylimVals = [0 2];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,ndirMT.meanBinsSeconds,mt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end

        dirLabel = 'dir'; % for 3&4
        % ---3
        timingField = 'RT';
        h = plot_type1(dirRT,rt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,imageExt]));
            end
            close(h);
        end

        x = [dirRT.meanBinsSeconds(1:end-1) + diff(dirRT.meanBinsSeconds)/2]';
        y = dirRT.auc_min_z';
        ylabelText = 'min Z';
        ylimVals = [-0.5 0.5];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,dirRT.meanBinsSeconds,rt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end

        x = [dirRT.meanBinsSeconds(1:end-1) + diff(dirRT.meanBinsSeconds)/2]';
        y = dirRT.auc_max_z';
        ylabelText = 'max Z';
        ylimVals = [0 2];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,dirRT.meanBinsSeconds,rt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end

        % ---4
        timingField = 'MT';
        dirLabel = 'dir';
        h = plot_type1(dirMT,mt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,imageExt]));
            end
            close(h);
        end

        x = [dirMT.meanBinsSeconds(1:end-1) + diff(dirMT.meanBinsSeconds)/2]';
        y = dirMT.auc_min_z';
        ylabelText = 'min Z';
        ylimVals = [-0.5 0.5];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,dirMT.meanBinsSeconds,mt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end

        x = [dirMT.meanBinsSeconds(1:end-1) + diff(dirMT.meanBinsSeconds)/2]';
        y = dirMT.auc_max_z';
        ylabelText = 'max Z';
        ylimVals = [0 2];
        h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,dirMT.meanBinsSeconds,mt_meanColors,timingField);
        if doSave
            print(h,'-painters','-depsc',fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,'.eps']));
            if saveImage
                saveas(h,fullfile(savePath,[dirLabel,timingField,'_corr_',ylabelText,imageExt]));
            end
            close(h);
        end
    end
    
% %     h = plot_type2(ndirContra,ndirIpsi);
% %     print(h,'-painters','-depsc',fullfile(savePath,['ndirContraIpsi','.eps']));
% %     close(h);
% %     
% %     h = plot_type2(dirContra,dirIpsi);
% %     print(h,'-painters','-depsc',fullfile(savePath,['dirContraIpsi','.eps']));
% %     close(h);
 end

function plot_stackedRTCorrs(all_loadData,rt_meanColors,mt_meanColors)
	markerSize = 100;
    ylimVals = [-0.5 2];
    
    figuree(600,600);
    lns = [];
    for iCond = 1:4
        loadData = all_loadData{iCond};
        if ismember(iCond,[1,3])
            meanColors = rt_meanColors;
        else
            meanColors = mt_meanColors;
        end
        
        subplot(2,2,iCond);
        x = [1:numel(loadData.auc_min_z)]';
        y = loadData.auc_min_z';
        scatter(x,y,markerSize,meanColors,'filled');
        hold on;
        xlabel('Time (s)');
        ylabel('min Z');
        [f,gof] = fit(x,y,'poly1');
        [RHO,PVAL] = corr(x,y);
        [p,s] = polyfit(x,y,1);
        [yfit,dy] = polyconf(p,x,s,'predopt','curve');
        [xsort,k] = sort(x);
        line(xsort,yfit(k),'color','r');
        line(xsort,yfit(k)-dy,'color','k','linestyle','-');
        line(xsort,yfit(k)+dy,'color','k','linestyle','-');
        xlim([min(x) max(x)]);
        xticks(xlim);
        xticklabels(compose('%1.2f',loadData.meanBinsSeconds([1 end])));
        ylim(ylimVals);
        yticks(ylim);
        curxlim = xlim;
        curylim = ylim;
        text(curxlim(2),curylim(2),{['r^2 = ',num2str(gof.rsquare,'%0.2f')],['p = ',num2str(PVAL,'%0.6f')]},'HorizontalAlignment','right','VerticalAlignment','top');

        x = [1:numel(loadData.auc_max_z)]';
        y = loadData.auc_max_z';
        scatter(x,y,markerSize,meanColors,'filled');
        hold on;
        xlabel('Time (s)');
        ylabel('max Z');
        [f,gof] = fit(x,y,'poly1');
        [RHO,PVAL] = corr(x,y);
        [p,s] = polyfit(x,y,1);
        [yfit,dy] = polyconf(p,x,s,'predopt','curve');
        [xsort,k] = sort(x);
        line(xsort,yfit(k),'color','r');
        line(xsort,yfit(k)-dy,'color','k','linestyle','-');
        line(xsort,yfit(k)+dy,'color','k','linestyle','-');
        xlim([min(x) max(x)]);
        xticks(xlim);
        xticklabels(compose('%1.2f',loadData.meanBinsSeconds([1 end])));
        ylim(ylimVals);
        yticks(ylim);
        curxlim = xlim;
        curylim = ylim;
        text(curxlim(2),curylim(2),{['r^2 = ',num2str(gof.rsquare,'%0.2f')],['p = ',num2str(PVAL,'%0.6f')]},'HorizontalAlignment','right','VerticalAlignment','top');
    end
end

function h = plot_typeRaster(loadData,timingField,meanColors)
    h = figuree(450,250);
    xlimVals = [-1 1];
    lineWidth = 4;
    
    curRaster = loadData.doRasters{1};
    n_rasterReadable = round(100000 / numel(curRaster));
    curRaster_sorted_readable = makeRasterReadable(curRaster',n_rasterReadable);
    plotSpikeRaster(curRaster_sorted_readable,'PlotType','scatter','AutoLabel',false);
    hold on;
    plot([0 0],[1 numel(curRaster)],'r-');
    xlim(xlimVals);
    xticks(xlim);
    yticks(ylim);
    xlabel('Time (s)');
    ylabel('Trial');
    
    if strcmp(timingField,'RT')
        toneLine = colormapline(-loadData.all_useTime_sorted,1:numel(loadData.all_useTime_sorted),[],meanColors);
        legend(toneLine,timingField);
        set(toneLine,'linewidth',lineWidth);
    elseif strcmp(timingField,'MT')
        toneLine = colormapline(loadData.all_useTime_sorted,1:numel(loadData.all_useTime_sorted),[],meanColors);
        legend(toneLine,timingField);
        set(toneLine,'linewidth',lineWidth);
    end

    set(gca,'fontSize',16);
    set(gcf,'color','w');
end

function h = plot_type1_upperCorr(x,y,ylabelText,ylimVals,meanBinsSeconds,meanColors,timingField)
    h = figuree(450,250);
    markerSize = 100;
    
    scatter(x,y,markerSize,meanColors,'filled');
% %     xlim([min(x) max(x)]);
% %     xticklabels(compose('%1.2f',meanBinsSeconds([1 end])));
    xlabel(timingField);
    ylabel(ylabelText);
    switch timingField
        case 'RT'
            x = x(2:end-1);
            y = y(2:end-1);
        case 'MT'
            x = x(1:end-1);
            y = y(1:end-1);
    end
    [f,gof] = fit(x,y,'poly1');
    [RHO,PVAL] = corr(x,y);
    [p,s] = polyfit(x,y,1);
    [yfit,dy] = polyconf(p,x,s,'predopt','curve');
    [xsort,k] = sort(x);
    line(xsort,yfit(k),'color','r');
    line(xsort,yfit(k)-dy,'color','k','linestyle','-');
    line(xsort,yfit(k)+dy,'color','k','linestyle','-');
    xlim([0 1]); % I do not like this, RT and MT can be different
    xticks(xlim);
    ylim(ylimVals);
    yticks(ylim);
    curxlim = xlim;
    curylim = ylim;
    text(curxlim(2),curylim(2),{['r^2 = ',num2str(gof.rsquare,'%0.5f')],['p = ',num2str(PVAL,'%0.5f')]},'HorizontalAlignment','right',...
        'VerticalAlignment','top','fontSize',16);
    
    set(gca,'fontSize',16);
    set(gcf,'color','w');
end

function h = plot_type1(loadData,meanColors,timingField)
    z_yLims = [-.5 2];
    z_xlimVals = [1 size(loadData.z_raw,2)];
    z_xtickVals = [1 floor(size(loadData.z_raw,2)/2) size(loadData.z_raw,2)];
    z_xticklabelText = {'-1','0','1'};
    scatter_maxZ_ylimVals = [0 2];
    scatter_minZ_ylimVals = [-0.5 0.5];
    upperRightPos = [.65 .7 .3 .3];
    upperLeftPos = [.2 .7 .2 .2];
    markerSize = 25;
    lineWidth = 1.5;
    annotateColor = repmat(.75,1,3);
    
    h = figuree(450,250);
    lns = plot(loadData.mean_z','lineWidth',lineWidth);
    set(lns,{'color'},num2cell(meanColors,2));
    xlabel('Time (s)');
    ylabel('Z score');
    ylim(z_yLims);
    yticks(sort([0,z_yLims]));
    xlim(z_xlimVals);
    xticks(z_xtickVals);
    xticklabels(z_xticklabelText);
    binS = 2 / z_xlimVals(2);
    
    % annotate min/max correlation
    ys = repmat(1.75,1,2);
    xs = [round(.2 / binS) round(.7 / binS)];
    
    annotation('doublearrow',x_to_norm_v2(xs(1),xs(2)),y_to_norm_v2(ys(1),ys(2)),'color',annotateColor);
    xs = [round(.75 / binS) round(1.25 / binS)];
    annotation('doublearrow',x_to_norm_v2(xs(1),xs(2)),y_to_norm_v2(ys(1),ys(2)),'color',annotateColor);
    
    grid on;
    setFig;
    
% %     axes('Position',upperLeftPos);
% %     x = [1:numel(loadData.auc_min_z)]';
% %     y = loadData.auc_min_z';
% % % %     y = loadData.auc_max_z';
% %     scatter(x,y,markerSize,meanColors,'filled');
% %     xlabel(timingField);
% %     ylabel('min Z');
% %     [f,gof] = fit(x,y,'poly1');
% %     [RHO,PVAL] = corr(x,y);
% %     [p,s] = polyfit(x,y,1);
% %     [yfit,dy] = polyconf(p,x,s,'predopt','curve');
% %     [xsort,k] = sort(x);
% %     line(xsort,yfit(k),'color','r');
% %     line(xsort,yfit(k)-dy,'color','k','linestyle','-');
% %     line(xsort,yfit(k)+dy,'color','k','linestyle','-');
% %     xlim([min(x) max(x)]);
% %     xticks(xlim);
% %     xticklabels(compose('%1.2f',loadData.meanBinsSeconds([1 end])));
% %     ylim(scatter_minZ_ylimVals);
% %     yticks(ylim);
% %     curxlim = xlim;
% %     curylim = ylim;
% %     text(curxlim(2),curylim(2),{['r^2 = ',num2str(gof.rsquare,'%0.2f')],['p = ',num2str(PVAL,'%0.6f')]},'HorizontalAlignment','right','VerticalAlignment','top');
% % 


% %     axes('Position',upperRightPos);
% % %     x = [1:numel(loadData.auc_max_z)]';
% %     x = [loadData.meanBinsSeconds(1:end-1) + diff(loadData.meanBinsSeconds)/2]';
% %     y = loadData.auc_max_z';
% %     % plot faint lines where data points are?
% % % %     plot(repmat(x,1,2)',repmat(scatter_maxZ_ylimVals,numel(x),1)','color',[.8 .8 .8]);
% % % %     hold on;
% %     scatter(x,y,markerSize,meanColors,'filled');
% %     xlim([min(x) max(x)]);
% %     xticks(x);
% %     xticklabelVals = cell(1,numel(x)-2);
% %     xticklabelVals(:) = {''};
% %     xticklabelVals = {num2str(x(1),'%1.2f'),xticklabelVals{:},num2str(x(end),'%1.2f')};
% %     xticklabels(xticklabelVals);
% %     xlabel(timingField);
% %     ylabel('max Z');
% %     switch timingField
% %         case 'RT'
% %             x = x(2:end-1);
% %             y = y(2:end-1);
% %         case 'MT'
% %             x = x(1:end-1);
% %             y = y(1:end-1);
% %     end
% %     [f,gof] = fit(x,y,'poly1');
% %     [RHO,PVAL] = corr(x,y);
% %     [p,s] = polyfit(x,y,1);
% %     [yfit,dy] = polyconf(p,x,s,'predopt','curve');
% %     [xsort,k] = sort(x);
% %     line(xsort,yfit(k),'color','r');
% %     line(xsort,yfit(k)-dy,'color','k','linestyle','-');
% %     line(xsort,yfit(k)+dy,'color','k','linestyle','-');
% % %     xticklabels(compose('%1.2f',loadData.meanBinsSeconds([1 end])));
% %     ylim(scatter_maxZ_ylimVals);
% %     yticks(ylim);
% %     curxlim = xlim;
% %     curylim = ylim;
% %     text(curxlim(2),curylim(2),{['r^2 = ',num2str(gof.rsquare,'%0.2f')],['p = ',num2str(PVAL,'%0.6f')]},'HorizontalAlignment','right','VerticalAlignment','top');
end

function h = plot_type2(loadData_contra,loadData_ipsi)
    h = figuree(450,300);
    lineWidth = 4;
    sm_lineWidth = 0.5;
    sm_lineOpacity = 0.2;
    colors = lines(2);
    z_yLims = [-.5 2];
    z_xlimVals = [1 size(loadData_contra.z_raw,2)];
    z_xtickVals = [1 floor(size(loadData_contra.z_raw,2)/2) size(loadData_contra.z_raw,2)];
    z_xticklabelText = {'-1','0','1'};
    lns = [];
    
    plot(loadData_contra.mean_z','lineWidth',sm_lineWidth,'color',[colors(1,:) sm_lineOpacity]);
    hold on;
    lns(1) = plot(mean(loadData_contra.mean_z),'lineWidth',lineWidth,'color',colors(1,:));
    plot(loadData_ipsi.mean_z','lineWidth',sm_lineWidth,'color',[colors(2,:) sm_lineOpacity]);
    lns(2) = plot(mean(loadData_ipsi.mean_z),'lineWidth',lineWidth,'color',colors(2,:));
    
    xlim(z_xlimVals);
    xticks(z_xtickVals);
    xticklabels(z_xticklabelText);
    grid on;
    xlabel('Time (s)');
    ylabel('Z score');
    ylim(z_yLims);
    yticks(sort([0,z_yLims]));
    legend(lns,{'Contra','Ipsi'});
    
    set(gca,'fontSize',16);
    set(gcf,'color','w');
end