% % load('entrainmentHighRes_setup')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')
% load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
freqList = logFreqList([1 200],30);

tWindow = 0.5;
eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};

if ismac
    dataPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/Ray_LFPspikeCorr';
    shufflePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/entrainmentShuffle';
else
    dataPath = 'C:\Users\dleventh\Documents\Data\ChoiceTask\LFPs\datastore\Ray_LFPspikeCorr';
    shufflePath = 'C:\Users\dleventh\Documents\Data\ChoiceTask\LFPs\datastore\entrainmentShuffle';
end
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainmentHighRes';

doCompile = true;
doConds = false;

doPlot_shuffle = false;
doPlot_lines = true;

nShuffle = 200;

loadedFile = [];
neuronCount = 0;
if doCompile
%     unitAngles = {};
    for iNeuron = 1:numel(all_ts)
        neuronCount = neuronCount + 1;
        load(fullfile(dataPath,['tsPeths_u',num2str(iNeuron,'%03d')]),'tsPeths');
        LFPfile = fullfile(dataPath,['Wz_phase_s',num2str(LFP_lookup(iNeuron),'%02d')]);
        if isempty(loadedFile) || ~strcmp(loadedFile,LFPfile)
            load(LFPfile,'Wz_phase');
        end
        disp(['Compiling iNeuron ',num2str(iNeuron,'%03d')]);
        
        for iShuffle = 1:nShuffle+1
            disp(['iShuffle: ',num2str(iShuffle)]);
            if iShuffle == 1
                trialOrder = 1:size(tsPeths,1);
            else
                trialOrder = randsample(1:size(tsPeths,1),size(tsPeths,1));
            end
            spikeAngles = NaN(size(Wz_phase,1),size(Wz_phase,4),0);
            for iEvent = 1:size(Wz_phase,1)
                startIdx = ones(size(Wz_phase,4));
                for iTrial = 1:size(tsPeths,1)
                    theseSpikes = tsPeths{trialOrder(iTrial),iEvent};
                    for iFreq = 1:size(Wz_phase,4)
                        spikeIdx = logical(histcounts(theseSpikes,linspace(-tWindow,tWindow,size(Wz_phase,2)+1)));
                        endIdx = startIdx(iFreq) + sum(spikeIdx);
                        spikeAngles(iEvent,iFreq,startIdx(iFreq):endIdx-1) = Wz_phase(iEvent,spikeIdx,iTrial,iFreq);
                        startIdx(iFreq) = endIdx;
                    end
                end
%                 unitAngles{iShuffle,iNeuron,iEvent} = spikeAngles;
            end
            shuffleName = ['u',num2str(iNeuron,'%03d'),'_shuffle',num2str(iShuffle,'%03d')];
            save(fullfile(shufflePath,shuffleName),'spikeAngles');
        end
    end
    save('entrainmentHighRes_setup','eventFieldnames','dirSelUnitIds','ndirSelUnitIds','primSec',...
        'LFP_lookup','all_FR','all_keepTrials');
end

if doConds
    nBins = 12;
    binEdges = linspace(-pi,pi,nBins+1);
    condUnits = {1:size(unitAngles,2),dirSelUnitIds,ndirSelUnitIds};
    condLabels = {'allUnits','dirSel','ndirSel'};
    shuffleLabels = {'noShuffle','shuffle'};
    condHists = NaN(2,numel(condUnits),numel(eventFieldnames_wFake),numel(freqList),nBins);
    condCounts = zeros(2,numel(condUnits),numel(eventFieldnames_wFake),numel(freqList),nBins);
    for iShuffle = 1:2
        for iCond = 1:3
            for iEvent = 1:numel(eventFieldnames_wFake)
                spikeAngles = [unitAngles{iShuffle,condUnits{iCond},iEvent}];
                for iFreq = 1:numel(freqList)
                    theseAngles = spikeAngles(iFreq,:);
                    counts = histcounts(theseAngles,binEdges);
                    condHists(iShuffle,iCond,iEvent,iFreq,:) = counts;
                    for iNeuron = condUnits{iCond}
                        neuronAngles = unitAngles{iShuffle,iNeuron,iEvent}(iFreq,:);
                        counts = histcounts(neuronAngles,binEdges);
                        [~,k] = max(counts);
                        condCounts(iShuffle,iCond,iEvent,iFreq,k) = condCounts(iShuffle,iCond,iEvent,iFreq,k) + 1;
                    end
                end
            end
        end
    end
end

