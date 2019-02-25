% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local_altLookup')
% load('Canolt_PAC_20190120.mat')

doSetup = false;
doSave = true;
doPlot = true;

if ismac
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/bySession';
else
    savePath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\MthalLFPs\CanoltySessions';
end

% dbstop if error
% dbclear all

tWindow = 0.5;
freqList = logFreqList([1 200],30);
% % freqList_p = logFreqList([2 10],10);
% % freqList_a = logFreqList([10 200],10);
% % freqList = unique([freqList_p freqList_a]);

freqList_p = [1:numel(freqList)];
freqList_a = [1:numel(freqList)];
% % freqList = {[1 4;4 8;13 30;30 70;70 200]};
% % bandLabels = {'\delta','\theta','\beta','\gamma','\gamma_H'};

eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};

nSurr = 200;
nShuff = 100;
oversampleBy = 5; % has to be high for eegfilt() (> 14,000 samples)
zThresh = 5;

if doSetup
    iSession = 0;
    all_MImatrix = {};
    all_shuff_MImatrix_mean = {};
    all_shuff_MImatrix_pvals = {};

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
        sevFilt = artifactThresh(sevFilt,[1],2000);
        sevFilt = sevFilt - mean(sevFilt);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        
        % surrogates
        trialTimeRanges = compileTrialTimeRanges(curTrials);
        takeTime = tWindow * oversampleBy;
        takeSamples = round(takeTime * Fs);
        minTime = min(trialTimeRanges(:,2));
        maxTime = max(trialTimeRanges(:,1)) - takeTime;

        data = [];
        surrLog = [];
        iSurr = 0;
        disp('Gathering surrogates...');
        
        while iSurr < nSurr + 40 + numel(keepTrials) % add buffer for artifact removal
            % try randTs
            randTs = (maxTime-minTime) .* rand + minTime;
            randSample = round(randTs * Fs);
            sampleRange = randSample:randSample + takeSamples - 1;
            thisData = sevFilt(sampleRange);
            if isempty(strfind(diff(thisData),zeros(1,round(numel(sampleRange)*0.1))))
                iSurr = iSurr + 1;
                data(:,iSurr) = thisData;
                surrLog(iSurr) = randTs;
            end
        end
        
        keepTrials = threshTrialData(data,zThresh);
        W_surr = [];
        W_surr = calculateComplexScalograms_EnMasse(data(:,keepTrials(1:nSurr + size(W,3))),'Fs',Fs,'freqList',freqList);
        tWindow_sample = round(tWindow * Fs);
        reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
        W_surr = W_surr(reshapeRange,:,:);
        W(8,:,:,:) = W_surr(:,(1:size(W,3)),:); % add fake trials
        
        
        MImatrix = NaN(size(W,1),numel(freqList_p),numel(freqList_a));
        shuff_MImatrix_mean = MImatrix;
        shuff_MImatrix_pvals = MImatrix;
        surr_ifA = NaN(numel(freqList_a),nSurr); % #save
        for iEvent = 1:size(W,1)
            disp(['working on event #',num2str(iEvent)]);
            for ifp = 1:numel(freqList_p)
                pIdx = ifp;%find(freqList == freqList_p(ifp));
                phase = squeeze(angle(W(iEvent,:,:,pIdx)));
                phase = phase(:)';
                for ifA = ifp:numel(freqList_a)
                    aIdx = freqList_a(ifA);%find(freqList == freqList_a(ifA));
                    amplitude = squeeze(abs(W(iEvent,:,:,aIdx)).^2);
                    amplitude = amplitude(:)';
                    
                    z = amplitude.*exp(1i*phase);
                    m_raw = mean(z);
                    
                    shuff_m_raw = [];
                    for iShuff = 1:nShuff
                        % randomly permutes with REAL W
                        shuff_amplitude = squeeze(abs(W(iEvent,:,randperm(size(W,3),size(W,3)),ifA)).^2);
                        shuff_amplitude = shuff_amplitude(:)';
                        shuff_z = shuff_amplitude.*exp(1i*phase);
                        shuff_m_raw(iShuff) = mean(shuff_z);
                    end
                    
                    if ~any(surr_ifA(ifA,:))
                        surrVals = [];
                        for iSurr = 1:nSurr
                            % randomly permutes with FAKE W (therefore, randomly shifted amplitude)
                            surrogate_amplitude = squeeze(abs(W_surr(:,randperm(nSurr,size(W,3)),ifA)).^2);
                            surrogate_amplitude = surrogate_amplitude(:)';
                            surrVals(iSurr) = mean(surrogate_amplitude.*exp(1i*phase));
                            surrogate_m(iSurr) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
                        end
                    else
                        surrogate_m = surr_ifA(ifA,:);
                    end
                        
                    [surrogate_mean,surrogate_std] = normfit(surrogate_m);
                    
                    m_norm_length = (abs(m_raw) - surrogate_mean) ./ surrogate_std;
                    m_norm_phase = angle(m_raw);
                    m_norm = m_norm_length*exp(1i*m_norm_phase);
                    MImatrix(iEvent,ifp,ifA) = m_norm_length;
                    
                    shuff_m_norm_length = (abs(shuff_m_raw) - surrogate_mean) ./ surrogate_std;
                    shuff_MImatrix_mean(iEvent,ifp,ifA) = mean(shuff_m_norm_length);
%                     shuff_MImatrix_pvals(iEvent,ifp,ifA) = sum(abs(m_norm_length) > abs(shuff_m_norm_length)) / nShuff;
                    shuff_MImatrix_pvals(iEvent,ifp,ifA) = sum(abs(m_raw) > abs(shuff_m_raw)) / nShuff;
                end
            end
        end
        all_MImatrix{iSession} = MImatrix;
        all_shuff_MImatrix_mean{iSession} = shuff_MImatrix_mean;
        all_shuff_MImatrix_pvals{iSession} = shuff_MImatrix_pvals;
    end
end

% % save('Canolt_PAC_20190120','all_MImatrix','all_shuff_MImatrix_mean','all_shuff_MImatrix_pvals',...
% % 'eventFieldnames_wFake','freqList_p','freqList_a','freqList');

if doPlot
    useSessions = [1:30];
    h = CanoltyPAC_trialStitched_print(all_MImatrix,all_shuff_MImatrix_mean,all_shuff_MImatrix_pvals,useSessions,...
    eventFieldnames_wFake,freqList_p,freqList_a,freqList);
    if doSave
        saveFile = ['PAC_s',num2str(useSessions(1)),'-',num2str(useSessions(end)),'_allEvent.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end