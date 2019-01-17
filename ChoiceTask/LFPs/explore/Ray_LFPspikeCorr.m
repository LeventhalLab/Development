% need to build arrays of:
% (1) norm. trial LFPs
% (2) norm. unit firing
% (3) unit-lfp lookup table
% where, (1) has one entry per session,
% (2) has multiple entries per session,
% (3) implies (1)->has_many->(2)
% for each event? only excited units?
% close all;
doSetup = false;

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
            [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
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
    save('Ray_LFPspikeCorr_setup','all_Wz_power','all_zSDE','LFP_lookup','all_keepTrials','all_FR');
end

% [ ] try xcorr for comparison
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/xcorrRayMethod';
doDirSel = 1;
nMs = 500;
minFR = 10;
startIdx = round(Wlength/2) - round(nMs/2) + 1;
LFP_range = startIdx:startIdx + nMs - 1;

FRunits = find(all_FR > minFR);
if doDirSel == 1
    disp('dirSel units');
    useUnits = dirSelUnitIds(ismember(dirSelUnitIds,FRunits));
elseif doDirSel == -1
    disp('ndirSel units');
    useUnits = ndirSelUnitIds(ismember(ndirSelUnitIds,FRunits));
else
    disp('all units');
    useUnits = FRunits;
end
% useUnits = useUnits(1:10);
[~,~,unitTrials,~] = cellfun(@size,all_Wz_power(LFP_lookup(useUnits)));

if doCompile
    lag_pval = NaN(nMs,7,numel(freqList));
    lag_rho = NaN(size(lag_pval));
    acors = NaN(sum(unitTrials),7,numel(freqList),nMs*2+1);
    for iFreq = 1:numel(freqList)
        disp(['Correlating ',num2str(freqList(iFreq),'%2.1f'),' Hz...']);
        for iEvent = 1:7
            disp(['  -> ',eventFieldnames{iEvent}]);
            % xcorr method
            neuronCount = 0;
            unitTrialCount = 0;
            for iNeuron = useUnits
                neuronCount = neuronCount + 1;
                for iTrial = 1:unitTrials(neuronCount)
                    unitTrialCount = unitTrialCount + 1;
                    Y = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,:,iTrial,iFreq));
                    X = squeeze(all_zSDE{iNeuron}(iTrial,iEvent,:))';
                    [acor,lag] = xcorr(X,Y,nMs);
                    acors(unitTrialCount,iEvent,iFreq,:) = acor;
                end
            end
            
