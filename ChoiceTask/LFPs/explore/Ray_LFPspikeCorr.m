% https://www.researchgate.net/post/How_can_one_calculate_normalized_cross_correlation_between_two_arrays
% https://www.mathworks.com/matlabcentral/answers/5275-algorithm-for-coeff-scaling-of-xcorr
doSetup = true;

if false
    % load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')
    load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
    load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'eventFieldnames')
    % if going straight to compile
    load('Ray_LFPspikeCorr_setup.mat')
end

freqList = logFreqList([1 200],30);
Wlength = 1000;
tWindow = 0.5;
loadedFile = [];
zThresh = 5;
oversampleBy = 5; % has to be high for eegfilt() (> 14,000 samples)
nSurr = 200; % >> max # of trials for any session

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
            
            % out of trial (i.e., fake trials)
            trialTimeRanges = compileTrialTimeRanges(curTrials);
            takeTime = tWindow * oversampleBy;
            takeSamples = round(takeTime * Fs);
            minTime = min(trialTimeRanges(:,2));
            maxTime = max(trialTimeRanges(:,1)) - takeTime;

            data = [];
            iSurr = 0;
            while iSurr < nSurr + 40 + numel(keepTrials) % add buffer for artifact removal
                % try randTs
                randTs = (maxTime-minTime) .* rand + minTime;
                randSample = round(randTs * Fs);
                sampleRange = randSample:randSample + takeSamples - 1;
                thisData = sevFilt(sampleRange);
                if isempty(strfind(diff(thisData),zeros(1,round(numel(sampleRange)*0.1))))
                    iSurr = iSurr + 1;
                    data(:,iSurr) = thisData;
                end
            end

            keepTrials = threshTrialData(data,zThresh);
            W_surr = [];
            W_surr = calculateComplexScalograms_EnMasse(data(:,keepTrials(1:nSurr + size(W,3))),'Fs',Fs,'freqList',freqList);
            tWindow_sample = size(W,2)/2;
            reshapeRange = round(size(W_surr,1)/2)-tWindow_sample:round(size(W_surr,1)/2)+tWindow_sample-1;
            W_surr = W_surr(reshapeRange,:,:);
            W(8,:,:,:) = W_surr(:,(1:size(W,3)),:); % add fake trials
        
            % technically don't need z-score if xcorr is normalized
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

doCompile = true;
doShuffle = false;
doPlot = false;
doSave = false;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/xcorrRayMethod';
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

all_shuff_pvals = NaN(numel(useUnits),7,numel(freqList),nMs*2+1);
all_A_shuffled_mean = all_shuff_pvals;
all_A = all_A_shuffled_mean;
unitLookup = [];
neuronCount = 0;
for iNeuron = useUnits
    neuronCount = neuronCount + 1;
    unitLookup(neuronCount) = iNeuron;
    disp(['iNeuron ',num2str(iNeuron,'%03d')]);
    
    if doCompile
        acors = NaN(size(all_zSDE{iNeuron},1),7,numel(freqList),nMs*2+1);
        for iTrial = 1:size(all_zSDE{iNeuron},1)
            disp(['  -> trial',num2str(iTrial,'%03d')]);
            for iEvent = 1:7
                for iFreq = 1:numel(freqList)
                    Y = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,:,iTrial,iFreq));
                    X = squeeze(all_zSDE{iNeuron}(iTrial,iEvent,:))';
                    [acor,lag] = xcorr(X,Y,nMs,'coeff');
                    acors(iTrial,iEvent,iFreq,:) = acor;
                end
            end
        end
        A = squeeze(mean(acors));
        all_A(neuronCount,:,:,:) = A;
        
        if doShuffle
            acors = NaN(size(all_zSDE{iNeuron},1),7,numel(freqList),nMs*2+1);
            A_shuffled = NaN(nShuffle,7,numel(freqList),nMs*2+1);
            shuff_pvals_pos = zeros(size(A));
            shuff_pvals_neg = zeros(size(A));
            for iShuffle = 1:nShuffle
                disp(['  -> shuffle',num2str(iShuffle,'%03d')]);
                randTrial = randsample(1:size(all_zSDE{iNeuron},1),size(all_zSDE{iNeuron},1));
                for iTrial = 1:size(all_zSDE{iNeuron},1)
                    for iEvent = 1:7
                        for iFreq = 1:numel(freqList)
                            Y = squeeze(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,:,iTrial,iFreq));
                            X = squeeze(all_zSDE{iNeuron}(randTrial(iTrial),iEvent,:))';
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
            all_A_shuffled_mean(neuronCount,:,:,:) = squeeze(mean(A_shuffled));
        end
    end
    

    if doPlot
        h = ff(1400,800);
        left_color = [0 0 0];
        right_color = [1 0 0];
        set(h,'defaultAxesColorOrder',[left_color; right_color]);
        rows = 4;
        cols = 7;
        acorCaxis = [-.2 .2];
        useData = {A,squeeze(mean(A_shuffled))};
        t = linspace(-tWindow*1000,tWindow*1000,size(all_zSDE{1},3));
        ySDE = [-3 3];
        yLFP = [-6 6];
        
        for iEvent = 1:7
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
                        title({['u',num2str(iNeuron,'%03d')],eventFieldnames{iEvent},'xcorr'});
                    else
                        title({eventFieldnames{iEvent},'xcorr'});
                    end
                else
                    title('xcorr_{shuffle}');
                end
                if iEvent == 7
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
            if iEvent == 7
                cbAside(gca,'pval','k');
            end
            
            subplot(rows,cols,prc(cols,[4,iEvent]));
            yyaxis left;
            imagesc(t,1:numel(freqList),squeeze(mean(all_Wz_power{LFP_lookup(iNeuron)}(iEvent,:,:,:),3))');
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
            plot(t,squeeze(mean(all_zSDE{iNeuron}(:,iEvent,:),1)),'lineWidth',2);
            ylim(ySDE);
            yticks(sort([0 ylim]));
            if iEvent == 7
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
save('20190121_RayLFP_compiled','lag','all_A','all_shuff_pvals',...
    'all_shuff_pvals','unitLookup','eventFieldnames','dirSelUnitIds','ndirSelUnitIds');