doSetup = false;

iEvent = 4;
freqList = {[1 4;13 30]};
nSurr = 200;
oversampleBy = 4;
tWindow = 0.5;
zThresh = 5;

if doSetup
    iSession = 0;
    session_MIs = {};
    session_means = {};
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

        filtArr = [];
        for iFreq = 1:size(freqList{:},1)
            disp(['Filtering for surrogates ',num2str(freqList{:}(iFreq,1)),' - ',num2str(freqList{:}(iFreq,2)),'Hz']);
            filtArr(iFreq,:) = eegfilt(sevFilt,Fs,freqList{:}(iFreq,1),freqList{:}(iFreq,2));
        end
        
        % surrogates
        trialTimeRanges = compileTrialTimeRanges(curTrials);
        takeTime = tWindow * oversampleBy;
% %         takeSamples = round(takeTime * Fs);
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
        
% %         if ~iscell(freqList)
% %             W_surr = calculateComplexScalograms_EnMasse(data(:,keepTrials(1:nSurr)),'Fs',Fs,'freqList',freqList);
% %         end
% %         tWindow_sample = round(tWindow * Fs);
% %         reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
% %         W_surr = W_surr(reshapeRange,:,:);

        phase = squeeze(angle(W(iEvent,:,:,1)));
        phase = phase(:)';

        amplitude = squeeze(abs(W(iEvent,:,:,2)));
        amplitude = amplitude(:)';

        z = amplitude.*exp(1i*phase);
        m_raw = mean(z);

        all_MI = [];
        all_mean = [];
        for iRep = 0:size(W,3)
            disp(iRep);
            surrogate_m = [];
            for iSurr = 1:nSurr
                surrogate_amplitude = [];
                real_amplitude = [];
                if iRep == size(W,3) % replace all
                    surrogate_amplitude = squeeze(abs(W_surr(:,randperm(nSurr,size(W,3)),2)));
                elseif iRep == 0 % replace none
                    surrogate_amplitude = squeeze(abs(W(iEvent,:,:,2)));
                else
                    % handle squeeze dims, clunky
                    if size(W,3)-iRep == 1
                        real_amplitude = abs(W(iEvent,:,1:size(W,3)-iRep,2))';
                    else
                        real_amplitude = squeeze(abs(W(iEvent,:,1:size(W,3)-iRep,2)));
                    end
                    if iRep == 1
                        surrogate_amplitude = abs(W_surr(:,randperm(nSurr,iRep),2));
                    else
                        surrogate_amplitude = squeeze(abs(W_surr(:,randperm(nSurr,iRep),2)));
                    end
                    surrogate_amplitude = [real_amplitude surrogate_amplitude];
                end
                surrogate_amplitude = surrogate_amplitude(:)';
                surrogate_m(iSurr) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
            end
            [surrogate_mean,surrogate_std] = normfit(surrogate_m);
            all_mean(iRep+1) = surrogate_mean;
            m_norm_length = (abs(m_raw)-surrogate_mean)/surrogate_std;
            all_MI(iRep+1) = m_norm_length;
        end
        session_MIs{iSession} = all_MI;
        session_means{iSession} = all_mean;
    end
end

% check s11
h = ff(400,600);
transVal = 0.5;
lineWidth = 0.5;
for iSession = 1:numel(session_MIs)
    all_MI = session_MIs{iSession};
    all_mean = session_means{iSession};
     % when more trials are replaced by surrogates the MIz increases: because PAC of the real (in trial) is high when
    % compared to the mean/std of the surrogate measures
    subplot(211);
    plot(0:numel(all_MI)-1,all_MI,'color',repmat(transVal,[1 4]),'LineWidth',lineWidth);
    hold on;
    xlabel('Replaced Trials');
    ylabel('MI_z');
    ylim([0 30]);
    title('\beta-\delta PAC');

    % the mean MIraw decreases as actual amplitudes are replaced with surrogates
    subplot(212);
    plot(0:numel(all_MI)-1,all_mean,'color',[1 0 0 transVal],'LineWidth',lineWidth);
    hold on;
    xlabel('Replaced Trials');
    ylabel('mean MI_r_a_w');
    ylim([0 8]);
end
set(gcf,'color','w');