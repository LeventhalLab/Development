doSetup = true;
doSave = true;
doPlot = true;

mixTrials = false;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/powerCorr';
freqList = logFreqList([1 200],30);
tickLabels = {num2str(freqList(:),'%2.1f')};
tWindow = 0.5;
iEvent = 4;
refEvent = 1;
nSurr = 200; % just needs to be more than trial count
zThresh = 5;
pThresh = 0.05;

if doSetup
    all_corr_arr_in = [];
    all_pval_arr_in = [];
    all_corr_arr_in_ref = [];
    all_pval_arr_in_ref = [];
    all_corr_arr_out = [];
    all_pval_arr_out = [];

    all_corrp_arr_in = [];
    all_pvalp_arr_in = [];
    all_corrp_arr_in_ref = [];
    all_pvalp_arr_in_ref = [];
    all_corrp_arr_out = [];
    all_pvalp_arr_out = [];
    
    all_z_corr_arr_ref = [];
    all_z_corr_arr_out = [];
    
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        
        % surrogates
        trialTimeRanges = compileTrialTimeRanges(curTrials(trialIds));
        takeTime = 3;
        takeSamples = round(takeTime * Fs);
        minTime = min(trialTimeRanges(:,2));
        maxTime = max(trialTimeRanges(:,1)) - takeTime;

        data = [];
        surrLog = [];
        iSurr = 0;
        disp('Searching for out of trial times...');
        while iSurr < nSurr + 40
            % try randTs
            randTs = (maxTime-minTime) .* rand + minTime;
            iSurr = iSurr + 1;
            randSample = round(randTs * Fs);
            surrLog(iSurr) = randTs;
            data(:,iSurr) = sevFilt(randSample:randSample + takeSamples - 1);
        end
        disp('Done searching!');
        W_surr = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);
        keepTrials = threshTrialData(data,zThresh);
        startRange = (round(size(W_surr,1)/2) - round(size(W,2)/2/2));
        endRange = startRange + size(W,2) - 1;
        W_surr = W_surr(startRange:endRange,keepTrials(1:nSurr),:);
        % end surrogates

        disp('got W, processing corr...');
        corr_arr_in = NaN(numel(trialIds),numel(freqList),numel(freqList));
        corr_arr_in_ref = NaN(numel(trialIds),numel(freqList),numel(freqList));
        pval_arr_in = NaN(numel(trialIds),numel(freqList),numel(freqList));
        pval_arr_in_ref = NaN(numel(trialIds),numel(freqList),numel(freqList));
        corr_arr_out = NaN(nSurr,numel(freqList),numel(freqList));
        pval_arr_out = NaN(nSurr,numel(freqList),numel(freqList));
        
        corrp_arr_in = NaN(numel(trialIds),numel(freqList),numel(freqList));
        pvalp_arr_in = NaN(numel(trialIds),numel(freqList),numel(freqList));
        corrp_arr_in_ref = NaN(numel(trialIds),numel(freqList),numel(freqList));
        pvalp_arr_in_ref = NaN(numel(trialIds),numel(freqList),numel(freqList));
        corrp_arr_out = NaN(nSurr,numel(freqList),numel(freqList));
        pvalp_arr_out = NaN(nSurr,numel(freqList),numel(freqList));
        
        for iTrial = 1:size(W,3)
            if mixTrials
                mixLabel = '_mixed';
                jTrial = randsample(1:size(W,3),1);
            else
                mixLabel = '';
                jTrial = iTrial;
            end
            for iFreq = 1:numel(freqList)
                for jFreq = iFreq:numel(freqList)
                    [R,P] = corr(abs(W(iEvent,:,iTrial,iFreq))',abs(W(iEvent,:,jTrial,jFreq))');
                    corr_arr_in(iTrial,iFreq,jFreq) = R;
                    pval_arr_in(iTrial,iFreq,jFreq) = P;
                    
                    [R,P] = circ_corrcc(angle(W(iEvent,:,iTrial,iFreq))',angle(W(iEvent,:,jTrial,jFreq))');
                    corrp_arr_in(iTrial,iFreq,jFreq) = R;
                    pvalp_arr_in(iTrial,iFreq,jFreq) = P;
                    
                    [R,P] = corr(abs(W(refEvent,:,iTrial,iFreq))',abs(W(refEvent,:,jTrial,jFreq))');
                    corr_arr_in_ref(iTrial,iFreq,jFreq) = R;
                    pval_arr_in_ref(iTrial,iFreq,jFreq) = P;
                    
                    [R,P] = circ_corrcc(angle(W(refEvent,:,iTrial,iFreq))',angle(W(refEvent,:,jTrial,jFreq))');
                    corrp_arr_in_ref(iTrial,iFreq,jFreq) = R;
                    pvalp_arr_in_ref(iTrial,iFreq,jFreq) = P;
                    
