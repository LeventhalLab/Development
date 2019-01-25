% % load('entrainmentHighRes_setup')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'LFPfiles_local')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'all_ts')
% load('session_20180919_NakamuraMRL.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181212_spikePhaseHist_NewSurrogates.mat', 'eventFieldnames')
freqList = logFreqList([1 200],30);

tWindow = 0.5;
eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};

if ismac
    dataPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/Ray_LFPspikeCorr';
else
    dataPath = 'C:\Users\dleventh\Documents\Data\ChoiceTask\LFPs\datastore\Ray_LFPspikeCorr';
end
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainmentHighRes';

doCompile = false;
doConds = false;
doPlot = true;

loadedFile = [];
neuronCount = 0;
if doCompile
    unitAngles = {};
    unitAngles_shuffle = {};
    for iNeuron = 1:13%numel(all_ts)
        neuronCount = neuronCount + 1;
        load(fullfile(dataPath,['tsPeths_u',num2str(iNeuron,'%03d')]),'tsPeths');
        LFPfile = fullfile(dataPath,['Wz_phase_s',num2str(LFP_lookup(iNeuron),'%02d')]);
        if isempty(loadedFile) || ~strcmp(loadedFile,LFPfile)
            load(LFPfile,'Wz_phase');
        end
        disp(['Compiling iNeuron ',num2str(iNeuron,'%03d')]);
        
        for iShuffle = 1:2
            if iShuffle == 1
                trialOrder = 1:size(tsPeths,1);
            else
                trialOrder = randsample(1:size(tsPeths,1),size(tsPeths,1));
            end
            for iEvent = 1:numel(eventFieldnames_wFake)
                spikeAngles = NaN(size(Wz_phase,4),0);
                startIdx = ones(size(Wz_phase,4));
                for iTrial = 1:size(tsPeths,1)
                    theseSpikes = tsPeths{trialOrder(iTrial),iEvent};
                    for iFreq = 1:size(Wz_phase,4)
                        spikeIdx = logical(histcounts(theseSpikes,linspace(-tWindow,tWindow,size(Wz_phase,2)+1)));
                        endIdx = startIdx(iFreq) + sum(spikeIdx);
                        spikeAngles(iFreq,startIdx(iFreq):endIdx-1) = Wz_phase(iEvent,spikeIdx,iTrial,iFreq);
                        startIdx(iFreq) = endIdx;
                    end
                end
                unitAngles{iShuffle,iNeuron,iEvent} = spikeAngles;
            end
        end
    end
% %     save('entrainmentHighRes_setup','unitAngles','-append');
end

% !! might want to make angle count equal across conditions?
if doConds
    nBins = 12;
    binEdges = linspace(-pi,pi,nBins+1);
%     condUnits = {1:numel(all_ts),dirSelUnitIds,ndirSelUnitIds};
    condUnits = {1:13,1:5,6:13};
    condLabels = {'allUnits','dirSel','ndirSel'};
    shuffleLabels = {'noShuffle','shuffle'};
    condHists = NaN(2,numel(condUnits),numel(eventFieldnames_wFake),numel(freqList),nBins);
    for iShuffle = 1:2
        for iCond = 1:3
            for iEvent = 1:numel(eventFieldnames_wFake)
                spikeAngles = [unitAngles{iShuffle,condUnits{iCond},iEvent}];
                for iFreq = 1:numel(freqList)
                    theseAngles = spikeAngles(iFreq,:);
                    counts = histcounts(theseAngles,binEdges);
                    condHists(iShuffle,iCond,iEvent,iFreq,:) = counts;
                end
            end
        end
    end
end

if doPlot
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
                ylabel('Freq. (Hz)');
                if iEvent == numel(eventFieldnames_wFake)
                    cbAside(gca,'Z','k');
                end
                title({eventFieldnames_wFake{iEvent},[condLabels{iCond},' ',shuffleLabels{iShuffle}]});
            end
        end
    end
end