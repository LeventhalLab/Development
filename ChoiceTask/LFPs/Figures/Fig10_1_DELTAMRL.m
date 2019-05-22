% DELTAMRL
if ~exist('data_source')
    load('20190416_DELTAMRL.mat')
end
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.02 .03];

doSetup = false;
doSave = true;
doLabels = false;

freqList = 2.5;
zThresh = 5;
tWindow = 1;
Wlength = 400;
midId = round(Wlength/2);
eventFieldnames_wFake = {eventFieldnames{:} 'interTrial'};

if doSetup
    nSurr = 2;
    allMids = [];
    for iSurr = 1:nSurr
        trial_Wz_phase = [];
        trialCount = 0;
        iSession = 0;
        for iNeuron = selectedLFPFiles'
            iSession = iSession + 1;
            disp(iSession);
            sevFile = LFPfiles_local{iNeuron};
            trials = all_trials{iNeuron};
            trials = addEventToTrials(trials,'interTrial');
            [trialIds,allTimes] = sortTrialsBy(trials,'RT');
            [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
            sevFilt = artifactThresh(sevFilt,[1],2000);
            sevFilt = sevFilt - mean(sevFilt);

            [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow*2,Fs,freqList,{eventFieldnames_wFake{8}});
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
            
            trialCount = trialCount + size(Wz_power,3);
            % iEvent, iTrial, iTime, iFreq
            if iSession == 1
                trial_Wz_phase = Wz_phase;
            else
                trial_Wz_phase(:,:,size(trial_Wz_phase,3)+1:trialCount,:) = Wz_phase;
            end
        end
        allMids(iSurr) = circ_r(squeeze(trial_Wz_phase(1,midId,:)));
    end
end

[RTv,RTk] = sort(compiledRTs);

iCond = 2;
iFreq = 1;
allMRLs = [];
for iEvent = 1:7
    useData = data_source{iCond};
    thisData = squeeze(useData(iEvent,:,RTk,iFreq));
    allMRLs(iEvent) = circ_r(thisData(midId,:)');
end

close all
h = ff(500,300);
bar(allMRLs,'k');
hold on
% % plot(xlim,[min(allMids) min(allMids)],'r-');
lns = plot(xlim,[max(allMids) max(allMids)],'r-');
ylim([0 0.6]);
yticks(ylim);

if doLabels
    for iEvent = 1:numel(allMRLs)
        text(iEvent,allMRLs(iEvent)+0.05,num2str(allMRLs(iEvent),2),'horizontalAlignment','center');
    end
    xticklabels(eventFieldnames_wFake);
    xtickangle(30);
    ylabel('MRL');
    title('MRL at t = 0');
else
    xticks([]);
    xticklabels([]);
    yticklabels([]);
end

tightfig;
set(gcf,'color','w');
if doSave
    setFig('','',[1,1]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'DELTAMRL.eps'));
    close(h);
end