function burstEventAnalysis(sessionConf)
% the zscore is calculated by adding more events at random times to each
% trial. The added events are at random times.

    pethHalfWidth = 1; % seconds
    histBin = 20;
    fontSize = 10;

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
%         for ii=1:length(burstEpochs)
%             burstTs = [burstTs; ts(burstEpochs(ii,1):burstEpochs(ii,2))];
%         end
        burstIdx = burstEpochs(:,1);
        burstTs = ts(burstIdx);
    %     burstLocs = round(burstTs * sessionConf.Fs);

        pethCell = {};
        initCell = true;
        correctTrials = find([trials.correct]==1);
        countedTrials = 0;
        
        randomEvents = 100;
        a = ts(1) + pethHalfWidth;
        b = ts(end) - pethHalfWidth;
%         randomTs = a + (b-a).*rand(randomEvents,length(correctTrials));
        
        for iTrial=correctTrials
            eventFieldnames = fieldnames(trials(iTrial).timestamps);
            for iField=1:length(eventFieldnames) + randomEvents
                % randomEvents are appended in order to create the zscore
                % distribution; this could be done better/multiple ways
                if iField <= length(eventFieldnames)
                    eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});
                else
                    eventTs = a + (b-a).*rand(1,1);
%                     eventTs = randomTs(iTrial,iField-length(eventFieldnames)); % could just create rand on fly?
                end
                
                if initCell
                    pethCell{iField,1} = []; % all spikes
                    pethCell{iField,2} = []; % burst events
                end
                if isempty(eventTs) % a few 'correct' trials had an empty tone, not sure why
                    continue;
                end
                % all spikes
                pethCell{iField,1} = [pethCell{iField,1}; ts(ts < eventTs+pethHalfWidth & ts >= eventTs-pethHalfWidth) - eventTs];
                % burst events
                pethCell{iField,2} = [pethCell{iField,2}; burstTs(burstTs < eventTs+pethHalfWidth & burstTs >= eventTs-pethHalfWidth) - eventTs];
            end
            initCell = false;
            countedTrials = countedTrials + 1;
        end
        
        % compile all of the histBin counts into single arrays to compute
        % the zscore
        allTsCounts = [];
        allTsBurstCounts = [];
        for iField=1:size(pethCell,1)
            [tsCounts,tsCenters] = hist(pethCell{iField,1},histBin);
            allTsCounts = [allTsCounts tsCounts];
            [tsBurstCounts,~] = hist(pethCell{iField,2},histBin);
            allTsBurstCounts = [allTsBurstCounts tsBurstCounts];
        end
        zTs = zscore(allTsCounts);
        zTs = reshape(zTs,histBin,length(zTs)/histBin);
        zBurstTs = zscore(allTsBurstCounts);
        zBurstTs = reshape(zBurstTs,histBin,length(zBurstTs)/histBin);

% %         h = formatSheet();
% %         spikesPerSecondFactor = countedTrials * (pethHalfWidth * 2); % total seconds of data being presented
% %         for iField=1:size(pethCell,1)
% %             subplot(4,2,iField);
% %             [tsCounts,tsCenters] = hist(pethCell{iField,1},histBin);
% %             [tsBurstCounts,~] = hist(pethCell{iField,2},histBin);
% %             plotyy(tsCenters,(tsCounts/spikesPerSecondFactor)*histBin,tsCenters,(tsBurstCounts/spikesPerSecondFactor)*histBin);
% %             xlabel('Time (s)','FontSize',fontSize);
% %             ylabel('Spikes/Second','FontSize',fontSize);
% %             title([strrep(neuronName,'_','-'),' ',eventFieldnames{iField}]);
% %             if iField==1
% %                 legend('all spikes','burst spikes','location','northwest')
% %             end
% %         end
% %         saveas(h,fullfile(figurePath,[neuronName,'_burstEvents']),'pdf');
% %         close(h);
        save(fullfile(figurePath,[neuronName,'_burstEvents'])); % mat file, could be more restrictive for necessary variables
        disp('end');
    end
end
