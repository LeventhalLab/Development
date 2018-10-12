function MImatrix_surr = tort_PACsurrogates(sevFilt,Fs,curTrials,freqList)

    doDebug = false;
    % (1) use surrogates from a distance: ~4 wavelengths/cycles from actual time point
    % (2) scramble amplitude/phase trials and compare Nose Out PAC
    % - if PAC is sig. larger normally, delta/beta are locked
    % - if PAC is sig. smaller normally, delta/beta are coincendental to the event
    tWindow = 1;
    sampleCycles = 5; % cycles
    oversampleBy = 4;
    % % freqList = logFreqList([2 200],30);

    freqLabels = num2str(freqList(:),'%2.1f');
    nBins = 18;
    nSurr = 200;

    trialTimeRanges = compileTrialTimeRanges(curTrials);
    % trialTimeRanges_samples = trialTimeRanges * Fs;
    takeTime = (sampleCycles / min(freqList)) * oversampleBy;
    takeSamples = round(takeTime * Fs);
    minTime = min(trialTimeRanges(:,2));
    maxTime = max(trialTimeRanges(:,1)) - takeTime;

    data = [];
    randSampleLog = [];
    iSurr = 0;
    disp('Searching for out of trial times...');
    iTry = 0;
    while iSurr < nSurr
        % try randTs
        randTs = (maxTime-minTime) .* rand + minTime;
        iTry = iTry + 1;
        % check that randTs is not in-trial
        if ~inTrial(randTs,takeTime,trialTimeRanges)
            iSurr = iSurr + 1;
            randSample = round(randTs * Fs);
            randSampleLog(iSurr) = randSample;
            data(:,iSurr) = sevFilt(randSample:randSample + takeSamples - 1);
        end
    end
    disp('Done searching!');
    
    tWindowSamples = tWindow * Fs;
    % we oversampled by 3 (@2Hz, 5 cycles * 3 = 7.5s)
    % should be able to start at tWindow (1s) and still have room to offset by 5 cycles for all freqs
    disp('Calculating W...');
    W = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);

    disp('Generating surrogates...');
    MImatrix_surr = NaN(nSurr,numel(freqList),numel(freqList));
    for iSurr = 1:nSurr
        disp(['s',num2str(iSurr)]);
        for ifp = 1:numel(freqList)
            faStart = round(tWindow * 2 * Fs);
            faEnd = round(faStart + (tWindow * Fs) - 1);
            % centered on sampleCycles + rnd from faStart
%             fpStart = faStart + round(tWindow * 2 * Fs) + round((sampleCycles - 0.5 + rand) / freqList(ifp) * Fs); % freq dep.
%             fpStart = faStart + round((2 + 2 * rand) * Fs); % fixed
            fpStart = faStart + round(tWindow * 2 * Fs) + round((sampleCycles - 0.5 + rand) / min(freqList) * Fs);

            fpEnd = round(fpStart + (tWindow * Fs) - 1);
            cur_fp = angle(W(fpStart:fpEnd,iSurr,ifp));
            for ifA = ifp:numel(freqList)
                binEdges = linspace(-pi,pi,nBins+1);
                [N,edges,bin] = histcounts(cur_fp,binEdges);

% %                 cur_fA = abs(W(faStart:faEnd,iSurr,ifA).^2);
                cur_fA = abs(W(faStart:faEnd,iSurr,ifA));
                mi_bins = zeros(1,nBins);
                
                for iBin = 1:nBins
                    mi_bins(1,iBin) = sum(cur_fA(bin == iBin)) ./ sum(bin == iBin); % mean
                end
                % now get pj
                pj = zeros(1,nBins);
                for iBin = 1:nBins
                    pj(1,iBin) = mi_bins(1,iBin) / sum(mi_bins);
                end
                % now get H
                H = 0;
                for iBin = 1:nBins
                    H = H + (pj(1,iBin) * log(pj(1,iBin)));
                end
                H = -H;
                Hmax = log(nBins);
                MI = (Hmax - H) / Hmax;
                MImatrix_surr(iSurr,ifp,ifA) = MI;
                
                
                % debug
                if doDebug
                    rows = 4;
                    cols = 1;
                    h = ff(900,800);
                    t = linspace(0,size(W,1)/Fs,size(W,1));

                    subplot(rows,cols,1);
                    plot(t,data(:,iSurr));
                    xlim([0 size(W,1)/Fs]);
                    xlabel('time (s)');
                    title({['iSurr: ',num2str(iSurr,'%02d')],'raw data'});

                    subplot(rows,cols,2);
                    plot(t,abs(W(:,iSurr,ifA)));
                    yticks(ylim);
                    xlim([0 size(W,1)/Fs]);
                    xlabel('time (s)');
                    hold on;
                    plot([faStart faEnd]./Fs,[diff(ylim)/2 diff(ylim)/2],'r','lineWidth',6);
                    title(['amplitude ',num2str(freqList(ifA),'%1.2f'),'Hz']);

                    subplot(rows,cols,3);
                    plot(t,angle(W(:,iSurr,ifp)));
                    ylim([-pi pi]);
                    yticks(sort([ylim 0]));
                    xlim([0 size(W,1)/Fs]);
                    xlabel('time (s)');
                    hold on;
                    plot([fpStart fpEnd]./Fs,[0 0],'b','lineWidth',6);
                    title(['phase ',num2str(freqList(ifp),'%1.2f'),'Hz']);
                    
                    subplot(rows,cols,4);
                    bar([pj pj],'k');
                    xticks([1 9 18 19 27 36]);
                    xticklabels({'0','180','270','0','180','270'});
                    xtickangle(270);
                    xlabel('phase');
                    ylim([0 0.1]);
                    yticks(ylim);
                    ylabel('pj');
                    title({'entropy measure',['MI = ',num2str(MI,2)]});
                    
                    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod/debug';
                    set(gcf,'color','w');
                    saveas(h,fullfile(savePath,['iSurr',num2str(iSurr,'%03d'),'_amp',num2str(ifA,'%02d'),'_phase',num2str(ifp,'%02d'),'.png']));
                     close(h);
                end
                
            end
        end
    end

    if doDebug
        rows = 5;
        cols = 8;
        iSurr = 0;
        for jj = 1:5
            ff(1400,900);
            for ii = 1:rows*cols
                iSurr = iSurr + 1;
                subplot(rows,cols,ii);
                imagesc(squeeze(MImatrix_surr(iSurr,:,:))');
                colormap(jet);
                set(gca,'ydir','normal');
                caxis([0 0.05])
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                ylabel('amp (Hz)');
                set(gca,'fontsize',6);
            end
        end

        ff(500,500);
        imagesc(squeeze(nanmean(MImatrix_surr))');
        colormap(jet);
        set(gca,'ydir','normal');
        %     caxis([0 0.2]);
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        ylabel('amp (Hz)');
        set(gca,'fontsize',6);

        figure;
        plot(sort(randSampleLog));
        ylim([1 numel(sevFilt)]);
        ylabel('whole session samples');
        xlabel('surrogate #');
        title('sampls point of surrogate (sorted)');
    end
end

function isInTrial = inTrial(randTs,takeTime,trialTimeRanges)
    isInTrial = false;
    for iTrial = 1:size(trialTimeRanges,1)
        % does it start in-trial?
        if randTs > trialTimeRanges(iTrial,1) && randTs < trialTimeRanges(iTrial,2)
            isInTrial = true;
            return;
        end
        % does it end in-trial?
        if randTs + takeTime > trialTimeRanges(iTrial,1) && randTs + takeTime < trialTimeRanges(iTrial,2)
            isInTrial = true;
            return;
        end
    end
end