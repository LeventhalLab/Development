% run burst, change paths
[sev,header] = ezSEV();
[n, ts] = nex_ts('/Users/hannahsoifer/Documents/Leventhal Lab/burst_assets/R0088_20151027a_T5_ch[33 35 37 39].nex', 'Channel01a');
[LTS, nonLTS]=extractLTS(ts);

[b, a] = butter(4, [.02, .5]);
fdata = filtfilt(b,a,double(sev));
figure;
plot(fdata)
hold on;
%plots the first spike of each burst
plot(ts(LTS(:,1))*header.Fs, zeros(1,length(LTS)),'*');
hold on;
plot(ts(LTS(:,2))*header.Fs, zeros(1,length(LTS)),'o');
hold on;
plot(ts(nonLTS(:,1))*header.Fs, zeros(1, length(nonLTS)), '+');
legend('data','start', 'end', 'non LTS spike start');

