% run burst, change paths
[sev,header] = ezSEV();
[n, ts] = nex_ts('/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-processed/R0088_20151027a/R0088_20151027a_T5_ch[33 35 37 39].nex', 'Channel01c');
[archive_burst_RS,archive_burst_length,archive_burst_start]=burst(ts);
rand_start = archive_burst_start(1:20);

%Get timestamps for rest of burst
y = [];
for ii = 1:20
    for jj = 1:archive_burst_length(ii)-1
        y = [y rand_start(ii)+jj];
    end
end
[b, a] = butter(4, [.02, .5]);
fdata = filtfilt(b,a,double(sev));
figure;
plot(fdata(1:1000000))
hold on;
plot(ts(y(1:length(y)))*header.Fs,zeros(1,length(y)),'o');
hold on;
plot(ts(rand_start(1:20))*header.Fs,zeros(1,20),'*');
