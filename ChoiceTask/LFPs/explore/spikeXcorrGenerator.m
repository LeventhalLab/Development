% SPIKEXCORR, XCORRLINES
% [ ] remove debug figures

% load('20190322_xcorr');

% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local_altLookup')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')

% load('20190321_xcorrSDE_u001.mat', 'lag')

doSetup = true;
doDebug = false;
doAlt = true;
doWrite = true;
doLoad = false;
doShuffle = false;
doSave = false;
doPlot1 = false;
doPlot2 = true;
dataPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/xcorr';
dataPath_shuff = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/xcorr_shuffle';
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/xcorr';

% freqList = logFreqList([1 200],30);
freqList = [2.5,20,55,180];
loadedFile = [];
minFR = 5;
maxTrialTime = 20; % seconds
tXcorr = 1; % seconds
inLabels = {'in-trial','inter-trial'};

doTrialOrder = false;
doPoisson = true;
nPoisson = 20;
if doSetup
    xcorrUnits = [];
    all_acors_poisson_median = [];
    all_acors_poisson_mean = [];
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
        end
        SDE = equalVectors(spikeDensityEstimate(ts,numel(sevFilt)/Fs),size(Wz,1))';
        SDEz = (SDE - mean(SDE)) ./ std(SDE);
        useSamples = {intrialSamples,intertrialSamples};
        
        if doTrialOrder
            acors = [];%NaN(2,size(intrialSamples,1),size(Wz,2));
            for iIn = 1:2
                for iTrial = 1:size(intrialSamples,1)
                    XSDE = squeeze(SDE(useSamples{iIn}(iTrial,1):useSamples{iIn}(iTrial,2)));
                    X = XSDE - mean(XSDE);
                    for iFreq = 1:size(Wz,2)
                        YW = squeeze(W(useSamples{iIn}(iTrial,1):useSamples{iIn}(iTrial,2),iFreq));
                        Y = (YW - mean(YW)) ./ std(W(:,iFreq));
                        [acor,lag] = xcorr(X,Y,round(tXcorr*Fs),'coeff');
                        acors(iIn,iTrial,iFreq,:) = acor;
                        
                        if doDebug && iIn == 1 && iFreq == 6
                            debugPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/xcorr/debug';
                            h = ff(800,500);
                            subplot(211);
                            yyaxis left;
                            plot(X);
                            xlim([1 numel(X)]);
                            yyaxis right;
                            plot(Y);
                            legend({'SDE','W'});
                            subplot(212);
                            plot(lag,acor,'k-');
                            xlim([min(lag) max(lag)]);
                            legend({'XCORR'});
                            saveas(h,fullfile(debugPath,['xcorrDebug_u',num2str(iNeuron,'%03d'),...
                                '_f',num2str(iFreq,'%02d'),'_t',num2str(iTrial,'%03d'),'_i',num2str(iIn),'.png']));
                            close(h);
                        end
                    end
                end
            end
            if doWrite
                save(fullfile(dataPath,['20190321_xcorrSDE_u',num2str(iNeuron,'%03d')]),'acors','lag','tXcorr');
            end
        end
        
        if doPoisson
            acors_poisson = [];
            for iPoisson = 1:nPoisson
                disp(['shuffling u',num2str(iNeuron,'%03d'),', iShuffle = ',num2str(iPoisson)]);
                ts = all_ts{iNeuron};
                spiketrain_duration = max(ts) * 1000; % ms
                spiketrain_meanrate = numel(ts) / max(ts); % s/sec
                spiketrain_gamma_order = 1; % poisson
                [t,s] = fastgammatrain(spiketrain_duration,spiketrain_meanrate,spiketrain_gamma_order);
                ts = t(s==1)' / 1000;
                SDE = equalVectors(spikeDensityEstimate(ts,numel(sevFilt)/Fs),size(Wz,1))';
