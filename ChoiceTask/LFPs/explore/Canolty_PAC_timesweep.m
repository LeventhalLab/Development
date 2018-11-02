doSetup = true;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/allSessions';

freqList = {[1 4;13 30]};
nSurr = 200;
oversampleBy = 4;
tWindow = 2;
tSweep = 0.5;
nSweep = 200;
zThresh = 5;

if doSetup
    iSession = 0;
    all_m_sweep = [];
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(['Session #',num2str(iSession)]);

        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        keepTrialIds = trialIds(keepTrials);
        
        filtArr = [];
        for iFreq = 1:size(freqList{:},1)
            disp(['Filtering for surrogates ',num2str(freqList{:}(iFreq,1)),' - ',num2str(freqList{:}(iFreq,2)),' Hz']);
            filtArr(iFreq,:) = eegfilt(sevFilt,Fs,freqList{:}(iFreq,1),freqList{:}(iFreq,2));
        end
        
        % surrogates
        trialTimeRanges = compileTrialTimeRanges(curTrials);
        takeTime = tWindow * oversampleBy;
        takeSamples = size(W,2);
        minTime = min(trialTimeRanges(:,2));
        maxTime = max(trialTimeRanges(:,1)) - takeTime;
        
        W_surr = [];
        data = [];
        surrLog = [];
        iSurr = 0;
        disp('Loading surrogates...');
        while iSurr < nSurr + 40 % add buffer for artifact removal
            % try randTs
            randTs = (maxTime-minTime) .* rand + minTime;
            iSurr = iSurr + 1;
            randSample = round(randTs * Fs);
            sampleRange = randSample:randSample + takeSamples - 1;
            surrLog(iSurr) = randTs;
            for iFreq = 1:size(freqList{:},1)
                W_surr(:,iSurr,iFreq) = filtArr(iFreq,sampleRange);
            end
            data(:,iSurr) = sevFilt(sampleRange);
        end
        keepTrials = threshTrialData(data,zThresh);
        W_surr = W_surr(:,keepTrials(1:nSurr),:);

        sweepSamples = round(tSweep * 2 * Fs);
        sweepPoints = floor(linspace(1,size(W,2)-sweepSamples,nSweep));
        for iEvent = 1:7
            m_sweep = [];
            for iSweep = 1:nSweep
                disp(['iSweep = ',num2str(iSweep)]);
                useRange = sweepPoints(iSweep):sweepPoints(iSweep) + sweepSamples - 1;
                phase = squeeze(angle(W(iEvent,useRange,:,1)));
                phase = phase(:)';

                amplitude = squeeze(abs(W(iEvent,useRange,:,2)));
                amplitude = amplitude(:)';

                z = amplitude.*exp(1i*phase);
                m_raw = mean(z);

                surrogate_m = [];
                for iSurr = 1:nSurr
                    surrogate_amplitude = squeeze(abs(W_surr(useRange,randperm(nSurr,size(W,3)),2)));
                    surrogate_amplitude = surrogate_amplitude(:)';
                    surrogate_m(iSurr) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
                end
                [surrogate_mean,surrogate_std] = normfit(surrogate_m);

                m_norm_length = (abs(m_raw)-surrogate_mean)/surrogate_std;
                m_sweep(iSweep) = m_norm_length;
            end
            all_m_sweep(iSession,iEvent,:) = m_sweep;
        end
    end
end

h = ff(900,800);
rows = 4;
cols = 2;
subplotMat = [1 3 5 7 2 4 6 8];
t = linspace(-tWindow,tWindow,nSweep);
nSmooth = 5;
for iEvent = 1:7
    subplot(rows,cols,subplotMat(iEvent));
    for iSession = 1:size(all_m_sweep,1)
        plot(t,smooth(squeeze(all_m_sweep(iSession,iEvent,:)),nSmooth),'color',repmat(0.5,[1 4]),'lineWidth',1);
        hold on;
        xlim([-tWindow,tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        ylim([-10 40]);
        yticks(sort([ylim 0]));
        ylabel('MI_z');
        title(['\delta-\beta MI_z at ',eventFieldnames{iEvent}]);
    end
    plot(t,smooth(mean(squeeze(all_m_sweep(:,iEvent,:))),nSmooth),'color','k','lineWidth',2);

    trialTimes = [];
    for iNeuron = selectedLFPFiles'
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        % keepTrialIds
        trialTimes = [trialTimes;getPerieventTimes(curTrials(trialIds),eventFieldnames,iEvent)];
    end
    
    colors = lines(7);
    yLine = [-2 0];
    lineWidth = 0.5;
    transVal = 0.05;
    tarEvent = iEvent - 1;
    for tarEvent = 1:7
        if iEvent == tarEvent
            continue;
        end
        yEvent = min(yLine) - 1;
        if isEven(tarEvent)
            yEvent = yEvent - 2;
        end
        for iTrial = 1:size(trialTimes,1)
            x = trialTimes(iTrial,tarEvent);
            plot([x x],yLine,'color',[colors(tarEvent,:),transVal],'lineWidth',lineWidth);
            hold on;
        end
        x = median(trialTimes(:,tarEvent));
        if abs(x) < tWindow
            text(x,yEvent,eventFieldnames{tarEvent},'HorizontalAlignment','center',...
                'VerticalAlignment','top','color',colors(tarEvent,:));
        end
    end

    grid on;
end
set(gcf,'color','w');
saveas(h,fullfile(savePath,'canolty_timeSweep.png'));