% %                     [R,P] = corr(abs(W_surr(:,iTrial,iFreq)),abs(W_surr(:,iTrial,jFreq)));
% %                     corr_arr_out(iTrial,iFreq,jFreq) = R;
% %                     pval_arr_out(iTrial,iFreq,jFreq) = P;
% %                     
% %                     [R,P] = circ_corrcc(angle(W_surr(:,iTrial,iFreq)),angle(W_surr(:,iTrial,jFreq)));
% %                     corrp_arr_out(iTrial,iFreq,jFreq) = R;
% %                     pvalp_arr_out(iTrial,iFreq,jFreq) = P;
                end
            end
        end
        
        for iSurr = 1:nSurr
            if mixTrials
                jTrial = randsample(1:nSurr,1);
            else
                jTrial = iTrial;
            end
            for iFreq = 1:numel(freqList)
                for jFreq = iFreq:numel(freqList)
                    [R,P] = corr(abs(W_surr(:,iSurr,iFreq)),abs(W_surr(:,jTrial,jFreq)));
                    corr_arr_out(iSurr,iFreq,jFreq) = R;
                    pval_arr_out(iSurr,iFreq,jFreq) = P;
                    
                    [R,P] = circ_corrcc(angle(W_surr(:,iSurr,iFreq)),angle(W_surr(:,jTrial,jFreq)));
                    corrp_arr_out(iSurr,iFreq,jFreq) = R;
                    pvalp_arr_out(iSurr,iFreq,jFreq) = P;
                end
            end
        end
        
        all_corr_arr_in(iSession,:,:) = squeeze(nanmean(corr_arr_in));
        all_pval_arr_in(iSession,:,:) = squeeze(nanmean(pval_arr_in));
        all_corr_arr_in_ref(iSession,:,:) = squeeze(nanmean(corr_arr_in_ref));
        all_pval_arr_in_ref(iSession,:,:) = squeeze(nanmean(pval_arr_in_ref));
        all_corr_arr_out(iSession,:,:) = squeeze(nanmean(corr_arr_out));
        all_pval_arr_out(iSession,:,:) = squeeze(nanmean(pval_arr_out));
        
        all_corrp_arr_in(iSession,:,:) = squeeze(nanmean(corrp_arr_in));
        all_pvalp_arr_in(iSession,:,:) = squeeze(nanmean(pvalp_arr_in));
        all_corrp_arr_in_ref(iSession,:,:) = squeeze(nanmean(corrp_arr_in_ref));
        all_pvalp_arr_in_ref(iSession,:,:) = squeeze(nanmean(pvalp_arr_in_ref));
        all_corrp_arr_out(iSession,:,:) = squeeze(nanmean(corrp_arr_out));
        all_pvalp_arr_out(iSession,:,:) = squeeze(nanmean(pvalp_arr_out));
        
        if doPlot
            rows = 2;
            cols = 5;
            h = figuree(1200,500);
            for iCol = 1:cols
                switch iCol
                    case 1
                        use_corr = squeeze(nanmean(corr_arr_in_ref));
                        use_corrp = squeeze(nanmean(corrp_arr_in_ref));
                        use_pval = squeeze(nanmean(pval_arr_in_ref));
                        use_pvalp = squeeze(nanmean(pvalp_arr_in_ref));
                        caxisVals = [-0.5 0.5];
                        titleLabel = ['IN ref ',eventFieldnames{refEvent}];
                    case 2
                        use_corr = squeeze(nanmean(corr_arr_in));
                        use_corrp = squeeze(nanmean(corrp_arr_in));
                        use_pval = squeeze(nanmean(pval_arr_in));
                        use_pvalp = squeeze(nanmean(pvalp_arr_in));
                        caxisVals = [-0.5 0.5];
                        titleLabel = ['IN ',eventFieldnames{iEvent}];
                    case 3
                        use_corr = squeeze(nanmean(corr_arr_out));
                        use_corrp = squeeze(nanmean(corrp_arr_out));
                        use_pval = squeeze(nanmean(pval_arr_out));
                        use_pvalp = squeeze(nanmean(pvalp_arr_out));
                        caxisVals = [-0.5 0.5];
                        titleLabel = 'OUT';
                    case 4
                        use_corr = (squeeze(nanmean(corr_arr_in)) - squeeze(nanmean(corr_arr_in_ref))) ./ squeeze(nanstd(corr_arr_in_ref));
                        all_z_corr_arr_ref(iSession,:,:) = use_corr;
                        caxisVals = [-1 1];
                        titleLabel = 'Z-score (norm by ref)';
                    case 5
                        use_corr = (squeeze(nanmean(corr_arr_in)) - squeeze(nanmean(corr_arr_out))) ./ squeeze(nanstd(corr_arr_out));
                        all_z_corr_arr_out(iSession,:,:) = use_corr;
                        caxisVals = [-1 1];
                        titleLabel = 'Z-score (norm by OUT)';
                end
                subplot(rows,cols,prc(cols,[1 iCol]));
                imagesc(use_corr);
                colormap(gca,jet);
                set(gca,'ydir','normal');
                caxis(caxisVals);
                xticks(1:numel(freqList));
                xticklabels(tickLabels);
                xtickangle(270);
                yticks(1:numel(freqList));
                yticklabels(tickLabels);
                cbAside(gca,'corr','k');
                title({['Session ',num2str(iSession)],['power ',titleLabel]});
                set(gca,'fontSize',6);

                if ismember(iCol,[1,2])
                    [row,col] = find(use_pval < pThresh);
                    for jj = 1:numel(row)
                        if col(jj) ~= row(jj)
                            text(col(jj),row(jj),'*','fontSize',12,'HorizontalAlignment','center');
                        end
                    end
                end
                
                if ismember(iCol,[1:3])
                    subplot(rows,cols,prc(cols,[2 iCol]));
                    imagesc(use_corrp);
                    colormap(gca,jet);
                    set(gca,'ydir','normal');
                    caxis([0 0.5]);
                    xticks(1:numel(freqList));
                    xticklabels(tickLabels);
                    xtickangle(270);
                    yticks(1:numel(freqList));
                    yticklabels(tickLabels);
                    cbAside(gca,'corr','k');
                    title(['phase ',titleLabel]);
                    set(gca,'fontSize',6);
                
                    [row,col] = find(use_pvalp < pThresh);
                    for jj = 1:numel(row)
                        if col(jj) ~= row(jj)
                            text(col(jj),row(jj),'*','color','w','fontSize',12,'HorizontalAlignment','center');
                        end
                    end
                end
                
            end
                
            set(gcf,'color','w');
            if doSave
                saveFile = ['session',num2str(iSession,'%02d'),'_IN-OUT_lfpPowerXcorr',mixLabel,'.png'];
                saveas(h,fullfile(savePath,saveFile));
                close(h);
            end
        end
    end
