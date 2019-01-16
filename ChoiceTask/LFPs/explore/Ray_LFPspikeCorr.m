% need to build arrays of:
% (1) norm. trial LFPs
% (2) norm. unit firing
% (3) unit-lfp lookup table
% where, (1) has one entry per session,
% (2) has multiple entries per session,
% (3) implies (1)->has_many->(2)
% for each event? only excited units?
% close all;
doSetup = true;

doCompile = true;
doPlot = true;
doSave = true;

if false
    if doSetup
        load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'LFPfiles_local')
        load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_ts')
        load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_trials')
    end
    if doCompile
        load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
        load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'eventFieldnames')
        load('Ray_LFPspikeCorr_setup.mat')
    end
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
    all_FR = [];
    iSession = 0;
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        disp(iNeuron);
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
            iSession = iSession + 1;
            [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
            curTrials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
            % must use tWindow*2 because Wz returns half window
            [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow*2,Fs,freqList,eventFieldnames);
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            [Wz_power,Wz_phase] = zScoreW(W,Wlength,tWindow); % power Z-score
            all_Wz_power{iSession} = Wz_power;
        end
        LFP_lookup(iNeuron) = iSession; % find LFP in all_Wz_power
        all_keepTrials{iNeuron} = keepTrials;
        tsPeths = eventsPeth(curTrials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
        tsPeths = tsPeths(keepTrials,:);
        
        all_FR(iNeuron) = numel([tsPeths{:,1}])/size(tsPeths,1);

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

% [ ] restrict by FR/SDE flatness
% [ ] try xcorr for comparison
% [ ] re-implement whole-session corr
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/xcorrRayMethod';
doDirSel = 1;
nMs = 500;
startIdx = round(Wlength/2) - round(nMs/2) + 1;
LFP_range = startIdx:startIdx + nMs - 1;

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
useUnits = [12,174,186,188,212];

for iNeuron = 133%useUnits
    [~,~,unitTrials,~] = cellfun(@size,all_Wz_power(LFP_lookup(iNeuron)));
    for iTrial = 1:unitTrials
        if doCompile
            lag_pval = [];
            lag_rho = [];
            for iFreq = 1:numel(freqList)
                disp(['Correlating ',num2str(freqList(iFreq),'%2.1f'),' Hz...']);
                for iEvent = 1:7
                    disp(['  -> ',eventFieldnames{iEvent}]);
% %                     Y = NaN(sum(unitTrials)*nMs,1);
                    Y = NaN(nMs,1);
                    Yind = 1;
                    A = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,LFP_range,iTrial,iFreq));
                    Y(Yind:Yind+numel(A)-1) = reshape(A',[numel(A) 1]);
                    Yind = Yind+numel(A);

                    % [ ] this is frequency independent (i.e., redundant!)
                    for iLag = 1:nMs+1
                        X = NaN(size(Y));
                        FR_range = LFP_range + (iLag - round(nMs/2)) - 1;
                        Xind = 1;
                        A = squeeze(all_zSDE{iNeuron}(iTrial,iEvent,FR_range));
                        X(Xind:Xind+numel(A)-1) = reshape(A',[numel(A) 1]);
                        Xind = Xind+numel(A);

                        [rho,pval] = corr(X,Y,'Type','Spearman');
                        lag_pval(iLag,iEvent,iFreq) = pval;
                        lag_rho(iLag,iEvent,iFreq) = rho;
                    end
                end
            end
        end

        if doPlot
            h = ff(1400,800);
            left_color = [0 0 0];
            right_color = [1 0 0];
            set(h,'defaultAxesColorOrder',[left_color; right_color]);
            rows = 3;
            cols = 7;
            useData = {lag_rho,lag_pval};
            useColormap = {'jet','hot'};
            useCaxis = [-1 1;0 0.05];
            useLabels = {'rho','pval'};
            t = linspace(-tWindow*1000,tWindow*1000,size(all_zSDE{1},3));
            tLag = linspace(-round(nMs/2),round(nMs/2),size(lag_rho,1));
            lagLines = [min(tLag) min(tLag)];
            ySDE = [-3 3];
            yLFP = [-6 6];

            for iRow = 1:2
                for iEvent = 1:7
                    subplot(rows,cols,prc(cols,[iRow,iEvent]));
                    imagesc(tLag,1:numel(freqList),squeeze(useData{iRow}(:,iEvent,:))');
                    set(gca,'ydir','normal');
                    xticks([min(xlim) round(mean(xlim)) max(xlim)]);
                    xticklabels([min(tLag) 0 max(tLag)]);
                    xlabel('spike lag (ms)');
                    yticks(linspace(min(ylim),max(ylim),numel(freqList)));
                    yticklabels(compose('%3.1f',freqList));
                    colormap(gca,useColormap{iRow});
                    caxis(useCaxis(iRow,:));
                    if iRow == 1
                        if iEvent == 1
                            title({['u',num2str(iNeuron,'%03d')],eventFieldnames{iEvent},'xcorr'});
                        else
                            title({eventFieldnames{iEvent},'xcorr'});
                        end
                    end
                    if iEvent == 1
                        ylabel('Freq (Hz)');
                    end
                    if iEvent == 7
                        cbAside(gca,useLabels{iRow},'k');
                    end
                end
            end
            for iEvent = 1:7
                subplot(rows,cols,prc(cols,[3,iEvent]));

                yyaxis left;
                A = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,:,iTrial,:));
                imagesc(t,1:numel(freqList),A');
                set(gca,'ydir','normal');
                colormap(gca,jet);
                caxis(yLFP);
                yticks(linspace(min(ylim),max(ylim),numel(freqList)));
                yticklabels(compose('%3.1f',freqList));
                if iEvent == 1
                    ylabel('Freq (Hz)');
                end

                yyaxis right;
                plot(t,squeeze(all_zSDE{iNeuron}(iTrial,iEvent,:)),'lineWidth',2);
                ylim(ySDE);
                yticks(sort([0 ylim]));
                if iEvent == 7
                    ylabel('SDE (Z)');
                end

                hold on;
                plot(-lagLines,ylim,'k:');
                plot(lagLines,ylim,'k:');
                plot([0,0],ylim,'k-');

                xlabel('time (ms)');
                title('LFP');
            end

            set(gcf,'color','w');
            if doSave
                saveas(h,fullfile(savePath,['u',num2str(iNeuron,'%03d'),'_t',num2str(iTrial,'%03d'),'_xcorrRayMethod.png']));
                close(h);
            end
        end
    end
end