savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP/allTrials';
doSave =  true;

doSetup = false;
tWindow = 3;
Wlength = 400;

if doSetup
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
        
        [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow,Fs,freqList,{eventFieldnames_wFake{1}});
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        
% % % %         [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
% % % %         
        trialCount = trialCount + size(W,3);
        % iEvent, iTrial, iTime, iFreq
        if iSession == 1
            trial_Wz_phase = angle(W);
        else
            trial_Wz_phase(:,:,size(trial_Wz_phase,3)+1:trialCount,:) = angle(W);
        end
    end
end

close all
t = linspace(-tWindow,tWindow,size(trial_Wz_phase,2));
allMRLs = [];
for iTime = 1:size(trial_Wz_phase,2)
    allMRLs(iTime) = circ_r(squeeze(trial_Wz_phase(1,iTime,:)));
end
h = ff(400,300);
plot(t,allMRLs);
hold on;
plot(xlim,[min(allMids) min(allMids)],'r-');
lns = plot(xlim,[max(allMids) max(allMids)],'r-');
xlabel('time (s)');
ylim([0 0.15]);
yticks(ylim);
ylabel('MRL');
title('\delta (2.5 Hz) MRL at t = 0, Cue');
legend(lns,{'chance (n = 20)'});
set(gcf,'color','w');

if doSave
    saveas(h,fullfile(savePath,['deltaMRLatCue_tWindow3s.png']));
    close(h);
end