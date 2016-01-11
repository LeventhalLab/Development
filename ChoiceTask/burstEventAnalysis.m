function burstEventAnalysis(sessionConf)

    pethHalfWidth = 1; % seconds
    histBin = 50;
    fontSize = 12;

    leventhalPaths = buildLeventhalPaths(sessionConf);
    matFiles = dir(fullfile(leventhalPaths.finished,'*.mat'));

    figurePath = fullfile(leventhalPaths.graphs,'burstEventAnalysis');
    if ~isdir(figurePath)
        mkdir(figurePath);
    end

    if isempty(matFiles)
        error('NOMATFILE','No .mat file found');
    else
        % load the nexStruct (first file)
        load(fullfile(leventhalPaths.finished,matFiles(1).name),'nexStruct');
    end

    % load log from raw directory
    logFile = dir(fullfile(leventhalPaths.rawdata,'*.log'));
    fnames = {logFile.name};
    logFile = cellfun(@isempty,regexp(fnames,'old.log')); %logical
    logFile = fnames{logFile};

    logData = readLogData(fullfile(leventhalPaths.rawdata,logFile));
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);

    % compiledEvents = loadCompiledEvents();
    % eventFieldnames = fieldnames(compiledEvents);

    neuronNames = {};
    for iNeuron=1:length(nexStruct.neurons)
        neuronNames{iNeuron} = nexStruct.neurons{iNeuron}.name;
    end
    neuronIds = listdlg('PromptString','Select neurons:',...
                'SelectionMode','multiple','ListSize',[200 200],...
                'ListString',neuronNames);

    for iNeuron=neuronIds
        neuronName = nexStruct.neurons{iNeuron}.name;
        [tetrodeName,tetrodeId] = getTetrodeInfo(neuronName);
        disp(neuronName);
        disp(tetrodeName);
        % do burst detection
        ts = nexStruct.neurons{iNeuron,1}.timestamps;
        %[] save figure?
        xBursts = [0.0035 0.0070 0.0200]; % experimentally determined
        [burstEpochs,burstFreqs] = findBursts(ts,xBursts);
        burstTs = [];
        for ii=1:length(burstEpochs)
            burstTs = [burstTs; ts(burstEpochs(ii,1):burstEpochs(ii,2))];
        end
    %     burstIdx = burstEpochs(:,1);
    %     burstLocs = round(burstTs * sessionConf.Fs);

        pethCell = {};
        initCell = true;
        correctTrials = find([trials.correct]==1);
        countedTrials = 0;
        for iTrial=correctTrials
            eventFieldnames = fieldnames(trials(iTrial).timestamps);
            for iField=1:length(eventFieldnames)
                eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});
                if initCell
                    pethCell{iField,1} = [];
                    pethCell{iField,2} = [];
                end
                if isempty(eventTs) % a few 'correct' trials had an empty tone, not sure why
                    continue;
                end
                pethCell{iField,1} = [pethCell{iField,1}; ts(ts < eventTs+pethHalfWidth & ts >= eventTs-pethHalfWidth) - eventTs];
                pethCell{iField,2} = [pethCell{iField,2}; burstTs(burstTs < eventTs+pethHalfWidth & burstTs >= eventTs-pethHalfWidth) - eventTs];
            end
            initCell = false;
            countedTrials = countedTrials + 1;
        end

        h = formatSheet();
        spikesPerSecondFactor = countedTrials * (pethHalfWidth * 2); % total seconds of data being presented
        for iField=1:size(pethCell,1)
            subplot(4,2,iField);
            [tsCounts,tsCenters] = hist(pethCell{iField,1},histBin);
            [tsBurstCounts,~] = hist(pethCell{iField,2},histBin);
            plotyy(tsCenters,(tsCounts/spikesPerSecondFactor)*histBin,tsCenters,(tsBurstCounts/spikesPerSecondFactor)*histBin);
            xlabel('Time (s)','FontSize',fontSize);
            ylabel('Spikes/Second','FontSize',fontSize);
            title([strrep(neuronName,'_','-'),' ',eventFieldnames{iField}]);
            if iField==1
                legend('all spikes','burst spikes','location','northwest')
            end
        end
        saveas(h,fullfile(figurePath,[neuronName,'_burstEvents']),'pdf');
        close(h);
        save(fullfile(figurePath,[neuronName,'_burstEvents']));
        disp('end');
    end
end
