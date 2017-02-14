function [meanScalo, stdScalo, log_meanScalo, log_stdScalo] = meanScalogram(sevFilt,tWindow,scaloWindow,Fs,freqList,num_iterations)

lfpThresh = 0.5e6; % diff uV^2, *this depends on decimate factor, need to generalize it

endTs = length(sevFilt) / Fs; % seconds


rand_t_range = endTs - range(tWindow);
% randTimes = (randTimes * rand_t_range) - tWindow(1);

windowSamples = round(Fs * tWindow);
scaloSamples = round(Fs * scaloWindow);
scaloSampleRange = (windowSamples - scaloSamples) : (windowSamples + scaloSamples) - 1;

scaloCount = 0;
allScalo = NaN(num_iterations, length(freqList), scaloSamples * 2);
while scaloCount <= num_iterations
    
    rand_t = (rand() * rand_t_range) - tWindow(1);
    midSpan = round(rand_t * Fs);
    sampleRange = midSpan - windowSamples : midSpan + windowSamples;
    
    if min(sampleRange) > 0 && max(sampleRange) < length(sevFilt)
        if max(abs(diff(sevFilt(sampleRange))).^2) < lfpThresh
            scaloData = sevFilt(sampleRange);
            scaloCount = scaloCount + 1;
        else
            disp(['redoing ',num2str(scaloCount),' (lfp thresh)']);
        end
    end
    
    [W, freqList] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'freqList',freqList,'doplot',false);
    W = squeeze(W);
    allScalo(scaloCount,:,:) = squeeze(abs(W(scaloSampleRange,:).^2))';
end
    
meanScalo = squeeze(mean(allScalo,1));
log_meanScalo = squeeze(mean(log10(allScalo),1));
log_stdScalo = squeeze(std(log10(allScalo),0,1));
stdScalo = squeeze(std(allScalo,0,1));
    