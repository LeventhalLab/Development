doSetup = true;
doSave = false;
% freqList = logFreqList([1 200],10);
freqList = [3.2,19];
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseHist';
nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
loadedFile = [];

if doSetup
    validUnits = [];
    all_spikeHist_pvals = NaN(numel(all_ts),numel(freqList));
    all_spikeHist_rs = NaN(numel(all_ts),numel(freqList));
    all_spikeHist_mus = NaN(numel(all_ts),numel(freqList));
    all_spikeHist_angles = NaN(numel(all_ts),nBins,numel(freqList));
    all_spikeHist_alphas = cell(numel(all_ts),numel(freqList));
    all_spikeHist_inTrial_pvals = NaN(numel(all_ts),numel(freqList));
    all_spikeHist_inTrial_rs = NaN(numel(all_ts),numel(freqList));
    all_spikeHist_inTrial_mus = NaN(numel(all_ts),numel(freqList));
    all_spikeHist_inTrial_angles = NaN(numel(all_ts),nBins,numel(freqList));
    all_spikeHist_inTrial_alphas = cell(numel(all_ts),numel(freqList));
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        % replace with alternative for LFP
        sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
            [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
        end
        
        ts = all_ts{iNeuron};
        ts_samples = floor(ts * Fs);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        trialTimeRanges = compileTrialTimeRanges(curTrials(trialIds));

        W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
        W = squeeze(W);
        ts_samples = ts_samples(ts_samples > 0 & ts_samples <= size(W,1)); % clean conversion errors
        
        spikeAngles = [];
        all_inTrial_ids = [];
        for ii = 1:size(trialTimeRanges,1)
            inTrial_ids = find(ts > trialTimeRanges(ii,1) & ts <= trialTimeRanges(ii,2));
            all_inTrial_ids = [all_inTrial_ids;inTrial_ids];
            spikeAngles = [spikeAngles;angle(W(floor(ts(inTrial_ids)*Fs),:))];
        end
        if size(spikeAngles,1) > 50
            validUnits = [validUnits iNeuron];
            for iFreq = 1:numel(freqList)
                alpha = spikeAngles(:,iFreq);
                all_spikeHist_alphas{iNeuron,iFreq} = alpha;
                pval = circ_rtest(alpha);
                all_spikeHist_inTrial_pvals(iNeuron,iFreq) = pval;
                r = circ_r(alpha);
                all_spikeHist_inTrial_rs(iNeuron,iFreq) = r;
                mu = circ_mean(alpha);
                all_spikeHist_inTrial_mus(iNeuron,iFreq) = mu;
                counts = histcounts(spikeAngles(:,iFreq),binEdges);
                all_spikeHist_inTrial_angles(iNeuron,:,iFreq) = counts;
            end
            
            all_outTrial_ids = ones(numel(ts_samples),1);
            all_outTrial_ids(all_inTrial_ids) = 0;
            all_outTrial_ids = logical(all_outTrial_ids);
            spikeAngles = angle(W(ts_samples(all_outTrial_ids),:));
            for iFreq = 1:numel(freqList)
                alpha = spikeAngles(:,iFreq);
                all_spikeHist_inTrial_alphas{iNeuron,iFreq} = alpha;
                pval = circ_rtest(alpha);
                all_spikeHist_pvals(iNeuron,iFreq) = pval;
                r = circ_r(alpha);
                all_spikeHist_rs(iNeuron,iFreq) = r;
                mu = circ_mean(alpha);
                all_spikeHist_mus(iNeuron,iFreq) = mu;
                counts = histcounts(spikeAngles(:,iFreq),binEdges);
                all_spikeHist_angles(iNeuron,:,iFreq) = counts;
            end
        end
    end
end

if false % display spike times on phase
    pp = 1000;%size(W,1);
    sp = ts_samples(ts_samples < pp);
    figure;
    for iFreq = [10]
        yyaxis left;
        plot(angle(W(1:pp,iFreq))); hold on;
        plot(ts_samples(1:numel(sp)),angle(W(sp,iFreq)),'.');
        yyaxis right;
        plot(abs(W(1:pp,iFreq)).^2);
    end
    
    % scrap
    sevFilt = eegfilt(sev(1:10000),Fs,175,225);
    W = calculateComplexScalograms_EnMasse(sev(1:10000)','Fs',Fs,'freqList',[20]);
    r_beta = xcorr(squeeze(abs(W(:,:,1)).^2),sev(1:10000));
    r_gamma1 = xcorr(squeeze(abs(W(:,:,2)).^2),sev(1:10000));
    figure;
    plot(normalize(r_beta));
    hold on;
    plot(normalize(r_gamma1));
end

if false % single plots
    for iNeuron = validUnits
        h = figuree(1400,400);
        rows = 2;
        cols = numel(freqList) + 1;
        for iRow = 1:2
            switch iRow
                case 1
                    use_pvals = squeeze(all_spikeHist_pvals(iNeuron,:));
                    use_angles = squeeze(all_spikeHist_angles(iNeuron,:,:));
                    ylabelText = 'OUT TRIAL';
                case 2
                    use_pvals = squeeze(all_spikeHist_inTrial_pvals(iNeuron,:));
                    use_angles = squeeze(all_spikeHist_inTrial_angles(iNeuron,:,:));
                    ylabelText = 'IN TRIAL';
            end
            for iFreq = 1:numel(freqList)
                subplot(rows,cols,prc(cols,[iRow iFreq]));
                bar([use_angles(:,iFreq);use_angles(:,iFreq)],'k');
                xticks([0,6.5,12.5,18.5,24]);
                xticklabels([0 180 360 540 720]);
                xtickangle(90);
                if iRow == rows
                    xlabel('Spike phase (deg)');
                end

                yticks(ylim);
                if iFreq == 1
                    ylabel(['# Spikes, ',ylabelText]);
                end
                pval_ast = '';
                titleColor = 'k';
                if use_pvals(iFreq) < 0.05
                    titleColor = 'r';
                    if use_pvals(iFreq) < 0.01
                        pval_ast = '**';
                    else
                        pval_ast = '*';
                    end
                end
                if iRow == 1
                    title({[num2str(iNeuron),'/366'],[num2str(freqList(iFreq),'%1.2f'),' Hz'],...
                        ['p = ',num2str(use_pvals(iFreq),2)]},'color',titleColor);
                else
                    title(['p = ',num2str(use_pvals(iFreq),2)],'color',titleColor);
                end
            end
            subplot(rows,cols,prc(cols,[iRow iFreq+1]));
            x = 1:numel(freqList);
            plot(x,use_pvals,'k-');
            hold on;
            plot(x(use_pvals < 0.05),use_pvals(use_pvals < 0.05),'ro');
            xticks(x);
            xticklabels(num2str(freqList(:),'%1.2f'));
            xtickangle(90);
            if iRow == 2
                xlabel('Freq (Hz)');
            end
            ylabel('Ray. pval');
            ylim([0 1]);
            yticks(ylim);
        end
        set(gcf,'color','w');
        if doSave
            saveFile = [num2str(iNeuron,'%03d'),'_spikePhaseHist_allFreqs.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end

if false
    h = figuree(1400,400);
    rows = 2;
    cols = numel(freqList);
    for iRow = 1:2
        switch iRow
            case 1
                use_pvals = all_spikeHist_pvals;
                use_angles = all_spikeHist_angles;
                ylabelText = 'OUT TRIAL';
            case 2
                use_pvals = all_spikeHist_inTrial_pvals;
                use_angles = all_spikeHist_inTrial_angles;
                ylabelText = 'IN TRIAL';
        end
        for iFreq = 1:numel(freqList)
            counts = histcounts(use_pvals(validUnits,iFreq),linspace(0,1,20));
            subplot(rows,cols,prc(cols,[iRow,iFreq]));
            bar(counts,'k');
            xlim([0 20]);
            xticks(xlim);
            xticklabels({'0','1'});
            xlabel('pval');
            ylabel('units');
            ylim([0 366]);
            yticks(ylim);
            title(ylabelText);
        end
    end
end