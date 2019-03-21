% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local_altLookup')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')

doSetup = true;
doPlot = true;
doAlt = true;
doWrite = true;

freqList = logFreqList([1 200],30);
loadedFile = [];
minFR = 5;
maxTrialTime = 20; % seconds
tXcorr = 0.5; % seconds
inLabels = {'in-trial','inter-trial'};

if doSetup
    xcorrUnits = [];
    all_acors_median = [];
    all_acors_mean = [];
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        disp(['--> iNeuron ',num2str(iNeuron)]);
        ts = all_ts{iNeuron};
        FR = numel(ts) / max(ts);
        if FR < minFR
            disp(['skipping at ',num2str(FR,2),' Hz']);
            continue;
        end
        xcorrUnits = [xcorrUnits iNeuron];
        % replace with alternative for LFP
        if doAlt
            sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
        end
        % only load unique sessions
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
            [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
            trials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(trials,'RT');
            intrialTimeRanges = compileTrialTimeRanges(trials(trialIds),maxTrialTime);
            [intrialSamples,intertrialSamples] = findIntertrialTimeRanges(intrialTimeRanges,Fs);
            
            disp('Calculating W...');
            W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);
            W = abs(squeeze(W)).^2; % power
            Wz = NaN(size(W));
            for iFreq = 1:size(W,2)
                Wz(:,iFreq) = (W(:,iFreq) - mean(W(:,iFreq))) ./  std(W(:,iFreq));
            end
            clear W;
        end
        SDE = equalVectors(spikeDensityEstimate(ts,numel(sevFilt)/Fs),size(Wz,1))';
        SDEz = (SDE - mean(SDE)) ./ std(SDE);
        useSamples = {intrialSamples,intertrialSamples};
        acors = [];%NaN(2,size(intrialSamples,1),size(Wz,2));
        for iIn = 1:2
            for iTrial = 1:size(intrialSamples,1)
                X = squeeze(SDEz(useSamples{iIn}(iTrial,1):useSamples{iIn}(iTrial,2)));
                for iFreq = 1:size(Wz,2)
                    Y = squeeze(Wz(useSamples{iIn}(iTrial,1):useSamples{iIn}(iTrial,2),iFreq));
                    [acor,lag] = xcorr(X,Y,round(tXcorr*Fs),'coeff');
                    acors(iIn,iTrial,iFreq,:) = acor;
                end
            end
        end
        for iIn = 1:2
            all_acors_median(iNeuron,iIn,:,:) = squeeze(median(acors(iIn,iTrial,:,:),2));
            all_acors_mean(iNeuron,iIn,:,:) = squeeze(mean(acors(iIn,iTrial,:,:),2));
        end
    end
end

if doPlot
    condUnits = {1:366,ndirSelUnitIds,dirSelUnitIds};
    condLabels = {'allUnits','ndirSel','dirSel'};
    h = ff(500,800);
    rows = 3;
    cols = 2;
    for iIn = 1:2
        for iDir = 1:3
            subplot(rows,cols,prc(cols,[iDir,iIn]));
            useUnits = xcorrUnits(ismember(xcorrUnits,condUnits{iDir}));
            data = squeeze(median(all_acors_median(useUnits,iIn,:,:)));
            imagesc(lag,1:numel(freqList),data);
            hold on;
            plot([0,0],ylim,'k:');
            set(gca,'ydir','normal');
            xlabel('spike lag (ms)');
            yticks(linspace(min(ylim),max(ylim),numel(freqList)));
            yticklabels(compose('%3.1f',freqList));
            colormap(gca,jet);
            caxis([-0.2,0.2]);
            title({inLabels{iIn},condLabels{iDir}});
        end
    end
end
