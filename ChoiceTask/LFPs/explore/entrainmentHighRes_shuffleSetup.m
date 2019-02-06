freqList = logFreqList([1 200],30);
tWindow = 0.5;
eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};

doSetup = false;
doCompile = true;

if doSetup
    useFreqs = 1:8;
    useEvents = [4,8];
    onlyFutureSpikes = true;
    nShuffle = 200;
    loadedFile = [];
    unitAngles_mean = {};
    for iNeuron = 1:numel(all_ts)
        tsFile = fullfile(dataPath,['tsPeths_u',num2str(iNeuron,'%03d')]);
        load(tsFile,'tsPeths');
%         LFPfile = fullfile(dataPath,['Wz_phase_alt_s',num2str(LFP_lookup_alt(iNeuron),'%03d')]);
        LFPfile = fullfile(dataPath,['Wz_phase_s',num2str(LFP_lookup(iNeuron),'%03d')]);
        if isempty(loadedFile) || ~strcmp(loadedFile,LFPfile)
            fprintf('--> loading LFP...\n');
            load(LFPfile,'Wz_phase');
            loadedFile = LFPfile;
        end
        FR = numel([tsPeths{:,1}])/size(tsPeths,1);
        fprintf('iNeuron: %03d, FR: %2.1f\n',iNeuron,FR);
        
        for iShuffle = 1:nShuffle+1
            if iShuffle == 1
                trialOrder = 1:size(tsPeths,1);
            else
                trialOrder = randsample(1:size(tsPeths,1),size(tsPeths,1));
            end
           
            for iEvent = 1:numel(useEvents)
                spikeAngles = NaN(numel(useFreqs),0);
                startIdx = ones(numel(useFreqs));
                for iTrial = 1:size(tsPeths,1)
                    theseSpikes = tsPeths{trialOrder(iTrial),useEvents(iEvent)};
                    if onlyFutureSpikes
                        theseSpikes(theseSpikes < 0) = []; % !! ONLY 0-0.5s
                    end
                    for iFreq = 1:numel(useFreqs)
                        % identifies bins (1-Wlength) with spikes, uses that to fill spikeAngles
                        spikeIdx = logical(histcounts(theseSpikes,linspace(-tWindow,tWindow,size(Wz_phase,2)+1)));
                        endIdx = startIdx(iFreq) + sum(spikeIdx);
                        spikeAngles(iFreq,startIdx(iFreq):endIdx-1) = Wz_phase(useEvents(iEvent),spikeIdx,iTrial,useFreqs(iFreq));
                        startIdx(iFreq) = endIdx;
                    end
                end
                if isempty(spikeAngles(:))
                    unitAngles_mean{iShuffle,iNeuron,iEvent} = NaN;
                else
                    unitAngles_mean{iShuffle,iNeuron,iEvent} = circ_mean(spikeAngles(:));
                end
            end
        end
    end
end

allUnits = 1:366;
condUnits = {allUnits,find(~ismember(allUnits,[dirSelUnitIds,ndirSelUnitIds])),ndirSelUnitIds,dirSelUnitIds};
condLabels = {'allUnits','other','ndirSel','dirSel'};
condLabels_wCount = {['allUnits (n = ',num2str(numel(condUnits{1})),')'],...
    ['other (n = ',num2str(numel(condUnits{2})),')'],...
    ['ndirSel (n = ',num2str(numel(condUnits{3})),')'],...
    ['dirSel (n = ',num2str(numel(condUnits{4})),')']};
shuffleLabels = {'noShuffle','shuffle'};
eventLabels = {'Nose Out','Inter-trial'};
useEvents = [4,8];

if doCompile
    all_condMean = {};
    for iCond = 1:numel(condUnits)
        condMean = [];
        for iShuffle = 1:2
            for iEvent = 1:numel(useEvents)
                neuronCount = 0;
                for iNeuron = condUnits{iCond}
                    if iShuffle == 1
                        neuronAngles = unitAngles_mean{iShuffle,iNeuron,iEvent};
                    else
                        neuronAngles = circ_mean([unitAngles_mean{2:end,iNeuron,iEvent}]');
                    end
                    if ~isnan(neuronAngles)
                        neuronCount = neuronCount + 1;
                        condMean(iShuffle,neuronCount,iEvent) = neuronAngles;
                    end
                end
            end
        end
        all_condMean{iCond} = condMean;
    end
end