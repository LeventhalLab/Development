function [Wavg,t,f] = burstLFPAnalysis(data,Fs,burstLocs,nAvg,titleText)
spectHalfWindow = 1; % seconds
nDownsample = 10;
fpass = [5 80];
numfreqs = 25;

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
burstLocsSample = sort(datasample(burstLocs,min(length(burstLocs),nAvg),'Replace',false));
h = waitbar(0,'Processing...');
for ii=1:length(burstLocsSample)
    % skip if near beginning or end of recording
    if (burstLocsSample(ii) < spectHalfSamples * 2 || burstLocsSample(ii) > length(data) - spectHalfSamples * 2)
        disp(['Skipping burst location ',num2str(burstLocsSample(ii))]);
        continue;
    end
    % pad with Fs for processing (1 second)
    processRange = (burstLocsSample(ii) - spectHalfSamples + 1) - round(Fs):(burstLocsSample(ii) + spectHalfSamples) + round(Fs);
    %[W,freqList] = calculateComplexScalograms_EnMasse(data(processRange)','Fs',Fs,'fpass',fpass,'numfreqs',numfreqs);
    
    [S1,t,f] = mtspecgramc(data(processRange)',movingwin,params);
%     halfW = size(W,1) / 2;
%     lfpRange = halfW - spectHalfSamples + 1:halfW + spectHalfSamples;
%     Wlfp(burstCount,:,:) = W(lfpRange,1,:);
    Wlfp(burstCount,:,:) = S1(:,:);
    burstCount = burstCount + 1;
    
%     figure;
%     plot_matrix(S1,t,f);
%     colormap(jet);
%     caxis([0 60]);
    progress = max(processRange)/length(data);
%     disp(num2str(progress));
    h = waitbar(progress,h,'Processing...');
end

close(h);

% Wavg = squeeze(abs(mean(Wlfp,1)).^2)';
% t = linspace(-spectHalfWindow,spectHalfWindow,size(Wavg,2));
% 
% figure;
% imagesc(t, freqList, log(Wavg));
% ylabel('Frequency (Hz)');
% xlabel('Time (s)');
% set(gca, 'YDir', 'normal');
% colormap(jet);
% caxis([0 7])

Wavg = squeeze(mean(Wlfp,1));
Wavg = 10*log10(Wavg);
halfT = (max(t) - min(t)) / 2;
t = linspace(-halfT,halfT,size(t,2));

% figure;
% imagesc(t,f,Wavg');
% axis xy; 
% colorbar;
% title(titleText);
% colormap(jet);
% caxis([0 60]);
% xlim([-spectHalfWindow spectHalfWindow]);

% disp('end');