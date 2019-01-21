% https://www.researchgate.net/post/How_can_one_calculate_normalized_cross_correlation_between_two_arrays
% https://www.mathworks.com/matlabcentral/answers/5275-algorithm-for-coeff-scaling-of-xcorr
doSetup = true;

if ismac
    dataPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/Ray_LFPspikeCorr';
else
    dataPath = '';
end

freqList = logFreqList([1 200],30);
Wlength = 1000;
tWindow = 0.5;
loadedFile = [];
zThresh = 5;
oversampleBy = 5; % has to be high for eegfilt() (> 14,000 samples)
nSurr = 200; % >> max # of trials for any session
eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};

if doSetup
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
            trials = all_trials{iNeuron};
            trials = addEventToTrials(trials,'outTrial');
            [trialIds,allTimes] = sortTrialsBy(trials,'RT');
            % must use tWindow*2 because Wz returns half window
            [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow*2,Fs,freqList,eventFieldnames_wFake);
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            % technically don't need z-score if xcorr is normalized
            [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
            save(fullfile(dataPath,['Wz_power_s',num2str(iSession,'%02d')]),'Wz_power');
        end
        LFP_lookup(iNeuron) = iSession; % find LFP in all_Wz_power
        all_keepTrials{iNeuron} = keepTrials;
        tsPeths = eventsPeth(trials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames_wFake);
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
        save(fullfile(dataPath,['zSDE_u',num2str(iNeuron,'%03d')]),'zSDE');
    end
    save('Ray_LFPspikeCorr_setup','LFP_lookup','all_keepTrials','all_FR','eventFieldnames_wFake','all_trials',...
        'LFPfiles_local','all_ts','dirSelUnitIds','ndirSelUnitIds','primSec');
end

doCompile = false;
doShuffle = false;
doPlot = false;
doSave = false;
doWrite = false;

if ismac
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/xcorrRayMethod';
else
    % for windows
end

nMs = 500;
minFR = 10;
nShuffle = 10;
startIdx = round(Wlength/2) - round(nMs/2) + 1;
LFP_range = startIdx:startIdx + nMs - 1;
doDirSel = 0;

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

loadedFile = [];
unitLookup = [];
neuronCount = 0;
for iNeuron = useUnits
    neuronCount = neuronCount + 1;
    unitLookup(neuronCount) = iNeuron;
    zSDE = load(fullfile(dataPath,['zSDE_u',num2str(iNeuron,'%03d')]),'zSDE');
    LFPfile = fullfile(dataPath,['Wz_power_s',num2str(LFP_lookup(iNeuron),'%02d')]);
    if isempty(loadedFile) || ~strcmp(loadedFile,LFPfile)
        Wz_power = load(LFPfile,'Wz_power');
    end
    
    if neuronCount == 1
        all_shuff_pvals = NaN(numel(useUnits),size(zSDE,2),numel(freqList),nMs*2+1);
        all_acors_shuffled_mean = all_shuff_pvals; % same dim
        all_acors = all_acors_shuffled_mean; % same dim
    end
    disp(['iNeuron ',num2str(iNeuron,'%03d')]);
    
    if doCompile
        acors = NaN(size(zSDE,1),size(zSDE,2),numel(freqList),nMs*2+1);
        for iTrial = 1:size(zSDE,1)
            disp(['  -> trial',num2str(iTrial,'%03d')]);
            for iEvent = 1:size(zSDE,2)
                for iFreq = 1:numel(freqList)
                    Y = squeeze(Wz_power(iEvent,:,iTrial,iFreq));
                    X = squeeze(zSDE(iTrial,iEvent,:))';
                    [acor,lag] = xcorr(X,Y,nMs,'coeff');
                    acors(iTrial,iEvent,iFreq,:) = acor;
                end
            end
        end
        A = squeeze(mean(acors));
        all_acors(neuronCount,:,:,:) = A;
        
        if doShuffle
            acors = NaN(size(zSDE,1),size(zSDE,2),numel(freqList),nMs*2+1);
            A_shuffled = NaN(nShuffle,size(zSDE,2),numel(freqList),nMs*2+1);
            shuff_pvals_pos = zeros(size(A));
            shuff_pvals_neg = zeros(size(A));
            for iShuffle = 1:nShuffle
                disp(['  -> shuffle',num2str(iShuffle,'%03d')]);
                randTrial = randsample(1:size(zSDE,1),size(zSDE,1));
                for iTrial = 1:size(zSDE,1)
                    for iEvent = 1:size(zSDE,2)
                        for iFreq = 1:numel(freqList)
                            Y = squeeze(Wz_power(iEvent,:,iTrial,iFreq));
                            X = squeeze(zSDE(randTrial(iTrial),iEvent,:))';
                            [acor,lag] = xcorr(X,Y,nMs,'coeff');
                            acors(iTrial,iEvent,iFreq,:) = acor;
                        end
                    end
                end
                B = squeeze(mean(acors)); % shuffled acor
                A_shuffled(iShuffle,:,:,:) = B;
                shuff_pvals_pos = shuff_pvals_pos + (A > B);
                shuff_pvals_neg = shuff_pvals_neg + (B > A);
            end
            shuff_pvals = zeros(size(A));
            shuff_pvals(shuff_pvals_pos > shuff_pvals_neg) = shuff_pvals_pos(shuff_pvals_pos > shuff_pvals_neg) / nShuffle;
            shuff_pvals(shuff_pvals_neg > shuff_pvals_pos) = -1 * shuff_pvals_neg(shuff_pvals_neg > shuff_pvals_pos) / nShuffle;

            all_shuff_pvals(neuronCount,:,:,:) = shuff_pvals;
            all_acors_shuffled_mean(neuronCount,:,:,:) = squeeze(mean(A_shuffled));
        end
    end
    

    if doPlot
        h = ff(1400,800);
        left_color = [0 0 0];
        right_color = [1 0 0];
        set(h,'defaultAxesColorOrder',[left_color; right_color]);
        rows = 4;
        cols = size(zSDE,2);
        acorCaxis = [-.2 .2];
        useData = {A,squeeze(mean(A_shuffled))};
        t = linspace(-tWindow*1000,tWindow*1000,size(zSDE,3));
        ySDE = [-3 3];
        yLFP = [-6 6];
        
        for iEvent = 1:size(zSDE,2)
            for iShuffle = 1:2
                subplot(rows,cols,prc(cols,[iShuffle,iEvent]));
                imagesc(lag,1:numel(freqList),squeeze(useData{iShuffle}(iEvent,:,:)));
                hold on;
                plot([0,0],ylim,'k:');
                set(gca,'ydir','normal');
                xlabel('spike lag (ms)');
                yticks(linspace(min(ylim),max(ylim),numel(freqList)));
                yticklabels(compose('%3.1f',freqList));
                colormap(gca,jet);
                caxis(acorCaxis);
                ax = gca;
                ax.YAxis.FontSize = 7;

                if iShuffle == 1
                    if iEvent == 1
                        ylabel('Freq (Hz)');
                        title({['u',num2str(iNeuron,'%03d')],eventFieldnames_wFake{iEvent},'xcorr'});
                    else
                        title({eventFieldnames_wFake{iEvent},'xcorr'});
                    end
                else
                    title('xcorr_{shuffle}');
                end
                if iEvent == size(zSDE,2)
                    cbAside(gca,'acor','k');
                end
            end
            
            subplot(rows,cols,prc(cols,[3,iEvent]));
            imagesc(lag,1:numel(freqList),squeeze(shuff_pvals(iEvent,:,:)));
            hold on;
            plot([0,0],ylim,'k:');
            set(gca,'ydir','normal');
            xlabel('spike lag (ms)');
            yticks(linspace(min(ylim),max(ylim),numel(freqList)));
            yticklabels(compose('%3.1f',freqList));
            colormap(gca,jupiter);
            caxis([-1 1]);
            ax = gca;
            ax.YAxis.FontSize = 7;
            title(['shuff (x',num2str(nShuffle),')']);
            if iEvent == size(zSDE,2)
                cbAside(gca,'pval','k');
            end
            
            subplot(rows,cols,prc(cols,[4,iEvent]));
            yyaxis left;
            imagesc(t,1:numel(freqList),squeeze(mean(Wz_power(iEvent,:,:,:),3))');
            set(gca,'ydir','normal');
            colormap(gca,jet);
            caxis(yLFP);
            yticks(linspace(min(ylim),max(ylim),numel(freqList)));
            yticklabels(compose('%3.1f',freqList));
            ax = gca;
            ax.YAxis(1).FontSize = 7;
            if iEvent == 1
                ylabel('Freq (Hz)');
            end

            yyaxis right;
            plot(t,squeeze(mean(zSDE(:,iEvent,:),1)),'lineWidth',2);
            ylim(ySDE);
            yticks(sort([0 ylim]));
            if iEvent == size(zSDE,2)
                ylabel('SDE (Z)');
            end
            hold on;
            plot([0,0],ylim,'k:');
            xlabel('time (ms)');
            title('LFP');
        end
        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,['u',num2str(iNeuron,'%03d'),'_ray_xcorr_norm.png']));
            close(h);
        end
    end
end
if doWrite
    save('20190121_RayLFP_compiled','lag','all_acors','all_shuff_pvals','all_acors_shuffled_mean','unitLookup');
end