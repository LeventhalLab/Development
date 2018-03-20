% % wt = cwt(data(:,1)',Fs,'FrequencyLimits',[1 100]);

all_wt = [];
for iTrial = 1:size(data,2)
    [wt,f,coi] = cwt(data(:,iTrial)',Fs);
    all_wt(iTrial,:,:) = abs(wt).^2;
end
avg_wt = squeeze(mean(all_wt,1));
figure;
imagesc(t,f,avg_wt);
        
set(gca,'ydir','normal');
colormap jet;

helperCWTTimeFreqPlot(avg_wt,t,f,'surf','CWT','Seconds','Hz');
ylim([1 100]);

calculateComplexScalograms_EnMasse(data,'Fs',Fs,'doplot',true);


% % [S,F,T] = spectrogram(data(:,1)',100,98,128,fs);
% % helperCWTTimeFreqPlot(S,T,F,'surf','STFT of Quadratic Chirp','Seconds','Hz')
% % 
movingwin = [0.5 0.05];
params.Fs = Fs;
params.fpass = [1 1000];
params.tapers = [3 5];
params.trialave = 1;
params.err = 0;
[S1,t,f] = mtspecgramc(data(:,1),movingwin,params);
figure;
plot_matrix(S1,t,f);
colormap jet;
colorbar;