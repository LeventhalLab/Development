% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-rawdata/R0075_20150518a/R0075_20150518a/Unnamed_data_ch7.sev';
% [sev,header] = read_tdt_sev(sevFile);
% 
% nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/Unnamed_data_ch7.sev.nex';
% tsCell = leventhalNexTs(nexFile);
% 
% ts = tsCell{1,2};
[burstEpochs,burstFreqs] = findBursts(ts);
burstIdx = burstEpochs(burstFreqs > 200,1);
slowIdx = burstEpochs(burstFreqs < 200,1);
slowLocs = ts(slowIdx) * header.Fs;
burstLocs = ts(burstIdx) * header.Fs;
randomLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));

% figure;plot(burstLocs);hold on;plot(randomLocs);plot(slowLocs); %sanity
nLocs = 1000;

slowLocsSample = randsample(slowLocs,nLocs);
[WlfpR,t,f] = burstLFPAnalysis(sev,header.Fs,slowLocsSample);
WavgR = squeeze(mean(WlfpR,1));
WavgR = 10*log10(WavgR);



prependText = '20150518a Ch7 UnitA';
figure('position',[100 100 300 800]);

subplot(511);
imagesc(t,f,WavgR');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'Random'});
c = caxis;
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(512);
imagesc(t,f,WavgS');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'< 200Hz Burst'});
caxis(c);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(513);
imagesc(t,f,WavgB');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'> 200Hz Burst'});
caxis(c);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(514);
imagesc(t,f,(WavgS-WavgR)');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'(Slow Burst - Random)'});
caxis([-3  7]);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(515);
imagesc(t,f,(WavgB-WavgR)');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'(Fast Burst - Random)'});
caxis([-3  7]);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');