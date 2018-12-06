doSetup = true;
zThresh = 5;
tWindow = 1;
freqList = {[1 4;4 8;13 30;30 70]};
Wlength = 400;

if doSetup
    trial_Wz_power = [];
    trial_Wz_phase = [];
    session_Wz_rayleigh_pval = [];
    compiledRTs = [];
    iSession = 0;
    trialCount = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        compiledRTs = [compiledRTs allTimes(keepTrials)];
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
        
        trialCount = trialCount + size(Wz_power,3);
        % iEvent, iTrial, iTime, iFreq
        if iSession == 1
            trial_Wz_power = Wz_power;
            trial_Wz_phase = Wz_phase;
        else
            trial_Wz_power(:,:,size(trial_Wz_power,3)+1:trialCount,:) = Wz_power;
            trial_Wz_phase(:,:,size(trial_Wz_phase,3)+1:trialCount,:) = Wz_phase;
        end
    end
end

data_source = {trial_Wz_power trial_Wz_phase};
[RTv,RTk] = sort(compiledRTs);
rows = size(trial_Wz_power,4);
useEvents = 1:7;
cols = numel(useEvents);
titleLabels = {'power','phase'};
cmaps = {'jet','parula'};
bandLabels = {'\delta','\theta','\beta','\gamma'};
caxisVals = {[-2 5],[-pi pi]};
for iCond = 1%1:2
    ff(1400,800);
    useData = data_source{iCond};
    for iEvent = useEvents
        for iFreq = 1:size(trial_Wz_power,4)
            subplot(rows,cols,prc(cols,[iFreq,iEvent]));
            thisData = squeeze(useData(iEvent,:,RTk,iFreq));
            imagesc(linspace(-tWindow,tWindow,size(thisData,1)),RTv,thisData');
            colormap(gca,cmaps{iCond});
            caxis(caxisVals{iCond});
            if iFreq == 1
                title({[eventFieldnames{iEvent},' - ',titleLabels{iCond}],bandLabels{iFreq}});
            else
                title(bandLabels{iFreq});
            end
            if iEvent == 1
                ylabel('RT (s)');
            else
                yticklabels([]);
            end
            if iFreq == size(trial_Wz_power,4)
                xticks([-tWindow,0,tWindow]);
                xlabel('Time (s)');
            else
                xticks([]);
            end
            grid on;
        end
    end
end