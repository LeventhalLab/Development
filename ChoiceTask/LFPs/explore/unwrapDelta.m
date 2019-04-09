doSetup = false;

if ~exist('selectedLFPFiles')
    load('session_20181106_entrainmentData.mat', 'selectedLFPFiles');
    load('session_20181106_entrainmentData.mat', 'eventFieldnames');
    load('session_20181106_entrainmentData.mat', 'LFPfiles_local');
    load('session_20181106_entrainmentData.mat', 'all_trials');
end

eventFieldnames_wFake = {eventFieldnames{:} 'interTrial'};
tWindow = 1;
zThresh = 5;
xlimVals = [-1 1];
nSmooth = 200;
freqList = 2.5;

if doSetup
    for iSession = 30 % 30 -> u344-366, dir: 348,349,356,357,361,363,364
        iNeuron = selectedLFPFiles(iSession);
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        trials = all_trials{iNeuron};
        trials = addEventToTrials(trials,'interTrial');
        
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames_wFake);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        all_data = all_data(:,:,keepTrials);
        allTimes = allTimes(keepTrials);
    end
end

close all
h = ff(1400,300);
rows = 1;
cols = 8;
t = linspace(-tWindow,tWindow,size(all_data,2)-1);
for iEvent = 1:8
    dataArr = [];
    subplot(rows,cols,iEvent);
    for iTrial = 1:size(W,3)
        data = unwrap(angle(squeeze(W(iEvent,:,iTrial))));
        dataArr(iTrial,:) = abs(diff(data));
    end
    plot(t,median(dataArr),'r-','linewidth',2);
    ylim([0.0098 0.0108]);
    yticks(ylim);
    xticks(sort([xlim,0]));
    title(eventFieldnames_wFake{iEvent});
end
set(gcf,'color','w');