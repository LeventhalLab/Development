% load('session_20180925_entrainmentSurrogates.mat', 'eventFieldnames')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20180925_entrainmentSurrogates.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/bySession';
doSetup = false;
doSave = true;
doPlot = true;
doDebug = false;
dbstop if error

tWindow = 0.5;
% freqList = logFreqList([2 200],11);
freqList_p = logFreqList([2 10],10);
freqList_a = logFreqList([10 200],10);
freqList = unique([freqList_p freqList_a]);

nSurr = 200;
nShuff = 1000;
oversampleBy = 4;
zThresh = 5;

iSession = 0;
all_MImatrix = {};
all_shuff_MImatrix_mean = {};
all_shuff_MImatrix_pvals = {};

for iNeuron = selectedLFPFiles(1)'
    iSession = iSession + 1;
    disp(['Session #',num2str(iSession)]);
    if doSetup
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
            % check that randTs is not in-trial
% %             if inTrial(randTs,takeTime,trialTimeRanges)
                iSurr = iSurr + 1;
                randSample = round(randTs * Fs);
                surrLog(iSurr) = randTs;
                data(:,iSurr) = sevFilt(randSample:randSample + takeSamples - 1);
%             end
        end
        disp('Done searching!');
        keepTrials = threshTrialData(data,zThresh);
        W_surr = calculateComplexScalograms_EnMasse(data(:,keepTrials(1:nSurr + size(W,3))),'Fs',Fs,'freqList',freqList);
        tWindow_sample = round(tWindow * Fs);
        reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
        % W_surr should now have nSurr + extra trials for fake out of trial event
        W(8,:,:,:) = W_surr(reshapeRange,(1:size(W,3))+nSurr,:);
        W_surr = W_surr(reshapeRange,1:nSurr,:);
        
        MImatrix = NaN(size(W,1),numel(freqList_p),numel(freqList_a));
        shuff_MImatrix_mean = MImatrix;
        shuff_MImatrix_pvals = MImatrix;
        surr_ifA = NaN(numel(freqList_a),nSurr); % #save
        for iEvent = 1:size(W,1)
            disp(['working on event #',num2str(iEvent)]);
            for ifp = 1:numel(freqList_p)
                for ifA = 1:numel(freqList_a)
                    pIdx = find(freqList == freqList_p(ifp));
                    phase = squeeze(angle(W(iEvent,:,:,pIdx)));
                    phase = phase(:)';
                    
                    aIdx = find(freqList == freqList_a(ifA));
                    amplitude = squeeze(abs(W(iEvent,:,:,aIdx)));
                    amplitude = amplitude(:)';
                    
                    z = amplitude.*exp(1i*phase);
                    m_raw = mean(z);
                    
                    shuff_m_raw = [];
                    for iShuff = 1:nShuff
                        shuff_amplitude = squeeze(abs(W(iEvent,:,randperm(size(W,3),size(W,3)),ifA)));
                        shuff_amplitude = shuff_amplitude(:)';
                        shuff_z = shuff_amplitude.*exp(1i*phase);
                        shuff_m_raw(iShuff) = mean(shuff_z);
                    end
                    
                    if ~any(surr_ifA(ifA,:))
                        surrVals = [];
                        for iSurr = 1:nSurr
                            surrogate_amplitude = squeeze(abs(W_surr(:,randperm(nSurr,size(W,3)),ifA)));
                            surrogate_amplitude = surrogate_amplitude(:)';
                            surrVals(iSurr) = mean(surrogate_amplitude.*exp(1i*phase));
                            surrogate_m(iSurr) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
                        end
                    else
                        surrogate_m = surr_ifA(ifA,:);
                    end
                        
                    [surrogate_mean,surrogate_std] = normfit(surrogate_m);
                    
                    m_norm_length = (abs(m_raw)-surrogate_mean)/surrogate_std;
                    m_norm_phase = angle(m_raw);
                    m_norm = m_norm_length*exp(1i*m_norm_phase);
                    MImatrix(iEvent,ifp,ifA) = m_norm_length;
                    
                    shuff_m_norm_length = (abs(shuff_m_raw)-surrogate_mean)./surrogate_std;
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
    
    if doPlot
        pLims = [0 0.001];
        zLims = [-26 26];
        rows = 4;
        cols = size(W,1);
        h = figuree(1300,800);
        eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};
        for iEvent = 1:size(W,1)
            curMat = squeeze(MImatrix(iEvent,:,:));
            subplot(rows,cols,prc(cols,[1 iEvent]));
            imagesc(curMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(zLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            if iEvent == 1
                title({'mean real Z',[subjectName,' s',num2str(iSession,'%02d')],eventFieldnames_wFake{iEvent}});
            else
                title({'mean real Z',eventFieldnames_wFake{iEvent}});
            end
            if iEvent == size(W,1)
                cbAside(gca,'Z-MI','k');
            end

            % note: z = norminv(alpha/N); N = # of index values
            pMat = normcdf(curMat,'upper')*numel(freqList).^2;
            subplot(rows,cols,prc(cols,[2 iEvent]));
            imagesc(pMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(pLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            title('mean real pval');
            if iEvent == size(W,1)
                cbAside(gca,'p-value','k');
            end
            
            curMat = squeeze(shuff_MImatrix_mean(iEvent,:,:));
            subplot(rows,cols,prc(cols,[3 iEvent]));
            imagesc(curMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(zLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            title('mean shuff Z');
            if iEvent == size(W,1)
                cbAside(gca,'Z-MI','k');
            end
            
            pMat = squeeze(shuff_MImatrix_pvals(iEvent,:,:));
            subplot(rows,cols,prc(cols,[4 iEvent]));
            imagesc(1-pMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis(pLims);
            xticks(1:numel(freqList_p));
            xticklabels(num2str(freqList_p(:),'%2.1f'));
            xtickangle(270);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList_a));
            yticklabels(num2str(freqList_a(:),'%2.1f'));
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            title('mean shuff pval');
            if iEvent == size(W,1)
                cbAside(gca,'p-value','k');
            end
        end
        set(gcf,'color','w');
        if doSave
            saveFile = ['s',num2str(iSession,'%02d'),'_allEvent.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end