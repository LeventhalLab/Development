figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
fileNames = {'','_highFreq'};
doSave = true;
doLabels = false;

makeLength = 400000;
nSmooth = makeLength / 1000;

% SETUP
xlimVals = [1 200];
f1_idx = closest(fnew,xlimVals(1));
f2_idx = closest(fnew,xlimVals(2));
f3_idx = closest(fnew,70);
f4_idx = closest(fnew,150);

norm_data_out = [];
norm_data_in = [];
% % ff(500,500);
for ii = 1:size(all_A_out,1)
    data_out = (all_A_out(ii,f1_idx:f2_idx) - mean(all_A_out(ii,f3_idx:f4_idx))) ./ std(all_A_out(ii,f3_idx:f4_idx));
    norm_data_out(ii,:) = data_out;
    data_in = (all_A_in(ii,f1_idx:f2_idx) - mean(all_A_in(ii,f3_idx:f4_idx))) ./ std(all_A_in(ii,f3_idx:f4_idx));
    norm_data_in(ii,:) = data_in;
% %     plot(smooth(data_out,nSmooth));
% %     hold on;
end
usef = linspace(xlimVals(1),xlimVals(2),size(norm_data_in,2));

% PLOT
xlimVals = [1 70;70 200];
ylimVals = [-1 18;-1 18];
useMargin = [1,5];
for iSubplot = 1:2
    h = ff(400,300);
    norm_med_out = smooth(mean(norm_data_out),nSmooth);
    plot(usef,norm_med_out,'lineWidth',2,'color','r');
    hold on;
    
    norm_med_in = smooth(mean(norm_data_in),nSmooth);
    plot(usef,norm_med_in,'lineWidth',2,'color','k');
    % set(gca,'xscale','log');
    
    xmarks = [1 4 7 13 30 70 200];
    xticks(xmarks);
    xlim(xlimVals(iSubplot,:));
    xtickangle(270);
    
    ylim(ylimVals(iSubplot,:));
    yticks(ylim);
    if doLabels
        ylabel('power (uv^2)');
        title('Mean Spectrum All Sessions');
        legend({'OUT trial','IN trial'});
        set(gca,'fontSize',16);
    else
        xticklabels({});
        yticklabels({});
    end
    if iSubplot == 2
        box off;
    end
    set(gcf,'color','w');
    
    tightfig;
    setFig('','',[1,useMargin(iSubplot)]);
    if doSave
        print(gcf,'-painters','-depsc',fullfile(figPath,['sessionsFFT',fileNames{iSubplot},'.eps']));
        close(h);
    end
end