% %                 SDEz = (SDE - mean(SDE)) ./ std(SDE);
                for iIn = 1:2
                    for iTrial = 1:size(intrialSamples,1)
                        XSDE = squeeze(SDE(useSamples{iIn}(iTrial,1):useSamples{iIn}(iTrial,2)));
                        X = XSDE - mean(XSDE);
                        for iFreq = 1:size(Wz,2)
                            YW = squeeze(W(useSamples{iIn}(iTrial,1):useSamples{iIn}(iTrial,2),iFreq));
                            Y = (YW - mean(YW)) ./ std(W(:,iFreq));
                            [acor,lag] = xcorr(X,Y,round(tXcorr*Fs),'coeff');
                            acors_poisson(iIn,iTrial,iFreq,:) = acor;
                        end
                    end
                end
                for iIn = 1:2
                    all_acors_poisson_median(iPoisson,iNeuron,iIn,:,:) = squeeze(median(acors_poisson(iIn,:,:,:),2));
                    all_acors_poisson_mean(iPoisson,iNeuron,iIn,:,:) = squeeze(mean(acors_poisson(iIn,:,:,:),2));
                end
            end

            if doWrite
                save(fullfile(dataPath_shuff,['20190321_xcorr_poisson_u',num2str(iNeuron,'%03d')]),...
                    'all_acors_poisson_median','all_acors_poisson_mean','lag','tXcorr');
                save(fullfile(dataPath_shuff,'20190321_xcorr_poisson_u001-206'),...
                    'all_acors_poisson_median','all_acors_poisson_mean','lag','tXcorr');
            end
        end
    end
end

% % % % xcorrFiles = dir(fullfile(dataPath,'*.mat'));
% % % % xcorrUnits = [];
% % % % for iFile = 1:numel(xcorrFiles)
% % % %     disp(['loading ',xcorrFiles(iFile).name]);
% % % %     iNeuron = str2num(xcorrFiles(iFile).name(end-6:end-4));
% % % %     xcorrUnits = [xcorrUnits iNeuron];
% % % % end
    
if doLoad
    xcorrFiles = dir(fullfile(dataPath,'*.mat'));
    all_acors = [];
    xcorrUnits = [];
    unitCount = 0;
    for iFile = 1:numel(xcorrFiles)
        disp(['loading ',xcorrFiles(iFile).name]);
        load(fullfile(xcorrFiles(iFile).folder,xcorrFiles(iFile).name));
        iNeuron = str2num(xcorrFiles(iFile).name(end-6:end-4));
        if sum(isnan(acors(:))) == 0
            unitCount = unitCount + 1;
            xcorrUnits = [xcorrUnits iNeuron];
            for iIn = 1:2
    %             all_acors(unitCount,iIn,:,:) = squeeze(median(acors(iIn,:,:,:),2));
                all_acors(unitCount,iIn,:,:) = squeeze(mean(acors(iIn,:,:,:),2));
            end
        end
    end
    if doWrite
        save('20190402_xcorr','all_acors','xcorrUnits');
    end
end

condUnits = {1:366,dirSelUnitIds,ndirSelUnitIds};

nShuffle = 1000;
if doShuffle
    all_acor_shuffle = [];
    for iShuffle = 1:nShuffle
        for iIn = 1:2
            for iDir = 2:3
                useUnits = randsample(1:numel(xcorrUnits),sum(ismember(xcorrUnits,condUnits{iDir})));
                data = squeeze(mean(all_acors(useUnits,iIn,:,:)));
                all_acor_shuffle(iShuffle,iIn,iDir,:,:) = data;
            end
        end
    end
    if doWrite
        save('20190402_xcorr','-append','all_acor_shuffle');
    end
end

tlag = linspace(-tXcorr,tXcorr,numel(lag));
condLabels = {'allUnits','dirSel','ndirSel'};

