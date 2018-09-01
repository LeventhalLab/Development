doSetup = true;
doSave = true;
doPlot = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/powerCorr';
freqList = logFreqList([1 200],10);
tickLabels = {num2str(freqList(:),'%2.1f')};

if doSetup
    all_corr_arr_in = [];
    all_pval_arr_in = [];
    all_corr_arr_out = [];
    all_pval_arr_out = [];
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        trialTimeRanges = compileTrialTimeRanges(curTrials(trialIds));
        trialTimeRanges_samples_in = round(trialTimeRanges*Fs);
        trialTimeRanges_samples_out = surrogateOutTrialTimes(trialTimeRanges_samples_in);

        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
        W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
        W = squeeze(W);

        disp('got W, processing corr...');
        corr_arr_in = NaN(numel(trialIds),numel(freqList),numel(freqList));
        pval_arr_in = NaN(numel(trialIds),numel(freqList),numel(freqList));
        corr_arr_out = NaN(numel(trialIds),numel(freqList),numel(freqList));
        pval_arr_out = NaN(numel(trialIds),numel(freqList),numel(freqList));
        for iTrial = 1:size(trialTimeRanges_samples_in,1)
            for iFreq = 1:numel(freqList)
                for jFreq = iFreq:numel(freqList)
                    range_in = trialTimeRanges_samples_in(iTrial,1):trialTimeRanges_samples_in(iTrial,2);
                    [R,P] = corr(abs(W(range_in,iFreq).^2),abs(W(range_in,jFreq).^2));
                    corr_arr_in(iTrial,iFreq,jFreq) = R;
                    pval_arr_in(iTrial,iFreq,jFreq) = P;
                    range_out = trialTimeRanges_samples_out(iTrial,1):trialTimeRanges_samples_out(iTrial,2);
                    [R,P] = corr(abs(W(range_out,iFreq).^2),abs(W(range_out,jFreq).^2));
                    corr_arr_out(iTrial,iFreq,jFreq) = R;
                    pval_arr_out(iTrial,iFreq,jFreq) = P;
                end
            end
        end
        all_corr_arr_in(iSession,:,:) = squeeze(nanmean(corr_arr_in));
        all_pval_arr_in(iSession,:,:) = squeeze(nanmean(pval_arr_in));
        all_corr_arr_out(iSession,:,:) = squeeze(nanmean(corr_arr_out));
        all_pval_arr_out(iSession,:,:) = squeeze(nanmean(pval_arr_out));
        
        if doPlot
            rows = 2;
            cols = 2;
            h = figuree(700,700);
            for iCol = 1:2
                switch iCol
                    case 1
                        use_corr = squeeze(nanmean(corr_arr_in));
                        use_pval = squeeze(nanmean(pval_arr_in));
                        titleLabel = 'IN TRIAL';
                    case 2
                        use_corr = squeeze(nanmean(corr_arr_out));
                        use_pval = squeeze(nanmean(pval_arr_out));
                        titleLabel = 'OUT TRIAL';
                end
                subplot(rows,cols,prc(cols,[1 iCol]));
                imagesc(use_corr);
                colormap(gca,jet);
                set(gca,'ydir','normal');
                caxis([-0.5 0.5]);
                xticks(1:numel(freqList));
                xticklabels(tickLabels);
                xtickangle(270);
                yticks(1:numel(freqList));
                yticklabels(tickLabels);
                cbAside(gca,'corr','k');
                title({['Session ',num2str(iSession),', LFP power xcorr'],titleLabel});

                [row,col] = find(use_pval < 0.05 & use_pval >= 0.01);
                for jj = 1:numel(row)
                    if col(jj) ~= row(jj)
                        text(col(jj),row(jj),'*','fontSize',20,'HorizontalAlignment','center');
                    end
                end
                [row,col] = find(use_pval < 0.01);
                for jj = 1:numel(row)
                    if col(jj) ~= row(jj)
                        text(col(jj),row(jj),'**','fontSize',20,'HorizontalAlignment','center');
                    end
                end

                subplot(rows,cols,prc(cols,[2 iCol]));
                imagesc(use_pval);
                colormap(gca,hot);
                set(gca,'ydir','normal');
                caxis([0 0.2]);
                xticks(1:numel(freqList));
                xticklabels(tickLabels);
                xtickangle(270);
                yticks(1:numel(freqList));
                yticklabels(tickLabels);
                cbAside(gca,'pval','k');
                title(titleLabel);

                [row,col] = find(use_pval < 0.05 & use_pval >= 0.01);
                for jj = 1:numel(row)
                    if col(jj) ~= row(jj)
                        text(col(jj),row(jj),'*','color','w','fontSize',20,'HorizontalAlignment','center');
                    end
                end
                [row,col] = find(use_pval < 0.01);
                for jj = 1:numel(row)
                    if col(jj) ~= row(jj)
                        text(col(jj),row(jj),'**','color','w','fontSize',20,'HorizontalAlignment','center');
                    end
                end
            end
            set(gcf,'color','w');
            if doSave
                saveFile = ['session',num2str(iSession,'%02d'),'_IN-OUT_lfpPowerXcorr.png'];
                saveas(h,fullfile(savePath,saveFile));
                close(h);
            end
        end
    end
