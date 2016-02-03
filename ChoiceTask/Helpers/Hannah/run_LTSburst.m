% run burst, change paths
[sev,header] = ezSEV();
[n, ts] = nex_ts('/Users/hannahsoifer/Documents/Leventhal Lab/burst_assets/R0088_20151027a_T5_ch[33 35 37 39].nex', 'Channel01a');
[LTS, nonLTS]=extractLTS(ts);

[b, a] = butter(4, [.02, .5]);
fdata = filtfilt(b,a,double(sev));
figure;
plot(fdata(1:400000)/header.Fs)
hold on;
%plots the first spike of each burst
plot(ts(LTS(1:20,1)), zeros(1,20),'*');
hold on;
plot(ts(LTS(1:20,2)), zeros(1,20),'o');
legend('data','start', 'end');

