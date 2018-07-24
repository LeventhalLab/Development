doSetup = true;
zThresh = 2;
freqList = logFreqList([1 200],30);

[sessionNames,~,ia] = unique(analysisConf.sessionNames);
for iSession = 1%:numel(sessionNames)
    sessionTs = [];
    for iNeuron = find(ia == iSession)'
        sessionTs = [sessionTs;all_ts{iNeuron}];
    end
    
%     sevFile = LFPfiles_local{selectedLFPFiles(iSession)};
%     curTrials = all_trials{iNeuron};
%     [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
%     [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
%     W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
    [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
    
    tWindow = 2;
    tsPeths = eventsPeth(curTrials(keepTrials),sessionTs,tWindow,eventFieldnames);
    SDEs = {};
    tWindow = 1;
    for iTrial = 1:size(tsPeths,1)
        for iEvent = 1:size(tsPeths,2)
            thisSDE = get_SDE(tsPeths{iTrial,iEvent},tWindow,Wlength);
            xcorrBands = [];
            for iBand = 1:numel(freqList)
                [r,lags] = xcorr(squeeze(Wz_power(iEvent,:,iTrial,iBand))',thisSDE);
                xcorrBands(:,iBand) = r;
            end
        end
    end
    
end

% attempting to keep settings self-contained
function s = get_SDE(ts,tWindow,nBins)

sigma = .020; % kernel std

% binWidth = .001; % 1ms
% binEdges = -tWindow:binWidth:tWindow;
binEdges = linspace(-tWindow,tWindow,nBins+1);
binWidth = mean(diff(binEdges));
counts = histcounts(ts,binEdges); % bin data
edges = [-3*sigma:binWidth:3*sigma]; % time ranges
kernel = normpdf(edges,0,sigma); % eval guassian kernel
kernel = kernel*binWidth; % multiply by bin width
sConv = conv(counts,kernel); % convolve

halfKernel = ceil(numel(edges)/2); % index of kernel center
s = sConv(halfKernel:halfKernel + numel(counts) - 1); % remove kernel smoothing from edges

end