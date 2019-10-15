% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local_altLookup')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')

% % load('session_20181212_spikePhaseHist_NewSurrogates.mat')
load('LFPfiles_local_matt');
LFPfiles_local_altLookup = strrep(LFPfiles_local_altLookup,'mattgaidica','matt');

doSetup = true;
doSave = false;
doAlt = true;
% freqList = logFreqList([1 200],10);
% freqList = [3.2,19];
% freqList = {[1 4;4 7;8 12;13 30]};
% freqList = [3.5 8 12 20];
freqList = logFreqList([1 200],30);
freqList = logFreqList([1 2000],30); % RESUBMISSION

if iscell(freqList)
    numelFreqs = size(freqList{:},1);
else
    numelFreqs = numel(freqList);
end
savePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseHist';
nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
loadedFile = [];
nSurr = 1;

if doSetup
    validUnits = [];
    all_spikeHist_pvals = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_rs = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_mus = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_angles = NaN(numel(all_ts),nBins,numelFreqs);
    all_spikeHist_alphas = cell(numel(all_ts),numelFreqs);
    
    all_spikeHist_pvals_surr = NaN(nSurr,numel(all_ts),numelFreqs);
    all_spikeHist_rs_surr = NaN(nSurr,numel(all_ts),numelFreqs);
    all_spikeHist_mus_surr = NaN(nSurr,numel(all_ts),numelFreqs);
    all_spikeHist_angles_surr = NaN(nSurr,numel(all_ts),nBins,numelFreqs);
    all_spikeHist_alphas_surr = cell(nSurr,numel(all_ts),numelFreqs);
    
    all_spikeHist_inTrial_pvals = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_inTrial_rs = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_inTrial_mus = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_inTrial_angles = NaN(numel(all_ts),nBins,numelFreqs);
    all_spikeHist_inTrial_alphas = cell(numel(all_ts),numelFreqs);
    
    all_spikeHist_inTrial_pvals_surr = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_inTrial_rs_surr = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_inTrial_mus_surr = NaN(numel(all_ts),numelFreqs);
    all_spikeHist_inTrial_angles_surr = NaN(numel(all_ts),nBins,numelFreqs);
    all_spikeHist_inTrial_alphas_surr = cell(numel(all_ts),numelFreqs);
    
    for iNeuron = 122%1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        % replace with alternative for LFP
        if doAlt
            sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
        end
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        % only load uniques
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
%             [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);

    decimateFactor = 10;
    sevFile = '/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/R0142_20161207a_R0142_20161207a-1_data_ch44.sev';
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    
    
    
% %             load('/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16_despiked/R0142_20161207a_R0142_20161207a-1_data_ch15_u122.mat');
            curTrials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
            trialTimeRanges = compileTrialTimeRanges(curTrials(trialIds),20);

            if iscell(freqList)
                W = calculateComplexSpectrum(sevFilt,Fs,freqList);
            else
                W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList); % size: 5568092, 1, 3
                W = squeeze(W); % size: 5568092, 3
            end
        end
        
        ts = all_ts{iNeuron};
        ts_samples = floor(ts * Fs);
        ts_samples = ts_samples(ts_samples > 0 & ts_samples <= size(W,1)); % clean conversion errors
        
        spikeAngles = [];
        all_inTrial_ids = [];
        for ii = 1:size(trialTimeRanges,1)
            inTrial_ids = find(ts > trialTimeRanges(ii,1) & ts <= trialTimeRanges(ii,2));
            all_inTrial_ids = [all_inTrial_ids;inTrial_ids];
            spikeAngles = [spikeAngles;angle(W(floor(ts(inTrial_ids)*Fs),:))]; % compiling inTrial spikeAngles
        end
        if size(spikeAngles,1) > 50
            validUnits = [validUnits iNeuron];
            % this is inTrial
            for iFreq = 1:numelFreqs
                alpha = spikeAngles(:,iFreq);
% %                 all_spikeHist_inTrial_alphas{iNeuron,iFreq} = alpha;
                pval = circ_rtest(alpha);
                all_spikeHist_inTrial_pvals(iNeuron,iFreq) = pval;
                r = circ_r(alpha);
                all_spikeHist_inTrial_rs(iNeuron,iFreq) = r;
                mu = circ_mean(alpha);
                all_spikeHist_inTrial_mus(iNeuron,iFreq) = mu;
                counts = histcounts(spikeAngles(:,iFreq),binEdges);
                all_spikeHist_inTrial_angles(iNeuron,:,iFreq) = counts;
            end
            % this is outTrial
            all_outTrial_ids = ones(numel(ts_samples),1);
            all_outTrial_ids(all_inTrial_ids) = 0;
            all_outTrial_ids = logical(all_outTrial_ids);
            
            % surrogate code
            % these need to be shuffled
            spiketrain_duration = max(ts) * 1000; % ms
            spiketrain_meanrate = numel(ts) / max(ts); % s/sec
            spiketrain_gamma_order = 1; % poisson
            [t,s] = fastgammatrain(spiketrain_duration,spiketrain_meanrate,spiketrain_gamma_order);
            ts_poisson = t(s==1) / 1000;
            ts_poisson_samples = floor(ts_poisson * Fs);
            ts_poisson_samples = ts_poisson_samples(1:find(ts_poisson_samples < size(W,1),1,'last'));
            for iSurr = 1:nSurr
                outTrialSurrIdx = randsample(1:numel(ts_poisson_samples),numel(all_inTrial_ids));
                spikeAngles = angle(W(ts_poisson_samples(outTrialSurrIdx),:));
%                 spikeAngles = angle(W(randsample(1:max(ts_poisson_samples),numel(ts_poisson_samples)),:));
                for iFreq = 1:numelFreqs
                    alpha = spikeAngles(:,iFreq);
% %                     all_spikeHist_alphas_surr{iSurr,iNeuron,iFreq} = alpha;
                    pval = circ_rtest(alpha);
                    all_spikeHist_pvals_surr(iSurr,iNeuron,iFreq) = pval;
                    r = circ_r(alpha);
                    all_spikeHist_rs_surr(iSurr,iNeuron,iFreq) = r;
                    mu = circ_mean(alpha);
                    all_spikeHist_mus_surr(iSurr,iNeuron,iFreq) = mu;
                    counts = histcounts(alpha,binEdges);
                    all_spikeHist_angles_surr(iSurr,iNeuron,:,iFreq) = counts;
                end
            end
            % match in-trial sample count, apples to apples
            useSamples = ts_samples(all_outTrial_ids);
            spikeAngles = angle(W(randsample(useSamples,numel(all_inTrial_ids)),:));
            for iFreq = 1:numelFreqs
                alpha = spikeAngles(:,iFreq);
% %                 all_spikeHist_alphas{iNeuron,iFreq} = alpha;
                pval = circ_rtest(alpha);
                all_spikeHist_pvals(iNeuron,iFreq) = pval;
                r = circ_r(alpha);
                all_spikeHist_rs(iNeuron,iFreq) = r;
                mu = circ_mean(alpha);
                all_spikeHist_mus(iNeuron,iFreq) = mu;
                counts = histcounts(alpha,binEdges);
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
    cols = numel(numelFreqs);
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
        for iFreq = 1:numel(numelFreqs)
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