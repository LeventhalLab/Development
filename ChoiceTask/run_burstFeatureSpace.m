% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-rawdata/R0075_20150518a/R0075_20150518a/Unnamed_data_ch7.sev';
% [sev,header] = read_tdt_sev(sevFile);
% [b,a] = butter(4, [0.02 0.2]);
% fdata = filtfilt(b,a,double(sev));
% 
% nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/R0075_20150518a_T02_WL48_PL16_DT24.nex';
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

% [Wlfp,t,f,validBursts] = burstLFPAnalysis(sev,header.Fs,ts(burstEpochs(:,1))*header.Fs);
% [WlfpR,t,f,validBurstsR] = burstLFPAnalysis(sev,header.Fs,sort(randsample(ts,length(burstEpochs))*header.Fs));
% WlfpRAvg = squeeze(mean(WlfpR,1));
% WlfpRAvg = 10*log10(WlfpRAvg);

beforeBetaScalar = [];%zeros(length(burstEpochs),1);
duringBetaScalar = [];%zeros(length(burstEpochs),1);
beforeBeta = [];%zeros(length(burstEpochs),3);
duringBeta = [];%zeros(length(burstEpochs),3);

tBefore = t > -1.5 & t < -0.5;
tDuring = t >=0 & t < 0.5;
tAfter = t > 0.5 & t < 1;

beta = f > 35;%f >= 13 & f <30;
gamma = f > 35;

jj = 1;
for ii=1:length(burstEpochs)
    if ~validBursts(ii)
        continue;
    end
    spikesInBurst = burstEpochs(ii,2) - burstEpochs(ii,1) + 1;
    burstDuration = (ts(burstEpochs(ii,2)) - ts(burstEpochs(ii,1))); %sec
    burstFrequency = spikesInBurst / burstDuration; %spikes/sec
    
    beforeBeta(jj,:) = [spikesInBurst burstDuration burstFrequency];
    beforeBetaScalar(jj) = 10*log10(mean(mean(squeeze(Wlfp(jj,tBefore,beta))))) - 10*log10(mean(mean(WlfpRAvg(tBefore,beta))));
    
    duringBeta(jj,:) = [spikesInBurst burstDuration burstFrequency];
    duringBetaScalar(jj) = 10*log10(mean(mean(squeeze(Wlfp(jj,tDuring,beta))))) - 10*log10(mean(mean(WlfpRAvg(tDuring,beta))));
    jj = jj + 1;
end

[~,idx] = sort(beforeBetaScalar);

figure('position',[100 100 800 800]);
colormapscatter(beforeBeta(idx,1),beforeBeta(idx,2),beforeBeta(idx,3),jet(256),50);
xlabel('Spikes in Burst');
ylabel('Burst Duration (Sec)');
zlabel('Burst Frequency (Spikes/Sec)');
title('Before Beta');

[~,idx] = sort(duringBetaScalar);

figure('position',[100 100 800 800]);
colormapscatter(duringBeta(idx,1),duringBeta(idx,2),duringBeta(idx,3),jet(256),50);
xlabel('Spikes in Burst');
ylabel('Burst Duration (Sec)');
zlabel('Burst Frequency (Spikes/Sec)');
title('During Beta');
