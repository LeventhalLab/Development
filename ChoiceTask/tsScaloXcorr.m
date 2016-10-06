% function tsScaloXcorr(ts,sevFile)
% basically need to change ts in spikeDensityEstimate for different types
% of bursts

decimateFactor = 50;
upperPrctile = 90;
lowerPrctile = 10;
lfpThresh = 0.5e6; % diff uV^2, *this depends on decimate factor, need to generalize it
freqList = logFreqList(fpass,30);

sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch35.sev';
[sev,header] = read_tdt_sev(sevFile);
ts = nexStruct.neurons{2,1}.timestamps;

sevFilt = decimate(double(sev),decimateFactor);
Fs = header.Fs/decimateFactor;
[b,a] = butter(4,200/(Fs/2)); % low-pass 200Hz
sevFilt = filtfilt(b,a,sevFilt);
sevFilt = sevFilt - mean(sevFilt);

trialLength = length(sevFilt) / Fs; % seconds

% sigma = 0.05; % 0.05 = 50ms
sigma = round(mean(diff(ts)),3); % use mean ISI?
[s,binned,kernel] = spikeDensityEstimate(ts,trialLength,sigma);
t = linspace(0,trialLength,length(s));

upperThresh = prctile(s,upperPrctile);
lowerThresh = prctile(s(s>0),lowerPrctile);

occurs = 1; % 50 = 50ms, this is kind of redundant
spansUpper = findThreshSpans(s,upperThresh,occurs);
spansMiddle = findThreshSpans(s,[lowerThresh upperThresh],occurs);
spansLower = findThreshSpans(s,-lowerThresh,occurs);

window = 1; % s
windowSamples = round(Fs * window);

fpass = [10 100];
allSpans = {spansLower,spansMiddle,spansUpper};
nScalograms = 1000;
for iSpan = 1:3
    A = [];
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
    [W, freqList] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'fpass',fpass,'freqList',freqList,'doplot',true);
    set(gca,'YScale','log');
    set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
    colormap(jet);
end