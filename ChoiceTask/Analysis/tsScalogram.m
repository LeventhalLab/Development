function [allScalograms,nScalograms] = tsScalogram(ts,sevFilt,tWindow,Fs,fpass,freqList)
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
spansUpper = findThreshSpans(s,upperThresh,occurs);
spansMiddle = findThreshSpans(s,[lowerThresh upperThresh],occurs);
spansLower = findThreshSpans(s,-lowerThresh,occurs);

windowSamples = round(Fs * tWindow);

allSpans = {spansLower,spansMiddle,spansUpper};
nScalograms = 100;
disp(['Averaging ',num2str(nScalograms),' scalograms']);
for iSpan = 1:3
    scaloData = [];
    curSpans = allSpans{iSpan};
    if isempty(curSpans) 
        continue; 
    end
    if size(curSpans,1) < nScalograms
        disp('not enough spans, reduce nScalograms');
    end
    
    scaloCount = 1;
    % if nScalograms >> curSpans or lfp thresh this takes forever
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
    end
    [W, freqList] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'fpass',fpass,'freqList',freqList,'doplot',false);
    allScalograms(iSpan,:,:) = squeeze(mean(abs(W).^2,2))';
end