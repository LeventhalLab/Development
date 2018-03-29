function [zMean,zStd,zFreqs] = zScoreScalogram(sevFilt,Fs,tWindow,freqList)

zFreqs = freqList;
nSamples = 500;
% generate surrogate trial times
tWindowSamples = round(tWindow * Fs);
data = [];
all_W = [];
iTrial = 1;
all_centerSample = [];
while iTrial < nSamples + 1
    centerSample = randsample(1+tWindowSamples:numel(sevFilt)-tWindowSamples,1);
    centerRangeSamples = (centerSample - tWindowSamples):(centerSample + tWindowSamples - 1);
    data(:,iTrial) = sevFilt(centerRangeSamples) - mean(sevFilt(centerRangeSamples)); % detrend
    if artifactFree(data(:,iTrial))
        all_W(iTrial,:,:) = calculateComplexScalograms_EnMasse(data(:,iTrial),'Fs',Fs,'freqList',freqList,'doplot',false);
        all_centerSample(iTrial) = centerSample;
        iTrial = iTrial + 1;
    else
        disp('zScoreScalogram: caught artifact!');
    end
end

all_Wpower = abs(all_W).^2;
zMean = squeeze(mean(all_Wpower,1))';
zStd = squeeze(std(all_Wpower,1))';

if true
    figuree(1200,400);
    subplot(131);
    imagesc(zMean);
    set(gca,'ydir','normal');
    colorbar;
    colormap jet;
    title('zMean');
    
    subplot(132);
    imagesc(zStd);
    set(gca,'ydir','normal');
    colorbar;
    colormap jet;
    title('zStd');
    
    subplot(133);
    histogram(all_centerSample);
    title(centerSamples);
end

function isFree = artifactFree(data)
artifactThresh = 200;
nSmooth = 40;
isFree = true;
if any(smooth(data,nSmooth) > artifactThresh)
    isFree = false;
end