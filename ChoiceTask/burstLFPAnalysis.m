function [Wlfp,t,f,validBursts] = burstLFPAnalysis(data,Fs,burstLocs)
spectHalfWindow = 4; % seconds
nDownsample = 10;
fpass = [0 80];

[b,a] = butter(2, 0.015); % 183Hz lowpass
data = artifactThresh(data,1,500);
data = filtfilt(b,a,double(data)); % filter both ways
data = downsample(data,nDownsample); % make smaller to run faster
Fs = Fs / nDownsample;
burstLocs = round(burstLocs / nDownsample);

movingwin=[1 0.05];
params.fpass = fpass;
params.tapers = [3 5];
params.Fs = Fs;
params.trialave = 1;
params.err = 0;

spectHalfSamples = round(spectHalfWindow * Fs);

Wlfp = [];
burstCount = 1;
h = waitbar(0,['Processing ',num2str(burstCount-1),'/',num2str(length(burstLocs))]);
validBursts = zeros(length(burstLocs),1);
for ii=1:length(burstLocs)
    % skip if near beginning or end of recording
    if (burstLocs(ii) < spectHalfSamples * 2 || burstLocs(ii) > length(data) - spectHalfSamples * 2)
        disp(['Skipping burst location ',num2str(burstLocs(ii))]);
        validBursts(ii) = 0;
        continue;
    end
    % pad with Fs for processing (1 second)
    processRange = (burstLocs(ii) - spectHalfSamples + 1) - round(Fs):(burstLocs(ii) + spectHalfSamples) + round(Fs);
    
    [S1,t,f] = mtspecgramc(data(processRange)',movingwin,params);
    Wlfp(burstCount,:,:) = S1(:,:);
    validBursts(ii) = 1;
    burstCount = burstCount + 1;

    progress = max(processRange)/length(data);
    h = waitbar(progress,h,['Processing ',num2str(burstCount-1),'/',num2str(length(burstLocs))]);
end

close(h);
halfT = (max(t) - min(t)) / 2;
t = linspace(-halfT,halfT,size(t,2));


% disp('end');