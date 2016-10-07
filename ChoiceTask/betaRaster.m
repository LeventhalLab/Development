ts = nexStruct.neurons{1,1}.timestamps;
if false
    tsBurst = [];
    tsLTS = [];
    burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
    if ~isempty(burstIdx) % ISI-based bursts and TLS bursts exist
        burstStartIdx = [1;diff(burstIdx)>1];
        tsBurst = ts(burstIdx(logical(burstStartIdx)));
        tsLTS = filterLTS(tsBurst);
    end
    [~,~,poissonIdx] = burst(ts);
    tsPoisson = [];
    if ~isempty(poissonIdx)
        tsPoisson = ts(poissonIdx);
    end
end

tts = tsBurst;
% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch35.sev';
decimateFactor = 100;
upperPrctile = 80;
lowerPrctile = 15;
spikeWindow = 0.5; %s

% [sev,header] = read_tdt_sev(sevFile);
% Fs = header.Fs/decimateFactor;
% sevFilt = decimate(double(sev),decimateFactor);
% sevFilt = eegfilt(sevFilt,Fs,13,30);

x = hilbert(sevFilt);
instAmp = abs(x); % envelope

upperThresh = prctile(instAmp,upperPrctile);
[locs,pks] = peakseek(instAmp,Fs/100,upperThresh);

locs = locs(pks<300); % artifacts

%       M x 1 cell of spike times:
%           M is the number of trials and each cell contains a 1 x N vector
%           of spike times. Units should be in seconds.
rasterTs = {}
allTs = [];
for ii=1:length(locs)
    centerTs = round(locs(ii) / Fs);
    rasterTs{ii,1} = tts(tts < centerTs + spikeWindow & tts >= centerTs - spikeWindow)' - centerTs;
    allTs = [allTs rasterTs{ii,1}];
end

figure;
plotSpikeRaster(rasterTs,'PlotType','vertline','AutoLabel',true);

figure;
hist(allTs,25);

% figure;
% plot(linspace(0,length(sevFilt)/Fs,length(sevFilt)),instAmp);
% hold on;
% plot(tts,zeros(1,length(tts)),'o');