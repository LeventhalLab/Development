savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/powerCorr';
decimateFactor = 20;
freqList = logFreqList([3.5 100],30);
[uniqueLFPs_local,ic,ia] = unique(LFPfiles_local);
for iFile = 1:numel(uniqueLFPs_local)
    sevFile = uniqueLFPs_local{iFile};
    disp(sevFile);
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    sevFilt = artifactThresh(sevFilt,1,1000);
    Fs = header.Fs / decimateFactor;
    W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
    W = squeeze(W);
    corr_arr = [];
    pval_arr = [];
    for iFreq = 1:numel(freqList)
        disp(num2str(iFreq))
        for jFreq = iFreq:numel(freqList)
            [R,P] = corrcoef(abs(W(:,iFreq).^2),abs(W(:,jFreq).^2));
            corr_arr(iFreq,jFreq) = R(2);
            pval_arr(iFreq,jFreq) = P(2);
        end
    end
    h = figuree(250,500);
    subplot(211);
    imagesc(corr_arr);
    colormap(jet);
    colorbar;
    set(gca,'ydir','normal');
    caxis([-1 1]);
    cb = colorbar('Ticks',sort([0 caxis]));
    curLims = xlim;
    tickVals = (curLims(1):curLims(end))+0.5;
    tickLabels = {num2str(freqList(:),'%2.1f')};
    xticks(tickVals);
    xticklabels(tickLabels)
    xtickangle(90);
    yticks(tickVals);
    yticklabels(tickLabels);
    xlabel('freq (Hz)');
    ylabel('freq (Hz)');
    title('Corr');
    set(gca,'fontSize',6);

    subplot(212);
    imagesc(pval_arr);
    colorbar;
    set(gca,'ydir','normal');
    caxis([0 1]);
    cb = colorbar('Ticks',caxis);
    curLims = xlim;
    tickVals = (curLims(1):curLims(end))+0.5;
    tickLabels = {num2str(freqList(:),'%2.1f')};
    xticks(tickVals);
    xticklabels(tickLabels)
    xtickangle(90);
    yticks(tickVals);
    yticklabels(tickLabels);
    xlabel('freq (Hz)');
    ylabel('freq (Hz)');
    title('Pval');
    set(gca,'fontSize',6);

    set(h,'color','w');
    saveas(h,fullfile(savePath,[num2str(iFile,'%03d'),'.png']));
    close(h);
end