doSetup = false;
if doSetup
    % load file
    fp = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0265_20190221_R0265_20190221-2_data_ch6.sev';
    [sev,header] = read_tdt_sev(fp);

    % setup timing
    ephysStart = 31;
    sleepRange = [36,54];
    t = linspace(0,numel(sev)/header.Fs/60,numel(sev)) + ephysStart;
    
    % set idxs
    startIdx = closest(t,sleepRange(1));
    endIdx = closest(t,sleepRange(2));

    % only use sleep time
    tSnip = t(startIdx:endIdx);
    data = double(sev(startIdx:endIdx));
    
    % filter SEV for spike detection
    [b,a] = butter(4, [0.02 0.5]); % high pass
    sevFilt = filtfilt(b,a,data);

    % detect spikes
    minpeakdist = 30;
    minpeakh = 150;
    [locs,~] = peakseek(-sevFilt,minpeakdist,minpeakh);

    % get scalogram
    freqList = [2.5,10,20,100,150];
    W = calculateComplexScalograms_EnMasse(data','Fs',header.Fs,'freqList',freqList);
    W = squeeze(W);
end

% plot
h = ff(600,500);
colors = lines(numel(freqList));
for iFreq = 1:numel(freqList)
    alpha = angle(W(locs,iFreq));
    r = circ_r(alpha);
    mu = circ_mean(alpha);
    polarplot([mu mu],[0 r],'lineWidth',3,'color',colors(iFreq,:));
    hold on;
    legendLabels{iFreq} = sprintf('%2.1f Hz',freqList(iFreq));
end
rlim([0 0.5]);
legend(legendLabels);
title('MRLs');