decimateFactor = 10;
data = sev(1:5e6)';
data = decimate(double(data),decimateFactor);
[W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',header.Fs/decimateFactor,'doplot',1);

t = [0:size(W,2)-1]./(header.Fs/decimateFactor);
figure; imagesc(t, freqList, log(squeeze(mean(abs(W).^2, 2))'));
ylabel('Frequency (Hz)')
xlabel('Time (s)');
set(gca, 'YDir', 'normal')