SDE = all_SDEs_zscore{1,1}{1,4};
SDE2 = all_SDEs_zscore{1,1}{2,4};
figure;
subplot(211);
plot(SDE);
hold on;
plot(SDE2);

[r,lags] = xcorr(SDE,SDE2);
subplot(212);
plot(lags,r);