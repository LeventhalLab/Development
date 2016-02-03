% run burst, change paths
[sev,header] = ezSEV();
[n, ts] = nex_ts('/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-processed/R0088_20151027a/R0088_20151027a_T5_ch[33 35 37 39].nex', 'Channel01a');
[archive_burst_RS,archive_burst_length,archive_burst_start]=burst(ts);

%Get first 20 starting points
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
plot(fdata(1:500000)/header.Fs)
hold on;
plot(ts(rand_start(1:20)),zeros(1,20),'*');
hold on;
plot(ts(y),zeros(1,length(y)),'o');
legend('start', 'end')
