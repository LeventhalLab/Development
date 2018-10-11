%%
figure(1)
eventList = peri_eventMetadata.eventList;
t = peri_eventMetadata.t;


hist_t = linspace(-1,1,size(LTShist,2));
max_t = zeros(1,length(eventList));

for ii = 1 : length(eventList)
    subplot(length(eventList),2,ii*2-1)
    hold off
    toPlot = mean(squeeze(periEventBeta(ii,:,:)));
    plot(t,toPlot)
    hold on
    plot(hist_t,LTShist(ii,:));
    set(gca,'ylim',[0 100]);
    
    LTS_hist_interp = interp1(hist_t,LTShist(ii,:),t);
    LTS_hist_interp = smooth(LTS_hist_interp,25);
    plot(t,LTS_hist_interp)
    
    subplot(length(eventList),2,ii*2)
    LTS_xcorr = xcorr(LTS_hist_interp,toPlot,'coeff');
    
    startSamp = round(length(t)/2);
    endSamp = startSamp + length(t)-1;
    LTS_xcorr = LTS_xcorr(startSamp:endSamp);

    plot(t,LTS_xcorr)
    set(gca,'xlim',[-.1,.1],'ylim',[0.4 1])
    max_t(ii) = t(LTS_xcorr == max(LTS_xcorr));
%     plot(LTS_hist_
end

max_t

% %%
% figure(2)
% t = peri_tsMetadata.t;
% plot(t,mean(periSpikeBeta))
