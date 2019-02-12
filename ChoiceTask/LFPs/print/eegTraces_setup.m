% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')
doSetup = false;
iNeuron = 133;
centerEvent = 4;
freqList = [2.5,20];
tWindow = 3;

if doSetup
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    trials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(trials,'RT');
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    sevFilt = artifactThresh(sevFilt,[1],2000);
    sevFilt = sevFilt - mean(sevFilt);
    [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    tsPeths = eventsPeth(trials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
end

trials_success = trials(trialIds);
for iTrial = 10:30%numel(trials_success)
    spikeTs = {tsPeths{iTrial,centerEvent}}';
    spikeTslabels = {num2str(iNeuron)};
    rawLFP = squeeze(all_data(centerEvent,:,iTrial));
    scaloLFP = squeeze(W(centerEvent,:,iTrial,:));
    freqA = 2;
    freqAlabels = {'\beta'};
    freqP = 1;
    freqPlabels = {'\delta'};
    eventTs = [];
    for iEvent = 1:numel(eventFieldnames)
        eventTs(iEvent) = getfield(trials_success(iTrial).timestamps,eventFieldnames{iEvent});
    end
    eventTs = eventTs - eventTs(centerEvent);
    eventLabels = eventFieldnames;
    eegTraces(spikeTs,spikeTslabels,rawLFP,scaloLFP,tWindow,freqA,freqAlabels,freqP,freqPlabels,eventTs,centerEvent,eventLabels);
end

% eegTraces(spikeTs,spikeTslabels,rawLFP,scaloLFP,freqA,freqAlabels,freqP,freqPlabels,tWindow,eventTs,eventLabels);