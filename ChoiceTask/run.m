sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-rawdata/R0075_20150518a/R0075_20150518a/Unnamed_data_ch1.sev';
[sev,header] = read_tdt_sev(sevFile);

nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/Unnamed_data_ch1.sev.nex';
tsCell = leventhalNexTs(nexFile);

ts = tsCell{1,2};
[burstEpochs,burstFreqs] = findBursts(ts);
burstIdx = burstEpochs(burstFreqs > 200,1);
burstLocs = ts(burstIdx) * header.Fs;
randomLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));

[WavgR,t,f] = burstLFPAnalysis(sev,header.Fs,randomLocs,1000,'Random Locs');
[WavgB,t,f] = burstLFPAnalysis(sev,header.Fs,burstLocs,100,'Burst Locs');

figure;
plot_matrix(abs(WavgB-WavgR),t,f);
caxis auto;
colormap(jet);