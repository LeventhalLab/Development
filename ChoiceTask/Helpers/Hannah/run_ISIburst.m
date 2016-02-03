% run burst, change paths
[sev,header] = ezSEV();
[n, ts] = nex_ts('/Users/hannahsoifer/Documents/Leventhal Lab/burst_assets/R0088_20151027a_T5_ch[33 35 37 39].nex', 'Channel01a');
xBursts = [0.0035 0.010 0.0200]; % experimentally determined
[burstEpochs,burstFreqs] = findBursts(ts,xBursts);

[b, a] = butter(4, [.02, .5]);
fdata = filtfilt(b,a,double(sev));
figure;
plot(fdata(1:500000)/header.Fs)
hold on;
plot(ts(burstEpochs(1:200, 1)),zeros(1,200),'o');
hold on;
plot(ts(burstEpochs(1:200,2)),zeros(1,200),'*');
legend('data', 'start', 'end')
