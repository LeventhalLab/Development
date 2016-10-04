% function tsScaloXcorr(ts,sevFile)

% [ ] handle slow firing units like 20160504a T24

% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-rawdata/R0117_20160504a/R0117_20160504a/R0117_20160504a_R0117_20160504a-2_data_ch102.sev';
% [sev,header] = read_tdt_sev(sevFile);
ts = nexStruct.neurons{2,1}.timestamps;

decimateFactor = 10;
sevFilt = decimate(double(sev),decimateFactor);
sevFilt = artifactThresh(sevFilt,1,500);
Fs = header.Fs/decimateFactor;
[b,a] = butter(4,200/(Fs/2)); % low-pass 200Hz
sevFilt = filtfilt(b,a,sevFilt);
sevFilt = sevFilt - mean(sevFilt);

trialLength = length(sevFilt) / Fs; % seconds

upperPrctile = 90;
lowerPrctile = 10;
upperThresh = prctile(s,upperPrctile);
lowerThresh = prctile(s,lowerPrctile);

sigma = 0.05; % 50ms
[s,binned,kernel] = spikeDensityEstimate(ts,trialLength,sigma);
t = linspace(0,trialLength,length(s));

occurs = 1; % 50ms
spansUpper = findThreshSpans(s,upperThresh,occurs);
spansMiddle = findThreshSpans(s,[lowerThresh upperThresh],occurs);
spansLower = findThreshSpans(s,-lowerThresh,occurs);

window = 1; % s
windowSamples = round(Fs * window);

fpass = [10 100];
freqList = logFreqList(fpass,30);
% figure;
allSpans = {spansLower,spansMiddle,spansUpper};
for iSpan = 1:3
    A = [];
    scaloData = [];
    curSpans = allSpans{iSpan};
    for ii=1:size(curSpans,1)
        midSpan = mean(curSpans(ii,:)) / 1000; % seconds
        sampleRange = [(round(midSpan * Fs) - windowSamples):(round(midSpan * Fs) + windowSamples)-1];
        if min(sampleRange) > 0 && max(sampleRange) < length(sevFilt)
            scaloData(:,ii) = sevFilt(sampleRange);
%             [At,f] = simpleFFT(sevFilt(sampleRange),Fs);
%             A(ii,:) = At;
        end
    end
    [W, freqList] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'fpass',fpass,'freqList',freqList,'doplot',true);
    set(gca,'YScale','log');
    set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
%     Am = mean(A);
%     hold on;
%     semilogy(f,smooth(Am,round(Fs/1000)));
end
% legend('Lower','Middle','Upper');
% xlim([10 100]);
% xlabel('Frequency (Hz)');
% ylabel('|Y(f)|');