function MImatrix_surr = tort_PACsurrogates(sevFilt,Fs,curTrials,freqList)

    doDebug = true;
    doDebug_iSurr = false;
    % (1) use surrogates from a distance: ~4 wavelengths/cycles from actual time point
    % (2) scramble amplitude/phase trials and compare Nose Out PAC
    % - if PAC is sig. larger normally, delta/beta are locked
    % - if PAC is sig. smaller normally, delta/beta are coincendental to the event
    tWindow = 1;
    tWindow_halfSample = round((tWindow * Fs) / 2);
    oversampleBy = 4;
    % % freqList = logFreqList([2 200],30);

    freqLabels = num2str(freqList(:),'%2.1f');
    nBins = 18;
    nSurr = 20;
    nLocs = nSurr;

    trialTimeRanges = compileTrialTimeRanges(curTrials);
    takeTime = tWindow * oversampleBy;
    takeSamples = round(takeTime * Fs);
    minTime = min(trialTimeRanges(:,2));
    maxTime = max(trialTimeRanges(:,1)) - takeTime;

    data = [];
    randSampleLog = [];
    iLoc = 0;
    disp('Searching for out of trial times...');
    iTry = 0;
    while iLoc <= nLocs % nSurr+!
        % try randTs
        randTs = (maxTime-minTime) .* rand + minTime;
        iTry = iTry + 1;
        % check that randTs is not in-trial
        if ~inTrial(randTs,takeTime,trialTimeRanges)
            iLoc = iLoc + 1;
            randSample = round(randTs * Fs);
            randSampleLog(iLoc) = randSample;
            data(:,iLoc) = sevFilt(randSample:randSample + takeSamples - 1);
        end
    end
    disp('Done searching!');
    
    disp('Calculating W...');
    W = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);
    % reshape W
    reshapeRange = round(size(W,1)/2)-tWindow_halfSample:round(size(W,1)/2)+tWindow_halfSample-1;
    W = W(reshapeRange,:,:);
    
    disp('Generating surrogates...');
    MImatrix_surr = NaN(nSurr,numel(freqList),numel(freqList));

    for iLoc = 1:nLocs
        disp(iLoc);
        for ifp = 1:numel(freqList)
            phase = angle(W(:,iLoc,ifp));
            for ifA = ifp:numel(freqList)
                amplitude = abs(W(:,iLoc,ifA));
                z = amplitude.*exp(1i*phase);
                % mean of z over time, prenormalized value
                m_raw = mean(z);
                surrogate_m = zeros(nSurr,1);
                surrCount = 0;
                for iSurr = 1:nSurr
                    if iLoc ~= iSurr
                        surrCount = surrCount + 1;
                        surrogate_amplitude = abs(W(:,iSurr,ifA));
                        surrogate_m(surrCount) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
                    end
                end
                % fit gaussian to surrogate data, uses normfit.m from MATLAB Statistics toolbox
                [surrogate_mean,surrogate_std] = normfit(surrogate_m);
                % normalize length using surrogate data (z-score) 
                m_norm_length = (abs(m_raw)-surrogate_mean)/surrogate_std;
                m_norm_phase = angle(m_raw);
                m_norm = m_norm_length*exp(1i*m_norm_phase);

                MImatrix_surr(iLoc,ifp,ifA) = m_norm_length;
            end
        end
    end

    if doDebug
        rows = 5;
        cols = 8;
        iLoc = 0;
        for jj = 1:5
            ff(1400,900);
            for ii = 1:rows*cols
                iLoc = iLoc + 1;
                subplot(rows,cols,ii);
                imagesc(squeeze(MImatrix_surr(iLoc,:,:))');
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

        ff(300,600);
        subplot(211);
        plot(sort(randSampleLog));
        ylim([1 numel(sevFilt)]);
        ylabel('whole session samples');
        xlabel('surrogate #');
        title('sampls point of surrogate (sorted)');
        subplot(212);
        plot(randSampleLog,'k.');
        ylim([1 numel(sevFilt)]);
        ylabel('whole session samples');
        title('sampls point of surrogate (not sorted)');
    end
end