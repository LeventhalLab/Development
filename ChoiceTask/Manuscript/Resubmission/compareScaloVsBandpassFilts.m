load('/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16/R0142_20161201a_R0142_20161201a-1_data_ch8.sev.mat')
freqList = [4,55];
nSec = 10;
data = sevFilt(1:round(Fs)*nSec);

W = calculateComplexScalograms_EnMasse(data','Fs',Fs,'freqList',freqList);
bp = [];
bpp = [];
BPE = [1,5];
for iFreq = 1:2
    h = hilbert(eegfilt(data,Fs,freqList(iFreq)-BPE(iFreq),freqList(iFreq)+BPE(iFreq)));
    bp(:,iFreq) = abs(h);
    bpp(:,iFreq) = angle(h);
end

t = linspace(0,nSec,size(W,1));
colors = lines(10);
close all;
yLims = [50,50];
xLims = [0 10;5 6];
lns = [];
ff(1200,600);
for iFreq = 1:2
    subplot(2,2,prc(2,[iFreq,1]));
    yyaxis left;
    lns(1) = plot(t,data,'k');
    ylim([-500 1500]);
    yticks(sort([ylim,0]));
    set(gca,'ycolor','k');
    ylabel('unfiltered raw data (uV)');
    xlabel('time (s)');
    set(gca,'fontSize',14);

    yyaxis right;
    lns(2) = plot(t,abs(W(:,:,iFreq)),'-','color',colors(1,:));
    hold on;
    lns(3) = plot(t,bp(:,iFreq),'-','color',colors(2,:));
    xlim(xLims(iFreq,:));
    ylim([0 yLims(iFreq)]);
    yticks(ylim);
    set(gca,'ycolor','k');
    title(['filter freq: ',num2str(freqList(iFreq)),' Hz']);
    legend(lns,{'Raw Data','Wavelet','Band-pass'});
    ylabel('filtered amplitude');
    xlabel('time (s)');
    set(gca,'fontSize',14);
    
    subplot(2,2,prc(2,[iFreq,2]));
    yyaxis left;
    lns(1) = plot(t,data,'k');
    ylim([-500 1500]);
    yticks(sort([ylim,0]));
    set(gca,'ycolor','k');
    ylabel('unfiltered raw data (uV)');
    xlabel('time (s)');
    set(gca,'fontSize',14);

    yyaxis right;
    lns(2) = plot(t,angle(W(:,:,iFreq)),'-','color',colors(1,:));
    hold on;
    lns(3) = plot(t,bpp(:,iFreq),'-','color',colors(2,:));
    xlim(xLims(iFreq,:));
    ylim([-4 4]);
    yticks(sort([ylim,0]));
    set(gca,'ycolor','k');
    title(['filter freq: ',num2str(freqList(iFreq)),' Hz']);
    legend(lns,{'Raw Data','Wavelet','Band-pass'});
    ylabel('filtered phase');
    xlabel('time (s)');
    set(gca,'fontSize',14);
end