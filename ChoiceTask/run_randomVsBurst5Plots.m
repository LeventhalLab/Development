% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0089/R0089-rawdata/R0089_20151004a/R0089_20151004a/R0089_20151004_R0089_20151004-1_data_ch48.sev';
% [sev,header] = read_tdt_sev(sevFile);
% 
% nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0089/R0089-processed/R0089_20151004a/R0089_20151004a_T08_WL48_PL16_DT24.nex';
% tsCell = leventhalNexTs(nexFile);
% 
% ts = tsCell{1,2};
% [burstEpochs,burstFreqs] = findBursts(ts);

% burstFreq = 200;
% burstIdx = burstEpochs(burstFreqs >= burstFreq,1);
% slowIdx = burstEpochs(burstFreqs < burstFreq,1);
% slowLocs = ts(slowIdx) * header.Fs;
% burstLocs = ts(burstIdx) * header.Fs;
% randomLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));

burstIdx = burstEpochs(:,1);
burstLocs  = ts(burstIdx) * header.Fs;
randomNospikeLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));
randomSpikeLocs = sort(datasample(ts,length(burstLocs),'Replace',false)) * header.Fs;


figure;plot(burstLocs);hold on;plot(randomNospikeLocs);plot(randomSpikeLocs); %sanity
legend('burstLocs','randomNospike','randomSpike')

nLocs = 400;

% slowLocsSample = sort(randsample(slowLocs,nLocs));
% [WlfpS,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,slowLocsSample);
% WavgS = 10*log10(squeeze(mean(WlfpS,1)));
% 
% randomNospikeLocsSample = sort(randsample(randomNospikeLocs,nLocs));
% [WlfprandomNospikeLocs,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,randomNospikeLocsSample);
% WavgrandomNospikeLocsSample = 10*log10(squeeze(mean(WlfprandomNospikeLocs,1)));
% 
% randomSpikeLocsSample = sort(randsample(randomSpikeLocs,nLocs));
% [WlfprandomSpikeLocs,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,randomSpikeLocsSample);
% WavgrandomSpikeLocsSample = 10*log10(squeeze(mean(WlfprandomSpikeLocs,1)));
% 
% burstLocsSample = sort(randsample(burstLocs,nLocs));
% [Wlfpbursts,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,burstLocsSample);
% WavgburstLocsSample = 10*log10(squeeze(mean(Wlfpbursts,1)));

prependText = '20151007a';
figure('position',[100 100 300 800]);

subplot(511);
imagesc(t,f,WavgrandomNospikeLocsSample');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'Random No Spike'});
c = caxis;
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(512);
imagesc(t,f,WavgrandomSpikeLocsSample');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'Random Spike'});
caxis(c);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(513);
imagesc(t,f,WavgburstLocsSample');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'Bursts'});
caxis(c);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(514);
imagesc(t,f,(WavgburstLocsSample-WavgrandomNospikeLocsSample)');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'(Burst - Random No Spike)'});
caxis([-3  7]);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(515);
imagesc(t,f,(WavgburstLocsSample-WavgrandomSpikeLocsSample)');
axis xy; 
colorbar;
colormap(jet);
title({prependText,'(Burst - Random Spike)'});
caxis([-3  7]);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');