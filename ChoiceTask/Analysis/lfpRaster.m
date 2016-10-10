function [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(ts,sevFile)
%[ ] pass in or retrieve event times from trial structure
% ts = nexStruct.neurons{4,1}.timestamps;
% if false
%     tsBurst = [];
%     tsLTS = [];
%     burstIdx = find(diff(ts) > 0 & diff(ts) <= maxBurstISI);
%     if ~isempty(burstIdx) % ISI-based bursts and TLS bursts exist
%         burstStartIdx = [1;diff(burstIdx)>1];
%         tsBurst = ts(burstIdx(logical(burstStartIdx)));
%         tsLTS = filterLTS(tsBurst);
%     end
%     [~,~,poissonIdx] = burst(ts);
%     tsPoisson = [];
%     if ~isempty(poissonIdx)
%         tsPoisson = ts(poissonIdx);
%     end
% end

% tts = ts;
% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch34.sev';
decimateFactor = 100;
upperPrctile = 98;
% lowerPrctile = 15;
spikeWindow = 5; %s
% if this is too close, it's likely that the same section of the lfp will
% have multiple peaks resulting in really similar spike trains in the
% raster
peakMinDist = 0.25; % seconds
% 
[sev,header] = read_tdt_sev(sevFile);
Fs = header.Fs/decimateFactor;
sevFilt = decimate(double(sev),decimateFactor);
sevFilt = eegfilt(sevFilt,Fs,13,30);

x = hilbert(sevFilt);
instAmp = abs(x); % envelope

upperThresh = prctile(instAmp,upperPrctile);
[locs,pks] = peakseek(instAmp,Fs*peakMinDist,upperThresh);

locs = locs(pks<300); % artifacts
pks = pks(pks<300);

allLogEvent = [];
correctTrials = find([trials.correct]==1);
eventCount = 1;
for iTrial=correctTrials
    allLogEvent(eventCount) = trials(iTrial).timestamps.centerOut;
    eventCount = eventCount + 1;
end

rasterTs = {};
rasterEvents = {};
allTs = [];
allEvents = [];
for ii=1:length(locs)
    centerTs = locs(ii) / Fs;
    % should be only one unless spikeWindow >> trial length
    rasterEvents{ii} = allLogEvent(allLogEvent < centerTs + spikeWindow & allLogEvent >= centerTs - spikeWindow) - centerTs;
    rasterTs{ii,1} = ts(ts < centerTs + spikeWindow & ts >= centerTs - spikeWindow)' - centerTs;
    allEvents = [allEvents rasterEvents{ii}];
    allTs = [allTs rasterTs{ii,1}];
end

% stack high firing epochs on top 
% [~,I] = sort(cellfun('size',rasterTs,2),'descend');
% rasterTs = rasterTs(I);
% rasterEvents = rasterEvents(I);
% [t,idx] = sort([rasterEvents{1,:}]);
[pksSort,I] = sort(pks);
rasterTs = rasterTs(I);
rasterEvents = rasterEvents(I);

figure;
plotSpikeRaster(rasterTs,'PlotType','scatter','AutoLabel',true);
title('Sorted by lfp power (high power = high trial #)');
hold on;
for ii=1:length(rasterEvents)
    if ~isempty(rasterEvents{ii})
        plot(rasterEvents{ii},ii,'o','Color','red');
    end
end

figure;
hist(allTs,25);

figure;
hist(allEvents,25);

% figure;
% plot(linspace(0,length(sevFilt)/Fs,length(sevFilt)),instAmp);
% hold on;
% plot(tts,zeros(1,length(tts)),'o');