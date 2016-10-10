function [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(trials,trialIds,fieldname,ts,sev,Fs,fpass,tWindow)
decimateFactor = 100;
upperPrctile = 98;
% lowerPrctile = 15;

% if this is too close, it's likely that the same section of the lfp will
% have multiple peaks resulting in really similar spike trains in the
% raster
peakMinDist = 0.25; % seconds
% 
% [sev,header] = read_tdt_sev(sevFile);
Fs = Fs/decimateFactor;
sevFilt = decimate(double(sev),decimateFactor);
sevFilt = eegfilt(sevFilt,Fs,fpass(1),fpass(2));
x = hilbert(sevFilt);
instAmp = abs(x); % envelope

upperThresh = prctile(instAmp,upperPrctile);
[locs,pks] = peakseek(instAmp,Fs*peakMinDist,upperThresh);

locs = locs(pks<300); % artifacts
pks = pks(pks<300);

allLogEvent = [];
eventCount = 1;
% [] important to overlay more than one event time? multiple colors or
% subplots?
for iTrial=trialIds
    allLogEvent(eventCount) = getfield(trials(iTrial).timestamps,fieldname);
    eventCount = eventCount + 1;
end

rasterTs = {};
rasterEvents = {};
allTs = [];
allEvents = [];
for ii=1:length(locs)
    centerTs = locs(ii) / Fs;
    % should be only one unless spikeWindow >> trial length
    rasterEvents{ii} = allLogEvent(allLogEvent < centerTs + tWindow & allLogEvent >= centerTs - tWindow) - centerTs;
    rasterTs{ii,1} = ts(ts < centerTs + tWindow & ts >= centerTs - tWindow)' - centerTs;
    allEvents = [allEvents rasterEvents{ii}];
    allTs = [allTs rasterTs{ii,1}];
end

% stack high firing epochs on top 
% [~,I] = sort(cellfun('size',rasterTs,2),'descend');
% rasterTs = rasterTs(I);
% rasterEvents = rasterEvents(I);
% [t,idx] = sort([rasterEvents{1,:}]);
[pksSort,I] = sort(pks); % sort by lfp power
rasterTs = rasterTs(I);
rasterEvents = rasterEvents(I);

% figure;
% plotSpikeRaster(rasterTs,'PlotType','scatter','AutoLabel',true);
% title('Sorted by lfp power (high power = high trial #)');
% hold on;
% for ii=1:length(rasterEvents)
%     if ~isempty(rasterEvents{ii})
%         plot(rasterEvents{ii},ii,'o','Color','red');
%     end
% end
% 
% figure;
% hist(allTs,25);
% 
% figure;
% hist(allEvents,25);

% figure;
% plot(linspace(0,length(sevFilt)/Fs,length(sevFilt)),instAmp);
% hold on;
% plot(tts,zeros(1,length(tts)),'o');