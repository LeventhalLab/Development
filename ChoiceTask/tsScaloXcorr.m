% function tsScaloXcorr(ts,sevFile)

sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch35.sev';
[sev,header] = read_tdt_sev(sevFile);
ts = nexStruct.neurons{2,1}.timestamps;

decimateFactor = 10;
sevFilt = decimate(double(sev),decimateFactor);
Fs = header.Fs/decimateFactor;
[b,a] = butter(4,200/(Fs/2)); % low-pass 200Hz
sevFilt = filtfilt(b,a,sevFilt);
sevFilt = sevFilt - mean(sevFilt);

trialLength = length(sevFilt) / Fs; % seconds

upperPrctile = 90;
lowerPrctile = 10;
upperThresh = prctile(s,upperPrctile);
lowerThresh = prctile(s(s>0),lowerPrctile);

sigma = 0.05; % 0.05 = 50ms
% sigma = round(mean(diff(ts)),3); % use mean ISI?
[s,binned,kernel] = spikeDensityEstimate(ts,trialLength,sigma);
t = linspace(0,trialLength,length(s));

occurs = 1; % 50 = 50ms, this is kind of redundant
spansUpper = findThreshSpans(s,upperThresh,occurs);
spansMiddle = findThreshSpans(s,[lowerThresh upperThresh],occurs);
spansLower = findThreshSpans(s,-lowerThresh,occurs);

window = 1; % s
windowSamples = round(Fs * window);

fpass = [10 100];
freqList = logFreqList(fpass,30);
allSpans = {spansLower,spansMiddle,spansUpper};
nScalograms = 100;
for iSpan = 1:1
    A = [];
    scaloData = [];
    curSpans = allSpans{iSpan};
    if isempty(curSpans) 
        continue; 
    end
    randSpanIdxs = randsample(1:min([size(curSpans,1),nScalograms]),min([size(curSpans,1),nScalograms]));
    for ii=1:49%length(randSpanIdxs)
        midSpan = mean(curSpans(randSpanIdxs(ii),:)) / 1000; % seconds
        midSpan = tSpans(ii);
        sampleRange = [(round(midSpan * Fs) - windowSamples):(round(midSpan * Fs) + windowSamples)-1];
        if min(sampleRange) > 0 && max(sampleRange) < length(sevFilt)
            scaloData(:,ii) = sevFilt(sampleRange);
            [W, freqList] = calculateComplexScalograms_EnMasse(scaloData(:,ii),'Fs',Fs,'fpass',fpass,'freqList',freqList,'doplot',true);
    set(gca,'YScale','log');
    set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
    colormap(jet);
    title(ii);
        end
        
    end
    
end