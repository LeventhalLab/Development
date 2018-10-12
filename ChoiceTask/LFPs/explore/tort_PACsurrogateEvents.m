function MImatrix_surrEvents = tort_PACsurrogateEvents(sevFilt,Fs,curTrials,freqList,eventFieldnames)

tWindow = 0.5;
% % tPeri = 0.5;

freqLabels = num2str(freqList(:),'%2.1f');
nBins = 18;
nSurr = 200;

[trialIds,~] = sortTrialsBy(curTrials,'RT');
W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);

% % secSamples = size(W,2) / (tWindow * 2);
% % periSamples = secSamples * tPeri;
% % W = W(:,round(size(W,2)/2) - periSamples:round(size(W,2)/2) + periSamples - 1,:,:);

MImatrix_surrEvents = NaN(size(W,1),nSurr,numel(freqList),numel(freqList));
for iEvent = 1:size(W,1)
    for iSurr = 1:nSurr
        pTrial = randsample(1:size(W,3),1);
        aTrial = randsample(1:size(W,3),1);
        disp(['e',num2str(iEvent),' s',num2str(iSurr)]);
        for ifp = 1:numel(freqList)
            for ifA = ifp:numel(freqList)
                cur_fp = angle(W(iEvent,:,pTrial,ifp));
                binEdges = linspace(-pi,pi,nBins+1);
                [N,edges,bin] = histcounts(cur_fp,binEdges);

                cur_fA = abs(W(iEvent,:,aTrial,ifA).^2);
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
                MImatrix_surrEvents(iEvent,iSurr,ifp,ifA) = MI;
            end
        end
    end
end