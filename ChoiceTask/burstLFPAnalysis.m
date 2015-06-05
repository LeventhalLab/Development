function [Wlfp,t,f,validBursts] = burstLFPAnalysis(data,Fs,burstLocs)
spectHalfWindow = 1; % seconds
nDownsample = 10;
fpass = [5 80];

[b,a] = butter(2, 0.015); % 183Hz lowpass
data = filtfilt(b,a,double(data)); % filter both ways
data = downsample(data,nDownsample); % make smaller to run faster
Fs = Fs / nDownsample;
burstLocs = round(burstLocs / nDownsample);

movingwin=[0.5 0.05];
params.fpass = fpass;
params.tapers = [5 9];
params.Fs = Fs;

spectHalfSamples = round(spectHalfWindow * Fs);

Wlfp = [];
burstCount = 1;
h = waitbar(0,'Processing...');
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
    h = waitbar(progress,h,'Processing...');
end

close(h);
halfT = (max(t) - min(t)) / 2;
t = linspace(-halfT,halfT,size(t,2));


% disp('end');