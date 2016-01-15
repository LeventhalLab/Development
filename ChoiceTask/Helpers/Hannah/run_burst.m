% run burst, change paths
[sev,header] = ezSEV();
[n, ts] = nex_ts('/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-processed/R0088_20151027a/R0088_20151027a_T5_ch[33 35 37 39].nex', 'Channel01c');
[archive_burst_RS,archive_burst_length,archive_burst_start]=burst(ts);

[b, a] = butter(4, [.02, .5]);
fdata = filtfilt(b,a,double(sev));
figure;
plot(fdata(1:5e6));
hold on;
plot(ts(archive_burst_start(1:100))*header.Fs,zeros(1,100),'o');