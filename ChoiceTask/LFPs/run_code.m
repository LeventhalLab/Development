close all
h = ff(600,800);
Fs = 1000;
T = 1/Fs;

for iNeuron = 200:numel(all_ts)
    ts = all_ts{iNeuron};
    disp(['FR = ',num2str(numel(ts)/ts(end),2)]);
    
    subplot(211);
    [s,binned] = spikeDensityEstimate(ts);
    [r,lags] = xcorr(logical(binned),2000,'coeff');
    sig = normalize(r(lags>0));
% %     s = eegfilt(sig,1000,0.5 30);
    plot(sig);
    xlim([0 1000]);
    ylim([0 1]);
    title(num2str(iNeuron));
    
    
    L = length(sig);
    t = (0:L-1)*T;
    subplot(212);
    Y = fft(sig);
    
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    plot(f,P1);
    xlim([0 30]);
    drawnow;
end