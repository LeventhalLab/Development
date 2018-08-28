% function [DKLlocs] = DKLbetaDetect_wholeSession(sevFilt,Fs)
% % To identify periods of high beta power we first calculated
% % the mean and standard deviation of beta power for each recording site during trials. Any
% % moment with beta power greater than two standard deviations above the mean
% % indicated a candidate epoch. The start and end of the epoch were taken as the times at
% % which the beta power trace became less than one standard deviation above the mean
% % (Csicsvari et al., 2003). To accept an epoch as a beta oscillation, its duration had to be
% % at least 2 cycles long at 20 Hz (100 ms), and the mean power in the beta band (15 - 25
% % Hz) for the raw LFP had to be more than twice the mean power in the combined flanking
% % bands (8 - 15 Hz and 25 - 45 Hz)
% duration >= 100ms @ 1STD, power 2x mean of flanking bands

doDebug = false;
doPlot = true;
doSetup = false;
doSave = true;
freqList = [8 15;15 25;25 45]; % beta
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseHist';
nBins = 12;

if doSetup
    all_spikeHist_pvals = NaN(numel(all_ts),1);
    all_spikeHist_angles = NaN(numel(all_ts),nBins);
    all_spikeHist_inTrial_pvals = NaN(numel(all_ts),1);
    all_spikeHist_inTrial_angles = NaN(numel(all_ts),nBins);
    all_spikeHist_outTrial_pvals = NaN(numel(all_ts),1);
    all_spikeHist_outTrial_angles = NaN(numel(all_ts),nBins);
    
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
        ts = all_ts{iNeuron};
        ts_samples = floor(ts * Fs);
        curTrials = all_trials{iNeuron};
        trialTimeRanges = compileTrialTimeRanges(curTrials);

        hx_low = hilbert(eegfilt(sevFilt,Fs,freqList(1,1),freqList(1,2)));
        hx_beta = hilbert(eegfilt(sevFilt,Fs,freqList(2,1),freqList(2,2)));
        hx_high = hilbert(eegfilt(sevFilt,Fs,freqList(3,1),freqList(3,2)));

        power_low = abs(hx_low).^2;
        power_beta = abs(hx_beta).^2;
        power_high = abs(hx_high).^2;

        phase_beta = angle(hx_beta);

        std_low = std(power_low);
        std_beta = std(power_beta);
        std_high = std(power_high);

        [locs,pks] = peakseek(power_beta,Fs/20,std_beta*2); % 50ms separation
        locs_range1 = [];
        locs_qual1 = [];
        rangeCount = 0;
        for iLoc = 1:numel(locs)
            curLoc = locs(iLoc);
            while curLoc > 0
                if power_beta(curLoc) < std_beta
                    locStart = curLoc;
                    break;
                end
                curLoc = curLoc - 1;
            end
            curLoc = locs(iLoc);
            while curLoc <= numel(power_beta)
                if power_beta(curLoc) < std_beta
                    locEnd = curLoc;
                    break;
                end
                curLoc = curLoc + 1;
            end
            if locEnd - locStart > Fs/10
                rangeCount = rangeCount + 1;
                locs_range1(rangeCount,:) = [locStart,locEnd];
                locs_qual1(rangeCount) = locs(iLoc);
            end
        end

        if doDebug
            nLocs = 20;
            figure;
            plot(power_beta(1:locs_range1(nLocs,2)+200));
            hold on;
            plot(locs_qual1(1:nLocs),power_beta(locs_qual1(1:nLocs)),'rx');
            plot([locs_range1(1:nLocs,1)';locs_range1(1:nLocs,2)'],repmat(std_beta,[2 nLocs]),'r-');
        end

        locs_range2 = [];
        locs_qual2 = [];
        rangeCount = 0;
        for iLoc = 1:numel(locs_qual1)
            useRange = locs_range1(iLoc,1):locs_range1(iLoc,2);
            if mean(power_beta(useRange)) > 2*(mean(power_low(useRange) + power_high(useRange)))
                rangeCount = rangeCount + 1;
                locs_qual2(rangeCount) = locs_qual1(iLoc);
                locs_range2(rangeCount,:) = locs_range1(iLoc,:);
            end
        end

        betaAngles = [];
        spikeAngles = [];
        overlapKey = [];
        for iLoc = 1:numel(locs_qual2)
            useRange = locs_range2(iLoc,1):locs_range2(iLoc,2);
            overlap = intersectIterate(trialTimeRanges*Fs,useRange);
            betaAngles = [betaAngles phase_beta(useRange)]; % does beta power peak at a preferred phase?
            spikeIds = find(ts_samples > locs_range2(iLoc,1) & ts_samples < locs_range2(iLoc,2));
            spikeAngles = [spikeAngles phase_beta(spikeIds)];
            overlapKey = [overlapKey repmat(double(overlap),[1 numel(spikeIds)])];
        end

        binEdges = linspace(-pi,pi,nBins+1);
        if sum(overlapKey == 1) > 50 % <- require 50 spikes within trials, old: numel(spikeAngles) > 50
            pval = circ_rtest(spikeAngles);
            counts = histcounts(spikeAngles,binEdges);
            pval_inTrial = circ_rtest(spikeAngles(overlapKey == 1));
            counts_inTrial = histcounts(spikeAngles(overlapKey == 1),binEdges);
            pval_outTrial = circ_rtest(spikeAngles(overlapKey == 0));
            counts_outTrial = histcounts(spikeAngles(overlapKey == 0),binEdges);
            if doPlot
                h = figuree(400,800);
                subplot(311);
                bar([counts counts],'k');
                xticks([0,6.5,12.5,18.5,24]);
                xticklabels([0 180 360 540 720]);
                xlabel('Spike phase (deg)');
                yticks(ylim);
                ylabel('# Spikes');
                pval_ast = '';
                titleColor = 'k';
                if pval < 0.05
                    titleColor = 'r';
                    if pval < 0.01
                        pval_ast = '**';
                    else
                        pval_ast = '*';
                    end
                end
                title({['MTHAL (',num2str(iNeuron),'/366)'],['p = ',num2str(pval,2)],[num2str(numel(spikeAngles)),' spikes']},'color',titleColor);
                
                subplot(312);
                bar([counts_inTrial counts_inTrial],'k');
                xticks([0,6.5,12.5,18.5,24]);
                xticklabels([0 180 360 540 720]);
                xlabel('Spike phase (deg)');
                yticks(ylim);
                ylabel('# Spikes');
                pval_ast = '';
                titleColor = 'k';
                if pval_inTrial < 0.05
                    titleColor = 'r';
                    if pval_inTrial < 0.01
                        pval_ast = '**';
                    else
                        pval_ast = '*';
                    end
                end
                title({['\beta IN TRIAL'],['p = ',num2str(pval_inTrial,2)],[num2str(sum(overlapKey == 1)),' spikes']},'color',titleColor);
                
                subplot(313);
                bar([counts_outTrial counts_outTrial],'k');
                xticks([0,6.5,12.5,18.5,24]);
                xticklabels([0 180 360 540 720]);
                xlabel('Spike phase (deg)');
                yticks(ylim);
                ylabel('# Spikes');
                pval_ast = '';
                titleColor = 'k';
                if pval_outTrial < 0.05
                    titleColor = 'r';
                    if pval_outTrial < 0.01
                        pval_ast = '**';
                    else
                        pval_ast = '*';
                    end
                end
                title({['\beta OUT TRIAL'],['p = ',num2str(pval_outTrial,2)],[num2str(sum(overlapKey == 0)),' spikes']},'color',titleColor);
                set(gcf,'color','w');
                
                if doSave
                    saveFile = [num2str(iNeuron,'%03d'),'_spikePhaseHist.png'];
                    saveas(h,fullfile(savePath,saveFile));
                    close(h);
                end
            end
            all_spikeHist_pvals(iNeuron) = pval;
            all_spikeHist_angles(iNeuron,:) = counts;
            all_spikeHist_inTrial_pvals(iNeuron) = pval_inTrial;
            all_spikeHist_inTrial_angles(iNeuron,:) = counts_inTrial;
            all_spikeHist_outTrial_pvals(iNeuron) = pval_outTrial;
            all_spikeHist_outTrial_angles(iNeuron,:) = counts_outTrial;
        end
    end
