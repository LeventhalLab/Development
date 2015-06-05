% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-rawdata/R0075_20150518a/R0075_20150518a/Unnamed_data_ch7.sev';
% [sev,header] = read_tdt_sev(sevFile);
% [b,a] = butter(4, [0.02 0.2]);
% fdata = filtfilt(b,a,double(sev));
% 
% nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/Unnamed_data_ch7.sev.nex';
% tsCell = leventhalNexTs(nexFile);
% 
% ts = tsCell{1,2};
% [burstEpochs,burstFreqs] = findBursts(ts);

% burstIdx = burstEpochs(burstFreqs > 200,1);
% slowIdx = burstEpochs(burstFreqs < 200,1);
% slowLocs = ts(slowIdx) * header.Fs;
% burstLocs = ts(burstIdx) * header.Fs;
% randomLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));

%make sure bursts actually exist
% figure;
% hold on;
% for ii=1:500
%     plot(fdata(header.Fs*ts(burstEpochs(ii,1)):header.Fs*ts(burstEpochs(ii,2))));
% end

[WlfpR,t,f] = burstLFPAnalysis(sev,header.Fs,ts(burstEpochs(:,1))*header.Fs);

cmap = zeros(length(burstEpochs),3);
burstFeatures = zeros(length(burstEpochs),3);

for ii=1:length(burstEpochs)
    spikesInBurst = burstEpochs(ii,2) - burstEpochs(ii,1) + 1;
    burstDuration = (ts(burstEpochs(ii,2)) - ts(burstEpochs(ii,1))); %sec
    burstFrequency = spikesInBurst / burstDuration; %spikes/sec
    burstFeatures(ii,:) = [spikesInBurst burstDuration burstFrequency];
    cmap(ii,:) = [.5 .5 .5];
end

figure('position',[100 100 800 800]);
colormapscatter(burstFeatures(:,1),burstFeatures(:,2),burstFeatures(:,3),cmap,100);
xlabel('Spikes in Burst');
ylabel('Burst Duration (Sec)');
zlabel('Burst Frequency (Spikes/Sec)');
