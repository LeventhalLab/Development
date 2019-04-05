figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
fileNames = {'','_highFreq'};
doSave = true;
doLabels = false;

makeLength = 400000;
nSmooth = makeLength / 1000;

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
    yticks([]);
    if doLabels
        ylabel('power (uv^2)');
        title('Mean Spectrum All Sessions');
        legend({'OUT trial','IN trial'});
        set(gca,'fontSize',16);
    else
        xticklabels({});
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