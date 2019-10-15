% load('/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16/R0088_20151030_R0088_20151030-1_data_ch38.sev.mat')
freqList = [4,55];
nSec = 10;
data = sevFilt(1:round(Fs)*nSec);

W = calculateComplexScalograms_EnMasse(data','Fs',Fs,'freqList',freqList);
bp = [];
BPE = [1,5];
for iFreq = 1:2
    h = hilbert(eegfilt(data,Fs,freqList(iFreq)-BPE(iFreq),freqList(iFreq)+BPE(iFreq)));
    bp(:,iFreq) = angle(h);
end

t = linspace(0,nSec,size(W,1));
colors = lines(10);
close all;
yLims = [200,70];
lns = [];
ff(1100,600);
for iFreq = 1:2
    subplot(2,1,iFreq);
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
    lns(3) = plot(t,bp(:,iFreq),'-','color',colors(2,:));
    xlim([0 nSec]);
    ylim([-4 4]);
    yticks(sort([ylim,0]));
    set(gca,'ycolor','k');
    title(['filter freq: ',num2str(freqList(iFreq)),' Hz']);
    legend(lns,{'Raw Data','Complex Scalogram','Band-pass Filter'});
    ylabel('filtered phase');
    xlabel('time (s)');
    set(gca,'fontSize',14);
end