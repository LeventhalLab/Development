function burstLFPAnalysis(data,Fs)
nDownsample = 10;

[b,a] = butter(2, 0.015); % 183Hz lowpass
data = filtfilt(b,a,double(data)); % filter both ways
data = downsample(data,nDownsample); % make smaller to run faster
Fs = Fs / nDownsample;

[W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',[1 80],'numfreqs',100);
t = [0:size(W,1)]./Fs;
figure;
imagesc(t, freqList, squeeze(mean(abs(W).^2, 2))');
ylabel('Frequency (Hz)');
xlabel('Time (s)');
set(gca, 'YDir', 'normal');

figure;
imagesc(t, freqList, log(squeeze(mean(abs(W).^2, 2))'));
ylabel('Frequency (Hz)');
xlabel('Time (s)');
set(gca, 'YDir', 'normal');

disp('end');