% %             Y = NaN(sum(unitTrials)*nMs,1);
% %             Yind = 1;
% %             for iNeuron = useUnits
% %                 A = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,LFP_range,:,iFreq));
% %                 Y(Yind:Yind+numel(A)-1) = reshape(A',[numel(A) 1]);
% %                 Yind = Yind+numel(A);
% %             end
% %             % [ ] frequency independent, could remove it from the iFreq loop
% %             for iLag = 1:nMs
% %                 X = NaN(size(Y));
% %                 FR_range = LFP_range + (iLag - round(nMs/2)) - 1;
% %                 Xind = 1;
% %                 for iNeuron = useUnits
% %                     A = squeeze(all_zSDE{iNeuron}(:,iEvent,FR_range));
% %                     X(Xind:Xind+numel(A)-1) = reshape(A',[numel(A) 1]);
% %                     Xind = Xind+numel(A);
% %                 end
% %                 [rho,pval] = corr(X,Y);
% %                 lag_pval(iLag,iEvent,iFreq) = pval;
% %                 lag_rho(iLag,iEvent,iFreq) = rho;
% %             end
        end
    end
    disp('Done compiling.');
    save('session_20190116_Ray_ABlags_ndirSel','A','B','acors','lag');
end

if doPlot
    close all;
    A = NaN(numel(useUnits),7,size(all_Wz_power{LFP_lookup(iNeuron)},2),numel(freqList));
    B = NaN(numel(useUnits),7,size(all_Wz_power{LFP_lookup(iNeuron)},2));
    for iEvent = 1:7
        neuronCount = 0;
        for iNeuron = useUnits
            neuronCount = neuronCount + 1;
            A(neuronCount,iEvent,:,:) = squeeze(mean(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,:,:,:),3));
            B(neuronCount,iEvent,:) = squeeze(mean(all_zSDE{iNeuron}(:,iEvent,:),1));
        end
    end
    
    h = ff(1400,800);
    rows = 2;
    cols = 7;
    useData = {lag_rho,lag_pval};
    useColormap = {'jupiter','hot'};
% %     useCaxis = [-0.1,0.1;0 0.05];
    useCaxis = [-500 1500;0 0.05];
    useLabels = {'rho','pval'};
    t = linspace(-tWindow*1000,tWindow*1000,size(all_zSDE{1},3));
    tLag = linspace(-round(nMs/2),round(nMs/2),size(lag_rho,1));
    lagLines = [min(tLag) min(tLag)];
    ySDE = [-3 3];
    yLFP = [-6 6];
    iRow = 1;
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        imagesc(lag,1:numel(freqList),squeeze(mean(acors(:,iEvent,:,:))));
        set(gca,'ydir','normal');
% %         xticks([min(xlim) round(mean(xlim)) max(xlim)]);
% %         xticklabels([min(tLag) 0 max(tLag)]);
        xlabel('spike lag (ms)');
        yticks(linspace(min(ylim),max(ylim),numel(freqList)));
        yticklabels(compose('%3.1f',freqList));
        colormap(gca,useColormap{iRow});
        caxis(useCaxis(iRow,:));
        title(eventFieldnames{iEvent});
        if iEvent == 1
            ylabel('Freq (Hz)');
        end
        if iEvent == 7
            cbAside(gca,useLabels{iRow},'k');
        end
    end

% %     for iRow = 1:2
% %         for iEvent = 1:7
% %             subplot(rows,cols,prc(cols,[iRow,iEvent]));
% %             imagesc(squeeze(useData{iRow}(:,iEvent,:))');
% %             set(gca,'ydir','normal');
% %             xticks([min(xlim) round(mean(xlim)) max(xlim)]);
% %             xticklabels([min(tLag) 0 max(tLag)]);
% %             xlabel('spike lag (ms)');
% %             yticks(linspace(min(ylim),max(ylim),numel(freqList)));
% %             yticklabels(compose('%3.1f',freqList));
% %             colormap(gca,useColormap{iRow});
% %             caxis(useCaxis(iRow,:));
% %             title(eventFieldnames{iEvent});
% %             if iEvent == 1
% %                 ylabel('Freq (Hz)');
% %             end
% %             if iEvent == 7
% %                 cbAside(gca,useLabels{iRow},'k');
% %             end
% %         end
% %     end
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[2,iEvent]));

        yyaxis left;
        imagesc(t,1:numel(freqList),squeeze(mean(A(:,iEvent,:,:)))');
        set(gca,'ydir','normal');
        colormap(gca,jet);
        caxis(yLFP);
        yticks(linspace(min(ylim),max(ylim),numel(freqList)));
        yticklabels(compose('%3.1f',freqList));
        if iEvent == 1
            ylabel('Freq (Hz)');
        end
        
        yyaxis right;
        plot(t,squeeze(mean(B(:,iEvent,:))),'lineWidth',2);
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
end



% % % % for iNeuron = 133%useUnits
% % % %     if all_FR(iNeuron) < minFR
% % % %         continue;
% % % %     end
% % % %     [~,~,unitTrials,~] = cellfun(@size,all_Wz_power(LFP_lookup(iNeuron)));
% % % %     for iTrial = 1:unitTrials
% % % %         if doCompile
% % % %             lag_pval = [];
% % % %             lag_rho = [];
% % % %             for iFreq = 1:numel(freqList)
% % % %                 disp(['Correlating ',num2str(freqList(iFreq),'%2.1f'),' Hz...']);
% % % %                 for iEvent = 1:7
% % % %                     disp(['  -> ',eventFieldnames{iEvent}]);
% % % % % %                     Y = NaN(sum(unitTrials)*nMs,1);
% % % %                     Y = NaN(nMs,1);
% % % %                     Yind = 1;
% % % %                     A = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,LFP_range,iTrial,iFreq));
% % % %                     Y(Yind:Yind+numel(A)-1) = reshape(A',[numel(A) 1]);
% % % %                     Yind = Yind+numel(A);
% % % % 
% % % %                     % [ ] this is frequency independent (i.e., redundant!)
% % % %                     for iLag = 1:nMs+1
% % % %                         X = NaN(size(Y));
% % % %                         FR_range = LFP_range + (iLag - round(nMs/2)) - 1;
% % % %                         Xind = 1;
% % % %                         A = squeeze(all_zSDE{iNeuron}(iTrial,iEvent,FR_range));
% % % %                         X(Xind:Xind+numel(A)-1) = reshape(A',[numel(A) 1]);
% % % %                         Xind = Xind+numel(A);
% % % % 
% % % %                         [rho,pval] = corr(X,Y,'Type','Spearman');
% % % %                         lag_pval(iLag,iEvent,iFreq) = pval;
% % % %                         lag_rho(iLag,iEvent,iFreq) = rho;
% % % %                     end
% % % %                 end
% % % %             end
% % % %         end
% % % % 
% % % %         if doPlot
% % % %             h = ff(1400,800);
% % % %             left_color = [0 0 0];
% % % %             right_color = [1 0 0];
% % % %             set(h,'defaultAxesColorOrder',[left_color; right_color]);
% % % %             rows = 3;
% % % %             cols = 7;
% % % %             useData = {lag_rho,lag_pval};
% % % %             useColormap = {'jet','hot'};
% % % %             useCaxis = [-1 1;0 0.05];
% % % %             useLabels = {'rho','pval'};
% % % %             t = linspace(-tWindow*1000,tWindow*1000,size(all_zSDE{1},3));
% % % %             tLag = linspace(-round(nMs/2),round(nMs/2),size(lag_rho,1));
% % % %             lagLines = [min(tLag) min(tLag)];
% % % %             ySDE = [-3 3];
% % % %             yLFP = [-6 6];
% % % % 
% % % %             for iRow = 1:2
% % % %                 for iEvent = 1:7
% % % %                     subplot(rows,cols,prc(cols,[iRow,iEvent]));
% % % %                     imagesc(tLag,1:numel(freqList),squeeze(useData{iRow}(:,iEvent,:))');
% % % %                     set(gca,'ydir','normal');
% % % %                     xticks([min(xlim) round(mean(xlim)) max(xlim)]);
% % % %                     xticklabels([min(tLag) 0 max(tLag)]);
% % % %                     xlabel('spike lag (ms)');
% % % %                     yticks(linspace(min(ylim),max(ylim),numel(freqList)));
% % % %                     yticklabels(compose('%3.1f',freqList));
% % % %                     colormap(gca,useColormap{iRow});
% % % %                     caxis(useCaxis(iRow,:));
% % % %                     if iRow == 1
% % % %                         if iEvent == 1
% % % %                             title({['u',num2str(iNeuron,'%03d')],eventFieldnames{iEvent},'xcorr'});
% % % %                         else
% % % %                             title({eventFieldnames{iEvent},'xcorr'});
% % % %                         end
% % % %                     end
% % % %                     if iEvent == 1
% % % %                         ylabel('Freq (Hz)');
% % % %                     end
% % % %                     if iEvent == 7
% % % %                         cbAside(gca,useLabels{iRow},'k');
% % % %                     end
% % % %                 end
% % % %             end
% % % %             for iEvent = 1:7
% % % %                 subplot(rows,cols,prc(cols,[3,iEvent]));
% % % % 
% % % %                 yyaxis left;
% % % %                 A = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,:,iTrial,:));
% % % %                 imagesc(t,1:numel(freqList),A');
% % % %                 set(gca,'ydir','normal');
% % % %                 colormap(gca,jet);
% % % %                 caxis(yLFP);
% % % %                 yticks(linspace(min(ylim),max(ylim),numel(freqList)));
% % % %                 yticklabels(compose('%3.1f',freqList));
% % % %                 if iEvent == 1
% % % %                     ylabel('Freq (Hz)');
% % % %                 end
% % % % 
% % % %                 yyaxis right;
% % % %                 plot(t,squeeze(all_zSDE{iNeuron}(iTrial,iEvent,:)),'lineWidth',2);
% % % %                 ylim(ySDE);
% % % %                 yticks(sort([0 ylim]));
% % % %                 if iEvent == 7
% % % %                     ylabel('SDE (Z)');
% % % %                 end
% % % % 
% % % %                 hold on;
% % % %                 plot(-lagLines,ylim,'k:');
% % % %                 plot(lagLines,ylim,'k:');
% % % %                 plot([0,0],ylim,'k-');
% % % % 
% % % %                 xlabel('time (ms)');
% % % %                 title('LFP');
% % % %             end
% % % % 
% % % %             set(gcf,'color','w');
% % % %             if doSave
% % % %                 saveas(h,fullfile(savePath,['u',num2str(iNeuron,'%03d'),'_t',num2str(iTrial,'%03d'),'_xcorrRayMethod.png']));
% % % %                 close(h);
% % % %             end
% % % %         end
% % % %     end
% % % % end