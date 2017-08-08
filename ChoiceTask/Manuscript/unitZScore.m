function [zscore] = unitZScore(trials,ts,tWindow,eventFieldnames,trialTypes)
binMs = 50; % ms
nBins = round((2*tWindow / .001) / binMs);
nBinHalfWidth = ((tWindow*2) / nBins) / 2;
nBins_tWindow = linspace(-tWindow+nBinHalfWidth,tWindow-nBinHalfWidth,nBins);

zscore = zeros(numel(eventFieldnames),size(nBins_tWindow,2));

% assumes trials is all trialTypes
trialIdInfo = organizeTrialsById(trials);

useTrials = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
tsPeths = eventsPeth(trials(useTrials),ts,tWindow,eventFieldnames);

ts_event1 = [tsPeths{:,1}];
[counts_events1,centers_event1] = hist(ts_event1,nBins_tWindow);

% skip if no counts, can't determine mean/std
if counts_events1 == 0
    error('Not enough spikes 1');
else
    zMean = mean(counts_events1 / size(tsPeths,1));
    zStd = std(counts_events1 / size(tsPeths,1));
end

% now get tsPeths for only trialTypes
useTrials = [];
for iTrialTypes = 1:numel(trialTypes)
    useTrials = [useTrials getfield(trialIdInfo,trialTypes{iTrialTypes})];
end
tsPeths = eventsPeth(trials(useTrials),ts,tWindow,eventFieldnames);
if isempty(tsPeths)
    error('Not enough spikes 2');
end
zscore = [];
zscore_filt = [];
for iEvent = 1:numel(eventFieldnames)
    ts_eventX = [tsPeths{:,iEvent}];
    [counts_eventsX,centers_eventX] = hist(ts_eventX,nBins_tWindow);
%         zscore(iEvent,:) = ((counts_eventsX / size(tsPeths,1)) - mean(allCounts)) / std(allCounts); % old method
    % just set z=0 if not using events; works for now
    zscore(iEvent,:) = ((counts_eventsX / size(tsPeths,1)) - zMean) / zStd;
end