function [allScalograms,nScalograms] = tsScalogram_DKL(ts,sevFilt,tWindow,scaloWindow,Fs,freqList)
upperPrctile = 85;
lowerPrctile = 15;
lfpThresh = 0.5e6; % diff uV^2, *this depends on decimate factor, need to generalize it

endTs = length(sevFilt) / Fs; % seconds

% sigma = 0.05; % 0.05 = 50ms
sigma = round(mean(diff(ts))/3,3); % use mean ISI?
[s,binned,kernel] = spikeDensityEstimate(ts,endTs,sigma);

upperThresh = prctile(s,upperPrctile);
lowerThresh = prctile(s(s>0),lowerPrctile);

occurs = 1; % 50 = 50ms, this is kind of redundant
spansAll = round([ts*Fs,ts*Fs]);
spansUpper = findThreshSpans(s,upperThresh,occurs);
spansMiddle = findThreshSpans(s,[lowerThresh upperThresh],occurs);
spansLower = findThreshSpans(s,-lowerThresh,occurs);

windowSamples = round(Fs * tWindow);
scaloSamples = round(Fs * scaloWindow);
scaloSampleRange = (windowSamples - scaloSamples) : (windowSamples + scaloSamples) - 1;
% allScalograms = [];
allSpans = {spansAll,spansLower,spansMiddle,spansUpper};
nScalograms = 0;
allScalograms = zeros(length(allSpans), length(freqList),scaloSamples*2);
allMRL = zeros(length(allSpans), length(freqList),scaloSamples*2);

for iSpan = 1:length(allSpans)
    scaloData = [];
    curSpans = allSpans{iSpan};
    if isempty(curSpans)
        if ~isempty(allScalograms)
            scaloSize = size(allScalograms);
            allScalograms(iSpan,:,:) = zeros(scaloSize(2:3));
        end
        continue; 
    end
    nScalograms = min(length(curSpans),300);
    
    scaloCount = 1;
    whileCount = 1;
    while scaloCount < nScalograms
        randSpanIdx = randi([1,size(curSpans,1)]);
        midSpan = mean(curSpans(randSpanIdx,:)) / 1000; % seconds
%         midSpan = curSpans(randSpanIdx,1) / 1000; % seconds
        sampleRange = [(round(midSpan * Fs) - windowSamples):(round(midSpan * Fs) + windowSamples)-1];
        if min(sampleRange) > 0 && max(sampleRange) < length(sevFilt)
            if max(abs(diff(sevFilt(sampleRange))).^2) < lfpThresh
                scaloData(:,scaloCount) = sevFilt(sampleRange);
                scaloCount = scaloCount + 1;
            else
                disp(['skipping ',num2str(randSpanIdx),' (lfp thresh)']);
            end
        end
        whileCount = whileCount + 1;
        if whileCount > 2000
            disp('exceeding while loop');
            break;
        end
    end
    [W, freqList] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'freqList',freqList,'doplot',false);
    allScalograms(iSpan,:,:) = squeeze(mean(abs(W(scaloSampleRange,:,:).^2),2))';
    Wangle = angle(W(scaloSampleRange,:,:));
    mrl = squeeze(mean(exp(1i*Wangle), 2));
    allMRL(iSpan,:,:) = mrl';

end