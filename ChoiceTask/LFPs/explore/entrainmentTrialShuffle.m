% see: /print/Leventhal2012_Fig6_spikePhaseHist_allFreqs.m

% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'LFPfiles_local')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_ts')
% load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'eventFieldnames')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'LFPfiles_local_altLookup')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_trials')

% save('entrainmentTrialShuffle_all_spikeAngles','all_spikeAngles');

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainmentTrialShuffle';

doSetup = false;
doSave = true;
doCompile = false;

freqList = logFreqList([1 200],30);

nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
loadedFile = [];
tWindow = 0.5;
zThresh = 5;

if doSetup
    all_spikeAngles = {};
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        % replace with alternative for LFP
        sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        % only load uniques
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
            [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
            curTrials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
            [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
            trialRanges = periEventTrialTs(curTrials(trialIds),tWindow,eventFieldnames);
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            trialRanges = trialRanges(:,keepTrials,:);
        end
        
        ts = all_ts{iNeuron};
        
        for iShuffle = 1:2
            if iShuffle == 1
                useW = W;
            else
                useW = W(:,:,randsample(1:size(W,3),size(W,3)),:);
            end
            spikeAngles = {};
            for iEvent = 1:numel(eventFieldnames)
                for iTrial = 1:numel(keepTrials)
                    useTs = ts(ts > trialRanges(iEvent,iTrial,1) & ts < trialRanges(iEvent,iTrial,2));
                    ts2W = linspace(trialRanges(iEvent,iTrial,1),trialRanges(iEvent,iTrial,2),size(W,2));
                    for iFreq = 1:numel(freqList)
                        tsAngles = [];
                        for iTs = 1:numel(useTs)
                            tsAngles = [tsAngles angle(useW(iEvent,closest(ts2W,useTs(iTs)),iTrial,iFreq))];
                        end
                        spikeAngles{iEvent,iTrial,iFreq} = tsAngles;
                    end
                end
            end
            all_spikeAngles{iShuffle,iNeuron} = spikeAngles;
        end
    end
end

% compile
if doCompile
    compiled_spikeAngles = {};
    for iShuffle = 1:2
        for iNeuron = 1:size(all_spikeAngles,2)
            thisNeuron = all_spikeAngles{iShuffle,iNeuron};
            for iEvent = 1:numel(eventFieldnames)
                for iFreq = 1:numel(freqList)
                    try
                        compiled_spikeAngles{iShuffle,iEvent,iFreq} = [compiled_spikeAngles{iShuffle,iEvent,iFreq} cell2mat(thisNeuron(iEvent,:,iFreq))];
                    catch
                        compiled_spikeAngles{iShuffle,iEvent,iFreq} = cell2mat(thisNeuron(iEvent,:,iFreq));
                    end
                end
            end
        end
    end
end

% close all;
h = ff(1200,800);
colors = lines(2);
rows = 10;
cols = 7;
iSubplot = 0;
for iFreq = 1:10
    iSubplot = iSubplot + 1;
    for iShuffle = 1:2
        for iEvent = 1:7
            theseAngles = compiled_spikeAngles{iShuffle,iEvent,iFreq};
            counts = histcounts(theseAngles,binEdges);
            subplot(rows,cols,prc(cols,[iSubplot,iEvent]));
            plot([counts counts],'color',colors(iShuffle,:),'linewidth',2);
            hold on;
            ylim([5.2e4 7.8e4]);
            yticks(ylim);
            xticks([0,6.5,12.5,18.5,24]);
            xticklabels([0 180 360 540 720]);
            xtickangle(270);
            grid on;
            if iFreq == 1
                title(eventFieldnames{iEvent});
            end
            if iEvent == 1
                ylabel([num2str(freqList(iFreq),'%2.1f'),' Hz']);
            end
        end
    end
    set(gcf,'color','w');
end
if doSave
    saveFile = ['entrainmentTrialShuffle_',num2str(iFreq),'.png'];
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end