if doPlot_lines
    doCountMethod = true;
    showShuffle = true;
    h = ff(1400,800);
    rows = 6;
    cols = 8;
    delta_range = 1:9;
    gammah_range = 26:30;
    for iCond = 1:3
        for iShuffle = 1:2
            for iEvent = 1:8
                histMat = NaN(numel(freqList),nBins*2);
                for iFreq = 1:numel(freqList)
                    if doCountMethod
                        thisHist = squeeze(condCounts(iShuffle,iCond,iEvent,iFreq,:)) ./ numel(condUnits{iCond});
                        histMat(iFreq,:) = repmat(thisHist,[2,1]);
                        zLims = [0 0.2];
                        ylabelVal = 'Frac. of Units';
                    else
                        theseHist = squeeze(condHists(iShuffle,iCond,iEvent,iFreq,:))';
                        histStd = (std(theseHist));
                        histMean = (mean(theseHist));
                        thisHist = (squeeze(condHists(iShuffle,iCond,iEvent,iFreq,:)) - histMean) ./ histStd;
                        zLims = [-3 3];
                        ylabelVal = 'Z of Frac.';
                    end
                    histMat(iFreq,:) = repmat(thisHist,[2,1]);
                end
                delta_lines = mean(histMat(delta_range,:));
                gammah_lines = mean(histMat(gammah_range,:));
                if iShuffle == 1 || showShuffle
                    subplot(rows,cols,prc(cols,[iCond*2-(2-iShuffle),iEvent]));
                    imagesc(histMat);
                    set(gca,'ydir','normal')
                    colormap(gca,jet);
                    caxis(zLims);
                    xticks([1,6.5,12.5,18.5,24]);
                    xticklabels([]);
%                     xticklabels([0 180 360 540 720]);
                    xtickangle(30);
%                     xlabel('Spike phase (deg)');
                    yticks(ylim);
                    yticklabels([freqList(1),freqList(end)]);
                    if iEvent == 1
                        ylabel('Freq. (Hz)');
                    end
                    if iEvent == numel(eventFieldnames_wFake)
                        cbAside(gca,ylabelVal,'k');
                    end
                    if iCond == 1 && iShuffle == 1
                        title({eventFieldnames_wFake{iEvent},[condLabels{iCond}]});
                    else
                       title(condLabels{iCond});
                    end
                    
                    lineStyle = '-';
                    lineWidth = 2;
                else
                    lineStyle = ':';
                    lineWidth = 0.5;
                end
                
                if ~showShuffle
                    subplot(rows,cols,prc(cols,[iCond*2,iEvent]));
                    plot(delta_lines,lineStyle,'color','b','lineWidth',lineWidth);
                    hold on;
                    plot(gammah_lines,lineStyle,'color','r','lineWidth',lineWidth);
                    xticks([1,6.5,12.5,18.5,24]);
                    if iEvent == 1
                        ylabel(ylabelVal);
                    end
                    if iCond == 3
                        xticklabels([0 180 360 540 720]);
                        xlabel('Spike phase (deg)');
                    else
                        xticklabels([]);
                    end
                    ylim(zLims);
                    yticks(sort(unique([0,ylim])));
                    grid on;
                end
            end
        end
    end
    if ~showShuffle
        legend({'delta','gamma','delta_{shuff}','gamma_{shuff}'});
    end
    set(gcf,'color','w');
end

if doPlot_shuffle
    h = ff(1400,800);
    rows = 6;
    cols = 8;
    zLims = [-3 3];
    for iCond = 1:3
        for iShuffle = 1:2
            for iEvent = 1:8
                subplot(rows,cols,prc(cols,[iCond*2-(2-iShuffle),iEvent]));
                histMat = NaN(numel(freqList),nBins*2);
                for iFreq = 1:numel(freqList)
                    theseHist = squeeze(condHists(iShuffle,iCond,iEvent,iFreq,:))';
                    histStd = (std(theseHist));
                    histMean = (mean(theseHist));
                    thisHist = (squeeze(condHists(iShuffle,iCond,iEvent,iFreq,:)) - histMean) ./ histStd;
                    histMat(iFreq,:) = repmat(thisHist,[2,1]);
                end
                imagesc(histMat);
                set(gca,'ydir','normal')
                colormap(gca,jet);
                caxis(zLims);
                xticks([1,6.5,12.5,18.5,24]);
                xticklabels([0 180 360 540 720]);
                xtickangle(30);
                xlabel('Spike phase (deg)');
                yticks(ylim);
                yticklabels([freqList(1),freqList(end)]);
                ylabelVal('Freq. (Hz)');
                if iEvent == numel(eventFieldnames_wFake)
                    cbAside(gca,'Z','k');
                end
                title({eventFieldnames_wFake{iEvent},[condLabels{iCond},' ',shuffleLabels{iShuffle}]});
            end
        end
    end
    set(gcf,'color','w');
end