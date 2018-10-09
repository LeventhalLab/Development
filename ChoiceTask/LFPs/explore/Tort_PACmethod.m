doSetup = true;
doSave = false;
doPlot = false;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod';
zThresh = 2;
tWindow = 2;
tPeri = 0.5;
freqList = logFreqList([2 200],30);

freqLabels = num2str(freqList(:),'%2.1f');
Wlength = 200;
nBins = 18;

iSession = 0;
all_MImatrix = {};
% session_MIMatrix_byRT = {};
% MImatrix_RT = {};
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

        secSamples = size(W,2) / (tWindow * 2);
        periSamples = secSamples * tPeri;
        W = W(:,round(size(W,2)/2) - periSamples:round(size(W,2)/2) + periSamples - 1,:,:);
    %         [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
    %         [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
    %         Wz_phase = Wz_phase(:,:,keepTrials,:);

        
        MImatrix = NaN(size(W,1),size(W,3),numel(freqList),numel(freqList));
%         MImatrixZ = NaN(size(W,1),size(W,3),numel(freqList),numel(freqList));
        for iEvent = 1:size(W,1)
            for iTrial = 1:size(W,3)
                disp(['e',num2str(iEvent),' t',num2str(iTrial)]);
                for ifp = 1:numel(freqList)
                    for ifA = ifp:numel(freqList)
                        cur_fp = angle(W(iEvent,:,iTrial,ifp));
                        binEdges = linspace(-pi,pi,nBins+1);
                        [N,edges,bin] = histcounts(cur_fp,binEdges);

% %                         cur_fA = abs(W(iEvent,:,iTrial,ifA).^2);
                        cur_fA = abs(W(iEvent,:,iTrial,ifA));
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
                        MImatrix(iEvent,iTrial,ifp,ifA) = MI;
                    end
                end
%                 trial_MImatrix = squeeze(MImatrix(iEvent,iTrial,:,:));
%                 trial_MImatrixZ = (trial_MImatrix - squeeze(nanmean(MImatrix_surr))) ./ squeeze(nanstd(MImatrix_surr));
%                 MImatrixZ(iEvent,iTrial,:,:) = trial_MImatrixZ;
            end
        end
%         session_MIMatrix_byRT{iSession} = MImatrix;
%         MImatrix_RT{iSession} = allTimes;
        all_MImatrix{iSession} = MImatrix;
    end
    
    if doPlot
        rows = 2;
        cols = 7;
        h = figuree(1400,400);
        for iEvent = 1:7
%             curMat = squeeze(nanmean(MImatrix(iEvent,:,:,:)));
%             all_MImatrix(iSession,iEvent,:,:) = curMat;
            % !! are there NaNs in active frequencies? Why?
            curMatZ = squeeze(nanmean(MImatrixZ(iEvent,:,:,:)));
            
            subplot(rows,cols,prc(cols,[1 iEvent]));
            imagesc(curMatZ');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([-1.5 1.5]);
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
            
            surr_Arr = [];
            for iSurr = 1:nSurr
                curMat_surr = squeeze(MImatrix_surr(iSurr,:,:));
                curMat_surrZ = (curMat_surr - squeeze(nanmean(MImatrix_surr))) ./ squeeze(nanstd(MImatrix_surr));
                if isempty(surr_Arr)
                    surr_Arr = (curMatZ > curMat_surrZ);
                else
                    surr_Arr = surr_Arr + (curMatZ > curMat_surrZ);
                end
            end
            subplot(rows,cols,prc(cols,[2 iEvent]));
            surr_Arr = 1 - (surr_Arr ./ nSurr);
            imagesc(surr_Arr');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([0 0.5]);
            xticks(1:numel(freqList));
            xticklabels(freqLabels);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList));
            yticklabels(freqLabels);
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            if iEvent == 7
                cbAside(gca,'pval','k');
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