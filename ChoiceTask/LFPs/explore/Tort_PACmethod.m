doSetup = true;
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/tortPAC';
zThresh = 2;
tWindow = 1;
freqList = logFreqList([3.5 200],30);

freqIdx = floor(linspace(1,numel(freqList),5));
freqLabels = freqList(freqIdx);
freqLabels = num2str(freqLabels(:),'%2.1f');
Wlength = 200;
nBins = 18;

iSession = 0;
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    if doSetup
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
%         [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
%         [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
%         Wz_phase = Wz_phase(:,:,keepTrials,:);
        
        MImatrix = NaN(size(W,1),size(W,3),numel(freqList),numel(freqList));
        for iEvent = 1:size(Wz_power,1)
            for iTrial = 1:size(Wz_power,3)
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
    end

    figuree(1200,300);
    for iEvent = 1:7
        subplot(1,7,iEvent);
        curMat = squeeze(nanmean(MImatrix(iEvent,:,:,:)));
        imagesc(curMat');
        colormap(jet);
        set(gca,'ydir','normal');
% %         caxis([-0.5 0.5]);
        xticks(freqIdx);
        xticklabels(freqLabels);
        yticks(freqIdx);
        yticklabels(freqLabels);
        set(gca,'fontsize',6);
    end
end
