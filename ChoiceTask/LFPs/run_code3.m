% session 16: R0142_20161208a
% neurons 120-134, 122 is representative
iNeuron = 122;
% to test: original file (no alt), despiked files
% sp_noAlt = {all_spikeHist_inTrial_rs,all_spikeHist_rs};
% sp_yesAlt = {all_spikeHist_inTrial_rs,all_spikeHist_rs};
% sp_despike = {all_spikeHist_inTrial_rs,all_spikeHist_rs};
% sp_10xdec = {all_spikeHist_inTrial_rs,all_spikeHist_rs};

ff(600,600);
titles = {'IN trial','OUT trial'};
for ii = 1:2
    subplot(2,1,ii);
    plot(freqList,sp_noAlt{ii}(iNeuron,:),'color','k','lineWidth',3);
    hold on;
    plot(freqList,sp_yesAlt{ii}(iNeuron,:),'color','r','lineWidth',3);
    plot(freqList,sp_yesAlt{ii}(iNeuron,:),'color','g','lineWidth',1);
    plot(freqList,sp_despike{ii}(iNeuron,:),'color','b','lineWidth',3);
    title(titles{ii});
    legend({'same wire','alt wire','alt fs','same despiked'},'location','eastoutside')
    xticks([1 3 8 25 70 200 2000]);
    xlim([1 2000]);
    set(gca, 'XScale', 'log')
    set(gca, 'YScale', 'log')
    xlabel('Freq (Hz)');
    ylabel('MRL');
end