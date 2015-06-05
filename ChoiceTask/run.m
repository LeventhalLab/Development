% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-rawdata/R0075_20150518a/R0075_20150518a/Unnamed_data_ch1.sev';
% [sev,header] = read_tdt_sev(sevFile);
% 
% nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/Unnamed_data_ch1.sev.nex';
% tsCell = leventhalNexTs(nexFile);
% 
% ts = tsCell{1,2};
% [burstEpochs,burstFreqs] = findBursts(ts);
% burstIdx = burstEpochs(burstFreqs > 200,1);
% burstLocs = ts(burstIdx) * header.Fs;
% randomLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));

[WavgR,t,f] = burstLFPAnalysis(sev,header.Fs,randomLocs,1000,'Random Locs');
[WavgB,t,f] = burstLFPAnalysis(sev,header.Fs,burstLocs,1000,'Burst Locs');

figure('position',[100 100 400 800]);

subplot(131);
imagesc(t,f,WavgR');
axis xy; 
colorbar;
colormap(jet);
title('Random Spectrogram');
c = caxis;

subplot(132);
imagesc(t,f,WavgB');
axis xy; 
colorbar;
colormap(jet);
title('Burst Spectrogram');
caxis(c);

subplot(133);
imagesc(t,f,abs(WavgB-WavgR)');
axis xy; 
colorbar;
colormap(jet);
title('(Burst - Random) Spectrogram');