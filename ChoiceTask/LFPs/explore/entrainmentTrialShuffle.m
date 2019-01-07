% see: /print/Leventhal2012_Fig6_spikePhaseHist_allFreqs.m

% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'LFPfiles_local')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_ts')
% load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'eventFieldnames')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'LFPfiles_local_altLookup')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_trials')

% save('entrainmentTrialShuffle_all_spikeAngles','all_spikeAngles');

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainmentTrialShuffle';

doSetup = true;
doSave = true;
doPlot = true;

doCompile = true;
doCompile_plot = false;
doByUnit = true;

freqList = logFreqList([1 200],30);

nBins = 12;
binEdges = linspace(-pi,pi,nBins+1);
loadedFile = [];
tWindow = 0.5;
zThresh = 5;

if doSetup
    all_spikeAngles = {};
    for iNeuron = 1:5%numel(all_ts)
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
                    useTs = ts(ts > trialRanges(iEvent,iTrial,1) & ts < trialRanges(iEvent,iTrial,2)) - mean(trialRanges(iEvent,iTrial,:));
                    ts2W = linspace(-tWindow,tWindow,size(W,2));
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

% analyze by unit
if doByUnit
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainmentTrialShuffle/units';
    close all;
    useFreqs = 1:10;
    colors = [0 0 0;1 0 0];
    rows = numel(useFreqs);
    cols = 7;
    ylimVals = [-4 4];
    unit_counts = [];
    for iNeuron = 1:size(all_spikeAngles,2)
        % prepare
        all_counts = [];
        for iShuffle = 1:2
            thisNeuron = all_spikeAngles{iShuffle,iNeuron};
            iRow = 0;
            for iFreq = useFreqs
                iRow = iRow + 1;
                for iEvent = 1:numel(eventFieldnames)
                    alpha = cell2mat(thisNeuron(iEvent,:,useFreqs(iFreq)));
                    counts = histcounts(alpha,binEdges);
                    all_counts(iShuffle,iFreq,iEvent,:) = counts;
                end
            end
        end
        
        % print
        if doPlot
            h = ff(1200,800);
        end
        for iShuffle = [2 1]
            iRow = 0;
            for iFreq = useFreqs
                iRow = iRow + 1;
                for iEvent = 1:numel(eventFieldnames)
                    counts = squeeze(all_counts(iShuffle,iFreq,iEvent,:));
                    row_counts = squeeze(all_counts(iShuffle,iFreq,:,:));
                    counts_z = (counts - mean(mean(row_counts))) ./ std(mean(row_counts,2));
                    unit_counts(iNeuron,iShuffle,iFreq,iEvent,:) = counts_z; % set it here
                    if doPlot
                        subplot(rows,cols,prc(cols,[iRow,iEvent]));
                        plot([counts_z;counts_z],'color',colors(iShuffle,:),'linewidth',2);
                        hold on;
                        grid on;
                        xlim([1 numel(counts_z)*2]);
                        ylim(ylimVals);
                        yticks(sort([0 ylim]));
                        if iRow == 1 && iEvent == 1
                            alpha = cell2mat(thisNeuron(4,:,1));
                            FR = round(numel(alpha) / size(thisNeuron,2));
                            title({['u',num2str(iNeuron,'%03d'),', ~',num2str(FR),'s/sec'],eventFieldnames{iEvent}});
                        elseif iRow == 1
                            title(eventFieldnames{iEvent});
                        end
                        if iEvent == 1
                            ylabel({[num2str(freqList(iFreq),'%2.1f'),' Hz'],'Z-counts'});
                        else
                            yticklabels([]);
                        end
                        if iRow == numel(useFreqs)
                            xticks([0,6.5,12.5,18.5,24]);
                            xticklabels([0 180 360 540 720]);
                            xtickangle(270);
                            xlabel('Spike-phase');
                        else
                            xticks([0,6.5,12.5,18.5,24]);
                            xticklabels([]);
                        end
                    end
                end
            end
        end
        if doPlot
            legend({'Shuffle','Normal'})
            set(h,'color','w');
            if doSave
                saveFile = ['entrainmentTrialShuffle_u',num2str(iNeuron,'%03d'),'_f',num2str(iFreq),'.png'];
                saveas(h,fullfile(savePath,saveFile));
                close(h);
            end
        end
    end
    
    % all units
    h = ff(1200,800);
    for iShuffle = [2 1]
        iRow = 0;
        for iFreq = useFreqs
            iRow = iRow + 1;
            for iEvent = 1:numel(eventFieldnames)
                counts_z = squeeze(mean(unit_counts(:,iShuffle,iFreq,iEvent,:)));
                subplot(rows,cols,prc(cols,[iRow,iEvent]));
                plot([counts_z;counts_z],'color',colors(iShuffle,:),'linewidth',2);
                hold on;
                grid on;
                xlim([1 numel(counts_z)*2]);
                ylim(ylimVals);
                yticks(sort([0 ylim]));
                if iRow == 1 && iEvent == 1
                    alpha = cell2mat(thisNeuron(4,:,1));
                    FR = round(numel(alpha) / size(thisNeuron,2));
                    title({['all units'],eventFieldnames{iEvent}});
                elseif iRow == 1
                    title(eventFieldnames{iEvent});
                end
                if iEvent == 1
                    ylabel({[num2str(freqList(iFreq),'%2.1f'),' Hz'],'Z-counts'});
                else
                    yticklabels([]);
                end
                if iRow == numel(useFreqs)
                    xticks([0,6.5,12.5,18.5,24]);
                    xticklabels([0 180 360 540 720]);
                    xtickangle(270);
                    xlabel('Spike-phase');
                else
                    xticks([0,6.5,12.5,18.5,24]);
                    xticklabels([]);
                end
            end
        end
    end
    legend({'Shuffle','Normal'})
    set(h,'color','w');
    if doSave
        saveFile = ['entrainmentTrialShuffle_allUnits_f',num2str(iFreq),'.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
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

if doCompile_plot
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
end