% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-rawdata/R0075_20150518a/R0075_20150518a/Unnamed_data_ch7.sev';
% [sev,header] = read_tdt_sev(sevFile);
% 
% nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/Unnamed_data_ch7.sev.nex';
% tsCell = leventhalNexTs(nexFile);
% 
% ts = tsCell{1,2};
% [burstEpochs,burstFreqs] = findBursts(ts);
% burstIdx = burstEpochs(burstFreqs > 200,1);
% burstLocs = ts(burstIdx) * header.Fs;
% randomLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));

% figure;plot(burstLocs);hold on;plot(randomLocs); %sanity

% [WavgR,t,f] = burstLFPAnalysis(sev,header.Fs,randomLocs,1000,'Random Locs');
% [WavgB,t,f] = burstLFPAnalysis(sev,header.Fs,burstLocs,1000,'Burst Locs');

prependText = '20150518a Ch7 UnitA';
figure('position',[100 100 400 800]);

subplot(311);
imagesc(t,f,WavgR');
axis xy; 
colorbar;
colormap(jet);
title([prependText,' - ','Random']);
c = caxis;
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(312);
imagesc(t,f,WavgB');
axis xy; 
colorbar;
colormap(jet);
title([prependText,' - ','Burst']);
caxis(c);
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');

subplot(313);
imagesc(t,f,(WavgB-WavgR)');
axis xy; 
colorbar;
colormap(jet);
title([prependText,' - ','(Burst - Random)']);
caxis auto;
xlim([-1 1]);
xlabel('time (s)');
ylabel('freq (Hz)');