end

rows = 3;
cols = 3;
h = figuree(1000,600);
titleLabels = {'\beta ALL','\beta IN TRIAL','\beta OUT TRIAL'};
for iRow = 1:3
    switch iRow
        case 1
            use_spikeHist_pvals = all_spikeHist_pvals;
            use_spikeHist_angle = all_spikeHist_angles;
        case 2
            use_spikeHist_pvals = all_spikeHist_inTrial_pvals;
            use_spikeHist_angle = all_spikeHist_inTrial_angles;
        case 3
            use_spikeHist_pvals = all_spikeHist_outTrial_pvals;
            use_spikeHist_angle = all_spikeHist_outTrial_angles;
    end
    subplot(rows,cols,prc(cols,[iRow 1]));
    counts = histcounts(use_spikeHist_pvals,linspace(0,1,41));
    b = bar(counts,'k');
    % highlight above chance

    xticks([1 round(40/2) 40]);
    xticklabels({'0','0.5','1'});
    xlabel('p-value');
    ylim([0 115]);
    yticks(ylim);
    ylabel('# Units');
    title(titleLabels{iRow});

    nSigMat = use_spikeHist_angle(use_spikeHist_pvals >= 0.05,:);
    nSig_zMean = mean(nSigMat,2);
    nSig_zStd = std(nSigMat,[],2);
    nSigMatZ = (nSigMat - nSig_zMean) ./ nSig_zStd;

    sigMat = use_spikeHist_angle(use_spikeHist_pvals < 0.05,:);
    sig_zMean = mean(sigMat,2);
    sig_zStd = std(sigMat,[],2);
    sigMatZ = (sigMat - sig_zMean) ./ sig_zStd;

    subplot(rows,cols,prc(cols,[iRow 2]));
    nSigBinMax = [];
    for ii = 1:size(nSigMat,1)
        [v,k] = max(nSigMat(ii,:));
        nSigBinMax(ii) = k;
    end
    sigBinMax = [];
    for ii = 1:size(sigMat,1)
        [v,k] = max(sigMat(ii,:));
        sigBinMax(ii) = k;
    end
    counts = histcounts(nSigBinMax,12) / size(nSigMat,1); % !!assumes range(nSigBinMax) is 1:12
    plot([counts counts],'k-','lineWidth',2);
    hold on;
    counts = histcounts(sigBinMax,12) / size(sigMat,1); % !!assumes range(nSigBinMax) is 1:12
    plot([counts counts],'r-','lineWidth',2);
    xticks([1,6.5,12.5,18.5,24]);
    xticklabels([0 180 360 540 720]);
    xlabel('Mean phase (deg)');
    ylim([0 0.2]);
    yticks([0:0.1:0.2]);
    ylabel('Fraction of units');
    title(titleLabels{iRow});
    grid on;

    subplot(rows,cols,prc(cols,[iRow 3]));
    lns(1) = plot([mean(nSigMatZ) mean(nSigMatZ)],'k','lineWidth',2);
    hold on;
    lns(2) = plot([mean(sigMatZ) mean(sigMatZ)],'r','lineWidth',2);
    xticks([1,6.5,12.5,18.5,24]);
    xticklabels([0 180 360 540 720]);
    xlabel('Spike phase (deg)');
    ylim([-0.3 0.3]);
    yticks(sort([ylim,0]));
    ylabel('Z bins');
    title(titleLabels{iRow});
    if iRow == 1
        legend(lns,{'p >= 0.05','p < 0.05'});
    end
    grid on;
end
set(gcf,'color','w');
if doSave
    saveFile = '_Figure6_Leventhal2012_MTHAL.png';
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end