doSave = false;
doPlot = true;
useFakeTrials = false; % then >> all_MImatrix_surr = all_MImatrix;
onlyAfter_t0 = false;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod';
zThresh = 2;
tWindow = 2;
tPeri = 0.5;
freqList = logFreqList([1 200],30);

freqLabels = num2str(freqList(:),'%2.1f');
Wlength = 200;
nBins = 18;

iSession = 0;
all_MImatrix = [];
session_MIMatrix_byRT = {};
MImatrix_RT = {};
for iNeuron = selectedLFPFiles(1)'
    iSession = iSession + 1;

    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    if ~useFakeTrials
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    else
        fakeTrials = generateFakeTrials(numel(curTrials(trialIds)),curTrials,eventFieldnames);
        W = eventsLFPv2(fakeTrials,sevFilt,tWindow,Fs,freqList,eventFieldnames);
    end

    secSamples = size(W,2) / (tWindow * 2);
    periSamples = secSamples * tPeri;
    W = W(:,round(size(W,2)/2) - periSamples:round(size(W,2)/2) + periSamples - 1,:,:);
%         [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
%         [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
%         Wz_phase = Wz_phase(:,:,keepTrials,:);
    if onlyAfter_t0
        W = W(:,round(size(W,2)/2):end,:,:); % post
%         W = W(:,1:round(size(W,2)/2),:,:); % pre
    end

    MImatrix = NaN(size(W,1),size(W,3),numel(freqList),numel(freqList));
    for iEvent = 1:size(W,1)
        for iTrial = 1:size(W,3)
            disp(['e',num2str(iEvent),' t',num2str(iTrial)]);
            for ifp = 1:numel(freqList)
                for ifA = ifp:numel(freqList)
                    cur_fp = angle(W(iEvent,:,iTrial,ifp));
                    binEdges = linspace(-pi,pi,nBins+1);
                    [N,edges,bin] = histcounts(cur_fp,binEdges);

                    cur_fA = abs(W(iEvent,:,iTrial,ifA).^2);
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
        end
    end
    session_MIMatrix_byRT{iSession} = MImatrix;
    MImatrix_RT{iSession} = allTimes;
    
    if doPlot
%         for iEvent = 1:size(MImatrix,1)
%             h = figuree(1200,800);
%             rowscols = ceil(sqrt(size(MImatrix,2)));
%             for iTrial = 1:size(MImatrix,2)
%                 subplot(rowscols,rowscols,iTrial);
%                 curMat = squeeze(MImatrix(iEvent,iTrial,:,:));
%                 imagesc(curMat');
%                 colormap(jet);
%                 set(gca,'ydir','normal');
%                 caxis([0 0.2]);
%                 xticks(freqIdx);
%                 xticklabels(freqLabels);
%                 xlabel('phase (Hz)');
%                 yticks(freqIdx);
%                 yticklabels(freqLabels);
%                 ylabel('amp (Hz)');
%                 set(gca,'fontsize',6);
%                 title(['e',num2str(iEvent),', t',num2str(iTrial)]);
%             end
%             set(gcf,'color','w');
%             saveFile = ['s',num2str(iSession,'%02d'),'_e',num2str(iEvent),'_allTrialsByRT.png'];
%             saveas(h,fullfile(savePath,saveFile));
%             close(h);
%         end

        rows = 3;
        cols = 7;
        h = figuree(1200,600);
        for iEvent = 1:7
            curMat = squeeze(nanmean(MImatrix(iEvent,:,:,:)));
            
            subplot(rows,cols,prc(cols,[1 iEvent]));
            all_MImatrix(iSession,iEvent,:,:) = curMat;
            imagesc(curMat');
            colormap(jet);
            set(gca,'ydir','normal');
            caxis([0 0.2]);
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
            
            surr_Arr = [];
            for iSurr = 1:nSurr
                curMat_surr = squeeze(MImatrix_surr(iSurr,:,:));
                if isempty(surr_Arr)
                    surr_Arr = (curMat > curMat_surr);
                else
                    surr_Arr = surr_Arr + (curMat > curMat_surr);
                end
            end
            subplot(rows,cols,prc(cols,[2 iEvent]));
            surr_Arr = surr_Arr ./ nSurr;
            imagesc(curMat');
            colormap(bone);
            set(gca,'ydir','normal');
            caxis([0 0.05]);
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
            if useFakeTrials
                saveFile = ['s',num2str(iSession,'%02d'),'_allEvent_surr.png'];
            else
                saveFile = ['s',num2str(iSession,'%02d'),'_allEvent.png'];
            end
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end