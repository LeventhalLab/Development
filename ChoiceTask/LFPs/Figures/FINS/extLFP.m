if ~exist('selectedLFPFiles')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'all_trials')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
    load('LFPfiles_local_matt.mat')
end

doSetup = false;

tWindow = 8;
freqList = [2.5,20,55,90];
Wlength = 600;
% eventFieldnames_wFake = {eventFieldnames{:} 'interTrial'};
eventNames = {eventFieldnames{2:4}};
if doSetup
    Wz = zeros(numel(eventNames),Wlength,0,numel(freqList));
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        trials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        trials = curateTrials(trials(trialIds),sevFilt,Fs,'interTrial');
        
        W = eventsLFPv2(trials,sevFilt,tWindow*2,Fs,freqList,eventNames);
        Wz_power = zScoreW(W,Wlength); % power Z-score
        Wz(:,:,size(Wz,3)+1:size(Wz,3)+size(Wz_power,3),:) = Wz_power;
    end
end

colors = lines(numel(freqList));
pThresh = 0.05; % already corrected for multiple comp.
zThresh = abs(norminv(pThresh));
close all
lw = 2;
ms = 10;
ff(1200,900);
rows = numel(eventNames);
cols = 1;
eventNamesLabels = {'Nose In','Tone','Nose Out'};
lineNames = {'Delta','Beta','Low-gamma','High-gamma'};
ylimVals = [-3 10];
pStart = ylimVals(1) + 0.5;
pInt = 0.2;
adjZ = 4.5; % avoids using surrogate z-scores, which were calculated for +/-1s
for iEvent = 1:numel(eventNames)
    subplot(rows,cols,iEvent);
    t = linspace(-tWindow,tWindow,Wlength);
    lns = [];
    for iFreq = 1:numel(freqList)
        theseData = nanmean(Wz(iEvent,:,:,iFreq),3)*adjZ;
        lns(iFreq) = plot(t,theseData,'linewidth',lw,'color',colors(iFreq,:));
        hold on;
        sigIds = find(abs(theseData) > zThresh);
        y = repmat(pStart+(iFreq-1)*pInt,[numel(sigIds),1]);
        plot(t(sigIds),y,'.','markersize',ms,'color',colors(iFreq,:));
    end
    set(gca,'fontsize',14);
    xlabel('time (s)');
    ylabel('mean z-score');
    ylim(ylimVals);
    yticks([min(ylim),0,max(ylim)]);
    xticks([min(xlim),0,max(xlim)]);
    text(min(xlim)+0.25,min(ylim)+pInt*numel(freqList),sprintf('p < %1.2f',pThresh),'fontsize',14);
    title(eventNamesLabels{iEvent});
    legend(lns,lineNames);
    legend box off;
    grid on
end