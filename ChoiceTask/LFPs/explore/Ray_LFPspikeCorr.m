% need to build arrays of:
% (1) norm. trial LFPs
% (2) norm. unit firing
% (3) unit-lfp lookup table
% where, (1) has one entry per session,
% (2) has multiple entries per session,
% (3) implies (1)->has_many->(2)
% for each event? only excited units?
doSetup = false;
doCompile = true;
doPlot = true;

if true
    % if doSetup
%     load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'LFPfiles_local')
%     load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_ts')
%     load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_trials')
    % if doCompile
    load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
    load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'eventFieldnames')
    load('Ray_LFPspikeCorr_setup.mat')
end

freqList = logFreqList([1 200],30);
Wlength = 1000;
tWindow = 0.5;
loadedFile = [];
zThresh = 5;
minFR = 5;

if doSetup
    all_Wz_power = {};
    all_zSDE = {};
    all_keepTrials = {};
    LFP_lookup = [];
    iSession = 0;
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        disp(iNeuron);
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
            iSession = iSession + 1;
            [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
            curTrials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
            [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            [Wz_power,Wz_phase] = zScoreW(W,Wlength,tWindow); % power Z-score
            all_Wz_power{iSession} = Wz_power;
        end
        LFP_lookup(iNeuron) = iSession; % find LFP in all_Wz_power
        all_keepTrials{iNeuron} = keepTrials;
        tsPeths = eventsPeth(curTrials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
        tsPeths = tsPeths(keepTrials,:);
        
        FR = numel([tsPeths{:,1}])/size(tsPeths,1);
        if FR < minFR
            disp('FR too low');
            all_zSDE{iNeuron} = [];
            continue;
        end

        SDE = [];
        for iTrial = 1:size(tsPeths,1)
            for iEvent = 1:size(tsPeths,2)
                ts = tsPeths{iTrial,iEvent};
                SDE(iTrial,iEvent,:) = spikeDensityEstimate_periEvent(ts,tWindow);
            end
        end
        zMean = mean(mean(SDE(:,1,:)));
        zStd = mean(std(SDE(:,1,:),[],3));
        zSDE = (SDE - zMean) ./ zStd;
        all_zSDE{iNeuron} = zSDE;
    end
    save('Ray_LFPspikeCorr_setup','all_Wz_power','all_zSDE','LFP_lookup','all_keepTrials');
end


% % % % % TEMP FIX
% % loadedFile = [];
% % t = {};
% % u = [];
% % iSession = 0;
% % for iNeuron = 1:numel(all_ts)
% %     sevFile = LFPfiles_local{iNeuron};
% %     if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
% %         loadedFile = sevFile;
% %         iSession = iSession + 1;
% %         t{iSession} = all_Wz_power{iNeuron};
% %     end
% %     u(iNeuron) = iSession; % find LFP in all_Wz_power
% % end
% % all_Wz_power = t;
% % LFP_lookup = u;
% % clear t;
% % clear u;


if doCompile
    % [ ] how to easily filter by unit?
    doDirSel = -1;
    nMs = 200;
    startIdx = round(Wlength/2)+1;
    notEmptyUnits = find(~cellfun(@isempty,all_zSDE) == 1);
    if doDirSel == 1
        disp('dirSel units');
        useUnits = dirSelUnitIds(ismember(dirSelUnitIds,notEmptyUnits));
    elseif doDirSel == -1
        disp('ndirSel units');
        useUnits = ndirSelUnitIds(ismember(ndirSelUnitIds,notEmptyUnits));
    else
        disp('all units');
        useUnits = notEmptyUnits;
    end

    lag_pval = [];
    lag_rho = [];
    for iFreq = 1:numel(freqList)
        disp(['Correlating ',num2str(freqList(iFreq),'%2.1f'),' Hz...']);
        for iEvent = 1:7
            disp(['  -> ',eventFieldnames{iEvent}]);
            [~,~,unitTrials,~] = cellfun(@size,all_Wz_power(LFP_lookup(useUnits)));
            Y = NaN(sum(unitTrials)*nMs,1);
            LFP_range = startIdx:startIdx + nMs - 1;
            Yind = 1;
            for iNeuron = useUnits
                A = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,LFP_range,:,iFreq));
                Y(Yind:Yind+numel(A)-1) = reshape(A',[numel(A) 1]);
                Yind = Yind+numel(A);
            end
            for iLag = 1:nMs+1
                X = NaN(size(Y));
                FR_range = LFP_range + (iLag - round(nMs/2));
                Xind = 1;
                for iNeuron = useUnits
                    A = squeeze(all_zSDE{iNeuron}(:,iEvent,FR_range));
                    X(Xind:Xind+numel(A)-1) = reshape(A',[numel(A) 1]);
                    Xind = Xind+numel(A);
                end
                [rho,pval] = corr(X,Y);
                lag_pval(iLag,iEvent,iFreq) = pval;
                lag_rho(iLag,iEvent,iFreq) = rho;
            end
        end
    end
end

if doPlot
    h = ff(1400,800);
    rows = 2;
    cols = 7;
    useData = {lag_rho,lag_pval};
    useColormap = {'jet','hot'};
    useCaxis = [-0.03 0.03;0 0.05];
    useLabels = {'rho','pval'};
    for iRow = 1:2
        for iEvent = 1:7
            subplot(rows,cols,prc(cols,[iRow,iEvent]));
            imagesc(squeeze(useData{iRow}(:,iEvent,:))');
            set(gca,'ydir','normal');
            xticks([min(xlim) round(mean(xlim)) max(xlim)]);
            xticklabels({'-100','0','100'});
            xlabel('Lag (ms)');
            yticks(linspace(min(ylim),max(ylim),numel(freqList)));
            yticklabels(compose('%3.1f',freqList));
            colormap(gca,useColormap{iRow});
            caxis(useCaxis(iRow,:));
            title({eventFieldnames{iEvent},'xcorr'});
            if iEvent == 1
                ylabel('Freq (Hz)');
            end
            if iEvent == 7
                cbAside(gca,useLabels{iRow},'k');
            end
        end
    end
    set(gcf,'color','w');
end