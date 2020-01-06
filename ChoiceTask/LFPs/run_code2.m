op% load('session_20191014_spikePhaseResubmit')
% load('analysisConf');
freqList = logFreqList([1 2000],30);

% all_spikeHist_inTrial_pvals 366x30
% all_spikeHist_inTrial_rs

subjects = {'R0088','R0117','R0142','R0154','R0182'};
subjectSessions = [1 4;5 11;12 24;25 29;30 30];

[a,b,c] = unique(analysisConf.sessionNames);
b = [b;366+1];

colors = parula(30);
close all;
ff(900,500);
for iSession = 1:30
    plot(freqList,nanmean(all_spikeHist_inTrial_rs(b(iSession):b(iSession+1)-1,:),1),...
        'color',colors(iSession,:));
    hold on;
end

plot(freqList,nanmean(all_spikeHist_inTrial_rs,1),...
        'color','k','lineWidth',3);
    
    plot(freqList,all_spikeHist_inTrial_rs(121,:),'color','k','lineWidth',3);
    
legend('location','eastoutside')
xticks([1 3 8 25 70 200 2000]);
xlim([1 2000]);
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
xlabel('Freq (Hz)');
ylabel('MRL');