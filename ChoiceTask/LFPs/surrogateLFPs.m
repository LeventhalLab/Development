% from LFP_byX.m
saveTo = '/Volumes/Sabol2017/Gaidica';

if ~exist('all_trials')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local_alt')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
    load('session_20180919_NakamuraMRL.mat', 'all_trials')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
end
load('LFPfiles_local_matt');
freqList = logFreqList([1 200],30);
Wlength = 400;
tWindow = 1;

shiftSec = 2;
nSurr = 100;
iSession = 0;
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    trials = all_trials{iNeuron};
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    [trialIds,allTimes] = sortTrialsBy(trials,'RT');
    trials = curateTrials(trials(trialIds),sevFilt,Fs,[]);
    % calculate real
    [W,all_data] = eventsLFPv2(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames);
    W = W(:,round(linspace(size(W,1),size(W,2),Wlength)),:,:);
    save(fullfile(saveTo,sprintf('LFP_session%02d',iSession)),'W');
    for iSurr = 1:nSurr
        tic;
        [trials_surr,rShift] = shiftTimestamps(trials,shiftSec);
        [W,all_data] = eventsLFPv2(trials_surr,sevFilt,tWindow,Fs,freqList,eventFieldnames);
        W = W(:,round(linspace(size(W,1),size(W,2),Wlength)),:,:);
        save(fullfile(saveTo,sprintf('LFP_session%02d_surr%05d',iSession,iSurr)),'W');
        toc
    end
end