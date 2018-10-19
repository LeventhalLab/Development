doSetup = true;
doSave = true;
doPlot = true;
dbstop if error

mixTrials = true;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod';
tWindow = 0.5;
freqList = logFreqList([2 200],10);

freqLabels = num2str(freqList(:),'%2.1f');
nSurr = 200;
oversampleBy = 4;

iSession = 0;
all_MImatrix = {};
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;

    if doSetup
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        
        % surrogates
        trialTimeRanges = compileTrialTimeRanges(curTrials);
        takeTime = tWindow * oversampleBy;
        takeSamples = round(takeTime * Fs);
        minTime = min(trialTimeRanges(:,2));
        maxTime = max(trialTimeRanges(:,1)) - takeTime;

        data = [];
        iSurr = 0;
        disp('Searching for out of trial times...');
        while iSurr < nSurr
            % try randTs
            randTs = (maxTime-minTime) .* rand + minTime;
            % check that randTs is not in-trial
            if ~inTrial(randTs,takeTime,trialTimeRanges)
                iSurr = iSurr + 1;
                randSample = round(randTs * Fs);
                data(:,iSurr) = sevFilt(randSample:randSample + takeSamples - 1);
            end
        end
        disp('Done searching!');
        tWindow_sample = round(tWindow * Fs);
        W_surr = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList);
        reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
        W_surr = W_surr(reshapeRange,:,:);
        
        MImatrix = NaN(size(W,1),size(W,3),numel(freqList),numel(freqList));
        for iEvent = 1:size(W,1)
            disp(['working on event #',num2str(iEvent)]);
            for iTrial = 1:size(W,3)
                for ifp = 1:numel(freqList)
                    for ifA = ifp:numel(freqList)
                        if mixTrials
                            phase = angle(W(iEvent,:,iTrial,ifp));
                        else
                            phase = angle(W(iEvent,:,randperm(size(W,3),1),ifp));
                        end
                        amplitude = abs(W(iEvent,:,iTrial,ifA));
                        z = amplitude.*exp(1i*phase);
                        m_raw = mean(z);
                        
                        for iSurr = 1:nSurr
                            surrogate_amplitude = abs(W_surr(:,iSurr,ifA))';
                            surrogate_m(iSurr) = abs(mean(surrogate_amplitude.*exp(1i*phase)));
                            %disp(nSurr-iSurr);
                        end
                        [surrogate_mean,surrogate_std] = normfit(surrogate_m);
                        m_norm_length = (abs(m_raw)-surrogate_mean)/surrogate_std;
                        m_norm_phase = angle(m_raw);
                        m_norm = m_norm_length*exp(1i*m_norm_phase);
                        
                        MImatrix(iEvent,iTrial,ifp,ifA) = m_norm_length;
                    end
                end
            end
        end
        all_MImatrix{iSession} = MImatrix;
    end
    
    if doPlot
        rows = 2;
        cols = 7;
        h = figuree(1400,400);
        for iEvent = 1:7
            curMat = squeeze(nanmean(MImatrix(iEvent,:,:,:)));

            subplot(rows,cols,prc(cols,[1 iEvent]));
            imagesc(curMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([-2 2]);
            xticks(1:numel(freqList));
            xticklabels(freqLabels);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList));
            yticklabels(freqLabels);
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            if iEvent == 1
                title({[subjectName,' s',num2str(iSession,'%02d')],eventFieldnames{iEvent}});
            else
                title({'',eventFieldnames{iEvent}});
            end
            if iEvent == 7
                cbAside(gca,'Z-MI','k');
            end
            
            % note: z = norminv(alpha/N); N = # of index values
            pMat = normcdf(curMat,'upper')*numel(freqList).^2;
            subplot(rows,cols,prc(cols,[2 iEvent]));
            imagesc(pMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([0 1]);
            xticks(1:numel(freqList));
            xticklabels(freqLabels);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList));
            yticklabels(freqLabels);
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);

            if iEvent == 7
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