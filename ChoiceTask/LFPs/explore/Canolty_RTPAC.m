doSetup = false;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/RT';

freqList = {[1 4;13 30]};
nSurr = 50;
oversampleBy = 4;
tWindow = 2;
tSweep = 0.5;
nSweep = 30;
zThresh = 5;

if doSetup
    compiled_PACRTdata = {};
    compiled_RT = [];
    iSession = 0;
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
        keepAllTimes = allTimes(keepTrials);
        compiled_RT = [compiled_RT keepAllTimes];
        
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
        
        compiled_PACRTdata(iSession).W = W;
        compiled_PACRTdata(iSession).W_surr = W_surr;
        compiled_PACRTdata(iSession).RT = keepAllTimes;
    end
end

if false
    nBins = 10;
    RTlinspace = ceil(linspace(1,numel(compiled_RT),nBins+1));
    RTsorted = sort(compiled_RT);
    RTintervals = RTsorted(RTlinspace);
    RTintervals(end) = 1; % so < works
    RTidxs = {};
    t = 0;
    for ii = 1:nBins
        RTidxs{ii} = find(compiled_RT >= RTintervals(ii) & compiled_RT < RTintervals(ii+1));
        t = t + numel(RTidxs{ii});
    end

    % compile into RT brackets
    W_RT = {};
    decodeSession = {};
    for iBin = 1:nBins
        tRange = 0;
        thisW = [];
        thisLog = [];
        for iSession = 1:numel(compiled_PACRTdata)
            RTs = compiled_PACRTdata(iSession).RT;
            trialIdxs = find(RTs >= RTintervals(ii) & RTs < RTintervals(ii+1));
            thisW(:,:,(1:numel(trialIdxs))+tRange,:) = compiled_PACRTdata(iSession).W(:,:,trialIdxs,:);
            thisLog((1:numel(trialIdxs))+tRange) = repmat(iSession,[1,numel(trialIdxs)]);
            tRange = tRange + numel(trialIdxs);
        end
        W_RT{iBin} = thisW; % in case trials are not divisible by nBins
        decodeSession{iBin} = thisLog;
    end
end

all_m_sweep = [];
sweepSamples = round(tSweep * 2 * Fs);
sweepPoints = floor(linspace(1,size(W,2)-sweepSamples,nSweep));
for iBin = 1:nBins
    W = W_RT{iBin};
    theseSessions = decodeSession{iBin};
    for iEvent = 4%1:7
        m_sweep = [];
        for iSweep = 1:nSweep
            disp(['iBin ',num2str(iBin),'; iEvent = ',num2str(iEvent),'; iSweep = ',num2str(iSweep)]);
            useRange = sweepPoints(iSweep):sweepPoints(iSweep) + sweepSamples - 1;
            phase = squeeze(angle(W(iEvent,useRange,:,1)));
            phase = phase(:)';

            amplitude = squeeze(abs(W(iEvent,useRange,:,2)));
            amplitude = amplitude(:)';

            z = amplitude.*exp(1i*phase);
            m_raw = mean(z);

            surrogate_m = [];
            for iSurr = 1:nSurr
                surrogate_amplitude = [];
                for iRTsession = 1:numel(theseSessions)
                    W_surr = compiled_PACRTdata(theseSessions(iRTsession)).W_surr;
                    surrogate_amplitude = [surrogate_amplitude squeeze(W_surr(useRange,randsample(1:nSurr,1),2))'];
                end
                surrogate_m(iSurr) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
            end
            [surrogate_mean,surrogate_std] = normfit(surrogate_m);

            m_norm_length = (abs(m_raw)-surrogate_mean)/surrogate_std;
            m_sweep(iSweep) = m_norm_length;
        end
        all_m_sweep(iBin,iEvent,:) = m_sweep;
    end
end

h = ff(900,800);
rows = 4;
cols = 2;
subplotMat = [1 3 5 7 2 4 6 8];
t = linspace(-tWindow,tWindow,nSweep);
colors = cool(nBins);
nSmooth = 1;
for iEvent = 4%1:7
    subplot(rows,cols,subplotMat(iEvent));
    for iBin = 1:size(all_m_sweep,1)
        plot(t,smooth(squeeze(all_m_sweep(iBin,iEvent,:)),nSmooth),'color',colors(iBin,:),'lineWidth',2);
        hold on;
        xlim([-tWindow,tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
%         ylim([-10 40]);
%         yticks(sort([ylim 0]));
        ylabel('MI_z');
        title(['\delta-\beta MI_z at ',eventFieldnames{iEvent}]);
    end
    grid on;
end
set(gcf,'color','w');