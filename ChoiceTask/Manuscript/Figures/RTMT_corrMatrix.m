function RTMT_corrMatrix()

    doSave = false;

    ndirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n54_movDirall_byRT_bins10_binMs20ORD20172409.mat');
    ndirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n54_movDirall_byMT_bins10_binMs20ORD20172509.mat');
    dirRT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n42_movDirall_byRT_bins10_binMs20ORD20172209.mat');
    dirMT = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n42_movDirall_byMT_bins10_binMs20ORD20172309.mat');
    dirIpsi = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n42_movDiripsi_byRT_bins10_binMs20ORD20172309.mat');
    dirContra = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_undirSel_n42_movDircontra_byRT_bins10_binMs20ORD20172409.mat');
    ndirIpsi = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n54_movDiripsi_byRT_bins10_binMs20ORD20172509.mat');
    ndirContra = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp/uSessions/evNose Out_un~dirSel_n54_movDircontra_byRT_bins10_binMs20ORD20172609.mat');

    % setup
    rt_meanColors = cool(numel(ndirRT.meanBinsSeconds)-1);
    mt_meanColors = summer(numel(ndirMT.meanBinsSeconds)-1);
    
% %     rt_xlimVals = [0 0.4];
% %     mt_xlimVals = [0 0.4];
    
    savePath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/temp';
    
    % plots
    h = plot_type1(ndirRT,rt_meanColors);
    if doSave
        print(h,'-painters','-depsc',fullfile(savePath,['ndirRT','.eps']));
        close(h);
    end
    
    h = plot_type1(ndirMT,mt_meanColors);
    if doSave
        print(h,'-painters','-depsc',fullfile(savePath,['ndirMT','.eps']));
        close(h);
    end
    
    h = plot_type1(dirRT,rt_meanColors);
    if doSave
        print(h,'-painters','-depsc',fullfile(savePath,['dirRT','.eps']));
        close(h);
    end
    
    h = plot_type1(dirMT,mt_meanColors);
    if doSave
        print(h,'-painters','-depsc',fullfile(savePath,['dirMT','.eps']));
        close(h);
    end
    
% %     h = plot_type2(ndirContra,ndirIpsi);
% %     print(h,'-painters','-depsc',fullfile(savePath,['ndirContraIpsi','.eps']));
% %     close(h);
% %     
% %     h = plot_type2(dirContra,dirIpsi);
% %     print(h,'-painters','-depsc',fullfile(savePath,['dirContraIpsi','.eps']));
% %     close(h);
    
% %     h = plot_typeRaster(ndirRT,'RT',rt_meanColors);
% %     print(h,'-painters','-depsc',fullfile(savePath,['ndirRT_raster','.eps']));
% %     close(h);
% %     
% %     h = plot_typeRaster(dirMT,'MT',mt_meanColors);
% %     print(h,'-painters','-depsc',fullfile(savePath,['dirMT_raster','.eps']));
% %     close(h);
end

function h = plot_typeRaster(loadData,timingField,meanColors)
    h = figuree(450,300);
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
    elseif strcmp(timingField,'MT')
        toneLine = colormapline(loadData.all_useTime_sorted,1:numel(loadData.all_useTime_sorted),[],meanColors);
        legend(toneLine,timingField);
    end
% %     legend(toneLine,timingField);

    set(toneLine,'linewidth',lineWidth);
    set(gca,'fontSize',16);
    set(gcf,'color','w');
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

function h = plot_type1(loadData,meanColors)
    z_yLims = [-.5 2];
    z_xlimVals = [1 size(loadData.z_raw,2)];
    z_xtickVals = [1 floor(size(loadData.z_raw,2)/2) size(loadData.z_raw,2)];
    z_xticklabelText = {'-1','0','1'};
    scatter_maxZ_ylimVals = [0 2];
    scatter_minZ_ylimVals = [-0.5 0];
    upperRightPos = [.65 .7 .2 .2];
    upperLeftPos = [.2 .7 .2 .2];
    markerSize = 15;
    lineWidth = 1.5;
    
    h = figuree(450,300);
    lns = plot(loadData.mean_z','lineWidth',lineWidth);
    set(lns,{'color'},num2cell(meanColors,2));
    xlabel('Time (s)');
    ylabel('Z score');
    ylim(z_yLims);
    yticks(sort([0,z_yLims]));
    xlim(z_xlimVals);
    xticks(z_xtickVals);
    xticklabels(z_xticklabelText);
    grid on;
    set(gca,'fontSize',16);
    box off;
    
    axes('Position',upperLeftPos);
    x = [1:numel(loadData.auc_min_z)]';
    y = loadData.auc_min_z';
% %     y = loadData.auc_max_z';
    scatter(x,y,markerSize,'k','filled');
    xlabel('RT');
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
    ylim(scatter_minZ_ylimVals);
    yticks(ylim);
    curxlim = xlim;
    curylim = ylim;
    text(curxlim(2),curylim(2),{['r^2 = ',num2str(gof.rsquare,3)],['p = ',num2str(PVAL,3)]},'HorizontalAlignment','right','VerticalAlignment','top');

    axes('Position',upperRightPos);
    x = [1:numel(loadData.auc_max_z)]';
    y = loadData.auc_max_z';
    scatter(x,y,markerSize,'k','filled');
    xlabel('RT');
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
    ylim(scatter_maxZ_ylimVals);
    yticks(ylim);

    curxlim = xlim;
    curylim = ylim;
    text(curxlim(2),curylim(2),{['r^2 = ',num2str(gof.rsquare,3)],['p = ',num2str(PVAL,3)]},'HorizontalAlignment','right','VerticalAlignment','top');

    set(gcf,'color','w');
end