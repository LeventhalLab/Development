tWindow = 1;
oversampleBy = 2;
freqList = logFreqList([1 200],30);

freqLabels = num2str(freqList(:),'%2.1f');
nBins = 18;
nSurr = 1000;

iSession = 0;
for iNeuron = selectedLFPFiles(1)'
    iSession = iSession + 1;
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    
    allCues = [];
    for iTrial = 1:numel(curTrials)
        allCues(iTrial) = curTrials(iTrial).timestamps.cueOn;
    end
    minTime = min(allCues);
    maxTime = max(allCues);

    data_a = [];
    data_p = [];
    jitterSamples = [];
    for iSurr = 1:nSurr
        randTs = (maxTime-minTime) .* rand + minTime;
        randSample = round(randTs * Fs);
        data_a(:,iSurr) = sevFilt(randSample:randSample + round(tWindow * Fs * oversampleBy));
        
        jitterSample = round(tWindow * rand * Fs);
        jitterSamples(iSurr) = jitterSample;
        data_p(:,iSurr) = sevFilt(randSample+jitterSample:randSample + round(tWindow * Fs * oversampleBy)+jitterSample);
    end
    W_a = calculateComplexScalograms_EnMasse(data_a,'Fs',Fs,'freqList',freqList);
    W_halfSamples = round(size(W_a,1) / oversampleBy / 2);
    W_middle = round(size(W_a,1) / 2);
    W_a = W_a(W_middle-W_halfSamples:W_middle+W_halfSamples-1,:,:);
    W_p = calculateComplexScalograms_EnMasse(data_p,'Fs',Fs,'freqList',freqList);
    W_p = W_p(W_middle-W_halfSamples:W_middle+W_halfSamples-1,:,:);
    
    MImatrix_surr = NaN(nSurr,numel(freqList),numel(freqList));
    for iSurr = 1:nSurr
        disp(['s',num2str(iSurr)]);
        for ifp = 1:numel(freqList)
            for ifA = ifp:numel(freqList)
                cur_fp = angle(W_p(:,iSurr,ifp));
                binEdges = linspace(-pi,pi,nBins+1);
                [N,edges,bin] = histcounts(cur_fp,binEdges);

                cur_fA = abs(W_a(:,iSurr,ifA).^2);
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
                MImatrix_surr(iSurr,ifp,ifA) = MI;
            end
        end
    end
end

ff(800,800);
for ii = 1:16
    subplot(4,4,ii);
    imagesc(squeeze(MImatrix_surr(ii,:,:))');
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

figure;
histogram(jitterSamples,20)