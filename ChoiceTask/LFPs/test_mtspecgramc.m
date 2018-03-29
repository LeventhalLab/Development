% % wt = cwt(data(:,1)',Fs,'FrequencyLimits',[1 100]);
iTrial = 10;
figuree(1200,800);
trialData = data(:,iTrial); % event 4
trialData = trialData - mean(trialData);

subplot(221);
plot(t,trialData);
xlabel('time (s)');
xticks([-tWindow 0 tWindow]);
ylabel('uV');
ylim([-500 500]);
title({'Raw Signal, Nose Out',['Subject ',subject__names{iSubject},', Trial ',num2str(iTrial)]});
grid on;

subplot(222);
simpleFFT(trialData',Fs,'newFig',false);
xlim([min(freqList) max(freqList)]);
title('FFT');
grid on;

% % subplot(223);
% % [wt,f,coi] = cwt(data(:,iTrial)',Fs);
% % imagesc(t,f,abs(wt).^2);
% % set(gca,'ydir','normal');
% % xlabel('time (s)');
% % xticks([-tWindow 0 tWindow]);
% % ylabel('freq (Hz)');
% % colormap jet;
% % colorbar;
% % title('MATLAB cwt()');
% % caxis([0 2500]);

subplot(223);
W = calculateComplexScalograms_EnMasse(trialData,'Fs',Fs,'freqList',freqList);
Wpower = squeeze(abs(W).^2)';
imagesc(t,freqList,Wpower);
set(gca,'ydir','normal');
xlabel('time (s)');
xticks([-tWindow 0 tWindow]);
ylabel('freq (Hz)');
colormap jet;
colorbar;
caxis([0 900]);
title('calculateComplexScalograms');

subplot(224);
W = calculateComplexScalograms_EnMasse(trialData,'Fs',Fs,'freqList',freqList);

imagesc(t,freqList,(Wpower-zMean)./zStd);
set(gca,'ydir','normal');
xlabel('time (s)');
xticks([-tWindow 0 tWindow]);
ylabel('freq (Hz)');
caxis([0 10]);
colormap jet;
colorbar;
title('Z calculateComplexScalograms');


set(gcf,'color','w');


if false
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
end