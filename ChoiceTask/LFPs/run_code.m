% load('20190318_entrain.mat')
freqList = logFreqList([1 200],30);
nSurr = 200;

trialTime = 2;
pLess = [];
pThresh = 0.001;
for iFreq = 1:30
    these_ps = squeeze(entrain_pvals(1,trialTime,:,iFreq));
    pLess(iFreq) = sum(these_ps < pThresh) / 366;
end


these_rs = squeeze(entrain_rs(1,trialTime,:,:));
ff(900,500);
subplot(211);
plot(freqList,these_rs);
xticks([1 3 8 25 70 200]);
xlim([1 200]);
set(gca, 'XScale', 'log')
xlabel('Freq (Hz)');
ylabel('MRL');

subplot(212);
plot(freqList,pLess);
xticks([1 3 8 25 70 200]);
xlim([1 200]);
set(gca, 'XScale', 'log')
xlabel('Freq (Hz)');
ylabel(['p < ',num2str(pThresh,'%0.4d')]);