if doPlot1
    h = ff(800,500);
    rows = 2;
    cols = 3;
    for iIn = 1:2
        for iDir = 1:3
            subplot(rows,cols,prc(cols,[iIn,iDir]));
            useUnits = ismember(xcorrUnits,condUnits{iDir});
            data = squeeze(nanmean(all_acors(useUnits,iIn,:,:)));
            imagesc(tlag,1:numel(freqList),data);
            hold on;
            plot([0,0],ylim,'k:');
            set(gca,'ydir','normal');
            xlim([min(tlag) max(tlag)]);
            xticks(sort([0,xlim]));
            xlabel('spike lags LFP (s)');
            yticks(linspace(min(ylim),max(ylim),numel(freqList)));
            yticklabels(compose('%3.1f',freqList));
            colormap(gca,jet);
            caxis([-0.02,0.05]);
            title({inLabels{iIn},condLabels{iDir}});
        end
    end
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,'SPIKEXCORR.png'));
        close(h);
    end
end

if doPlot2
    close all
    useFreqs = [6;17;22;29];
    freqLabels = {'\delta','\beta','\gamma_L','\gamma_H'};
    h = ff(900,800);
    rows = size(useFreqs,1);
    cols = 3;
    colors = {lines(size(useFreqs,1)),lines(size(useFreqs,1))*.3};
    pThresh = 0.05;
    ylimVals = [-0.05,0.05];
    for iDir = 1:3
        useUnits = ismember(xcorrUnits,condUnits{iDir});
        for iFreq = 1:size(useFreqs,1)
            for iIn = 1:2
                data = squeeze(nanmean(all_acors(useUnits,iIn,useFreqs(iFreq),:)));
                subplot(rows,cols,prc(cols,[iFreq,iDir]));
                plot(tlag,data,'color',colors{iIn}(iFreq,:),'linewidth',2);
                hold on;
                
                % display
                disp([condLabels{iDir},' ',inLabels{iIn},', ',num2str(iFreq)]);
                [v,k] = min(data);
                disp(['--> MIN: r = ',num2str(v,3),', t = ',num2str(tlag(k)*1000,3)]);
                [v,k] = max(data);
                disp(['--> MAX: r = ',num2str(v,3),', t = ',num2str(tlag(k)*1000,3)]);
                
% %                 poisson_data = squeeze(mean(all_acors_poisson_median(:,condUnits{iDir},iIn,iFreq,:),2));
% %                 plot(tlag,poisson_data','color',[colors{iIn}(iFreq,:) 0.8]);
                
                if iDir > 1
                    shuff_data = squeeze(all_acor_shuffle(:,iIn,iDir,useFreqs(iFreq),:));
                    diffFromShuff = sum(data' < shuff_data) / nShuffle;
                    pIdx = find(diffFromShuff < pThresh);% | diffFromShuff >= 1-pThresh);
                    plot(tlag(pIdx),ones(size(pIdx))*max(ylimVals)-(iIn*.005),'.','color',colors{iIn}(iFreq,:),'linewidth',2);
                    pIdx = find(diffFromShuff >= 1-pThresh);
                    plot(tlag(pIdx),ones(size(pIdx))*min(ylimVals)+(iIn*.005),'.','color',colors{iIn}(iFreq,:),'linewidth',2);
                else
                    if iIn == 2
                        legend({'in-trial','inter-trial'},'location','northwest');
                    end
                end
            end
            xlim([min(tlag) max(tlag)]);
            xticks(sort([0,xlim]));
            if iFreq == size(useFreqs,1)
                xlabel('spike lags LFP (s)');
            end
            ylim(ylimVals);
            yticks(sort([0,ylim]));
            ylabel('mean xcorr');
            if iFreq == 1
                title({condLabels{iDir},freqLabels{iFreq}});
            else
                title(freqLabels{iFreq});
            end
            grid on;
        end
    end
    set(gcf,'color','w');
    addNote(h,{'top bars are where signal > all unit shuffle','bottom bars are where signal < all unit shuffle'});
    if doSave
        saveas(h,fullfile(savePath,'XCORRLINES.png'));
        close(h);
    end
end