end

rows = 2;
cols = 2;
h = figuree(700,700);
for iCol = 1:2
    switch iCol
        case 1
            use_corr = squeeze(nanmean(all_corr_arr_in));
            use_pval = squeeze(nanmean(all_pval_arr_in));
            titleLabel = 'IN TRIAL';
        case 2
            use_corr = squeeze(nanmean(all_corr_arr_out));
            use_pval = squeeze(nanmean(all_pval_arr_out));
            titleLabel = 'OUT TRIAL';
    end
    subplot(rows,cols,prc(cols,[1 iCol]));
    imagesc(use_corr);
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis([-0.5 0.5]);
    xticks(1:numel(freqList));
    xticklabels(tickLabels);
    xtickangle(270);
    yticks(1:numel(freqList));
    yticklabels(tickLabels);
    cbAside(gca,'corr','k');
    title({['All Sessions, LFP power xcorr'],titleLabel});

    [row,col] = find(use_pval < 0.05 & use_pval >= 0.01);
    for jj = 1:numel(row)
        if col(jj) ~= row(jj)
            text(col(jj),row(jj),'*','fontSize',20,'HorizontalAlignment','center');
        end
    end
    [row,col] = find(use_pval < 0.01);
    for jj = 1:numel(row)
        if col(jj) ~= row(jj)
            text(col(jj),row(jj),'**','fontSize',20,'HorizontalAlignment','center');
        end
    end

    subplot(rows,cols,prc(cols,[2 iCol]));
    imagesc(use_pval);
    colormap(gca,hot);
    set(gca,'ydir','normal');
    caxis([0 0.2]);
    xticks(1:numel(freqList));
    xticklabels(tickLabels);
    xtickangle(270);
    yticks(1:numel(freqList));
    yticklabels(tickLabels);
    cbAside(gca,'pval','k');
    title(titleLabel);

    [row,col] = find(use_pval < 0.05 & use_pval >= 0.01);
    for jj = 1:numel(row)
        if col(jj) ~= row(jj)
            text(col(jj),row(jj),'*','color','w','fontSize',20,'HorizontalAlignment','center');
        end
    end
    [row,col] = find(use_pval < 0.01);
    for jj = 1:numel(row)
        if col(jj) ~= row(jj)
            text(col(jj),row(jj),'**','color','w','fontSize',20,'HorizontalAlignment','center');
        end
    end
end
set(gcf,'color','w');
if doSave
    saveFile = ['allSessions_IN-OUT_lfpPowerXcorr.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end