end

rows = 2;
cols = 5;
h = figuree(1200,500);
for iCol = 1:cols
    switch iCol
        case 1
            use_corr = squeeze(nanmean(all_corr_arr_in_ref));
            use_corrp = squeeze(nanmean(all_corrp_arr_in_ref));
            use_pval = squeeze(nanmean(all_pval_arr_in_ref));
            use_pvalp = squeeze(nanmean(all_pvalp_arr_in_ref));
            caxisVals = [-0.5 0.5];
            titleLabel = ['IN ref ',eventFieldnames{refEvent}];
        case 2
            use_corr = squeeze(nanmean(all_corr_arr_in));
            use_corrp = squeeze(nanmean(all_corrp_arr_in));
            use_pval = squeeze(nanmean(all_pval_arr_in));
            use_pvalp = squeeze(nanmean(all_pvalp_arr_in));
            caxisVals = [-0.5 0.5];
            titleLabel = ['IN ',eventFieldnames{iEvent}];
        case 3
            use_corr = squeeze(nanmean(all_corr_arr_out));
            use_corrp = squeeze(nanmean(all_corrp_arr_out));
            use_pval = squeeze(nanmean(all_pval_arr_out));
            use_pvalp = squeeze(nanmean(all_pvalp_arr_out));
            caxisVals = [-0.5 0.5];
            titleLabel = 'OUT';
        case 4
            use_corr = squeeze(mean(all_z_corr_arr_ref));
            caxisVals = [-2 2];
            titleLabel = 'Z-score (norm by ref)';
        case 5
            use_corr = squeeze(mean(all_z_corr_arr_out));
            caxisVals = [-2 2];
            titleLabel = 'Z-score (norm by OUT)';
    end
    subplot(rows,cols,prc(cols,[1 iCol]));
    imagesc(use_corr);
    colormap(gca,jet);
    set(gca,'ydir','normal');
    caxis(caxisVals);
    xticks(1:numel(freqList));
    xticklabels(tickLabels);
    xtickangle(270);
    yticks(1:numel(freqList));
    yticklabels(tickLabels);
    cbAside(gca,'corr','k');
    title({['Session ',num2str(iSession)],['power ',titleLabel]});
    set(gca,'fontSize',6);

    if ismember(iCol,[1,2])
        [row,col] = find(use_pval < pThresh);
        for jj = 1:numel(row)
            if col(jj) ~= row(jj)
                text(col(jj),row(jj),'*','fontSize',12,'HorizontalAlignment','center');
            end
        end
    end

    if ismember(iCol,[1:3])
        subplot(rows,cols,prc(cols,[2 iCol]));
        imagesc(use_corrp);
        colormap(gca,jet);
        set(gca,'ydir','normal');
        caxis([0 0.5]);
        xticks(1:numel(freqList));
        xticklabels(tickLabels);
        xtickangle(270);
        yticks(1:numel(freqList));
        yticklabels(tickLabels);
        cbAside(gca,'corr','k');
        title(['phase ',titleLabel]);
        set(gca,'fontSize',6);

        [row,col] = find(use_pvalp < pThresh);
        for jj = 1:numel(row)
            if col(jj) ~= row(jj)
                text(col(jj),row(jj),'*','color','w','fontSize',12,'HorizontalAlignment','center');
            end
        end
    end
end

set(gcf,'color','w');
if doSave
    saveFile = ['allSessions_IN-OUT_lfpPowerXcorr',mixLabel,'.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end