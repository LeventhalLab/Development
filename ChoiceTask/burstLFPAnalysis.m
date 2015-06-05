function burstLFPAnalysis(data,Fs,burstLocs)
spectHalfWindow = 2; % seconds
nDownsample = 10;
fpass = [5 80];
numfreqs = 50;

[b,a] = butter(2, 0.015); % 183Hz lowpass
data = filtfilt(b,a,double(data)); % filter both ways
data = downsample(data,nDownsample); % make smaller to run faster
Fs = Fs / nDownsample;
burstLocs = round(burstLocs / nDownsample);

% filename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/R0075_20150518a_T05_WL48_PL16_DT24-03-hs.nex';
% tsCell = leventhalNexTs(filename);
% ts = tsCell{1,2};
% [burstEpochs,burstFreqs] = findBursts(ts);
% burstIdx = burstEpochs(burstFreqs > 200,1);
% burstLocs = ts(burstIdx) * Fs;

spectHalfSamples = round(spectHalfWindow * Fs);

Wlfp = [];
burstCount = 1;
burstLocsSample = sort(datasample(burstLocs,min(length(burstLocs),10000),'Replace',false));
for ii=1:length(burstLocsSample)
    % skip if near beginning or end of recording
    if ~(burstLocsSample(ii) > spectHalfSamples * 2 || burstLocsSample(ii) > length(data) - spectHalfSamples * 2)
        continue;
    end
    % pad with Fs for processing (1 second)
    processRange = (burstLocsSample(ii) - spectHalfSamples + 1) - round(Fs):(burstLocsSample(ii) + spectHalfSamples) + round(Fs);
    %[W,freqList] = calculateComplexScalograms_EnMasse(data(processRange)','Fs',Fs,'fpass',fpass,'numfreqs',numfreqs);
    movingwin=[0.5 0.05];
    params.fpass = [0 80];
    params.tapers = [5 9];
    params.Fs = Fs;
    [S1,t,f] = mtspecgramc(data(processRange)',movingwin,params);
%     halfW = size(W,1) / 2;
%     lfpRange = halfW - spectHalfSamples + 1:halfW + spectHalfSamples;
%     Wlfp(burstCount,:,:) = W(lfpRange,1,:);
    Wlfp(burstCount,:,:) = S1(:,:);
    burstCount = burstCount + 1;
    
%     figure;
%     plot_matrix(S1,t,f);
%     colormap(jet);
%     caxis([0 60]);
    
    disp(num2str(max(processRange)/length(data)));
end

% Wavg = squeeze(abs(mean(Wlfp,1)).^2)';
% t = linspace(-spectHalfWindow,spectHalfWindow,size(Wavg,2));
% 
% figure;
% imagesc(t, freqList, log(Wavg));
% ylabel('Frequency (Hz)');
% xlabel('Time (s)');
% set(gca, 'YDir', 'normal');
% colormap(jet);
% caxis([0 7])

Wavg = squeeze(mean(Wlfp,1));
figure;
plot_matrix(Wavg,t,f);
colormap(jet);
caxis([0 60]);

disp('end');