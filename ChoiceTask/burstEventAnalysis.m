function burstEventAnalysis(sessionConf)

pethHalfWidth = 1; % seconds
histBin = 75;
fontSize = 12;

leventhalPaths = buildLeventhalPaths(sessionConf);
matFiles = dir(fullfile(leventhalPaths.finished,'*.mat'));

if isempty(matFiles)
    error('NOMATFILE','No .mat file found');
else
    % load the nexStruct (first file)
    load(fullfile(leventhalPaths.finished,matFiles(1).name),'nexStruct');
end

% load log from raw directory
logFile = dir(fullfile(leventhalPaths.rawdata,'*.log'));
logData = readLogData(fullfile(leventhalPaths.rawdata,logFile(1).name));
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
    [burstEpochs,burstFreqs] = findBursts(ts);
    burstTs = [];
    for ii=1:length(burstEpochs)
        burstTs = [burstTs; ts(burstEpochs(ii,1):burstEpochs(ii,2))];
    end
%     burstIdx = burstEpochs(:,1);
%     burstLocs = round(burstTs * sessionConf.Fs);
    
    pethCell = {};
    initCell = true;
    for iTrial=find([trials.correct]==1)
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
    end
    
    figure('position',[0 0 900 500]);
    for iField=1:size(pethCell,1)
        subplot(4,2,iField);
        [tsCounts,tsCenters] = hist(pethCell{iField,1},histBin);
        [tsBurstCounts,~] = hist(pethCell{iField,2},histBin);
        plotyy(tsCenters,tsCounts,tsCenters,tsBurstCounts);
        xlabel('Time (s)','FontSize',fontSize);
        ylabel('Spikes/Second','FontSize',fontSize);
    end
%     spikesPerSecond = (counts/((pethHalfWidth*2)/histBin))/length(eventTs);
    disp('end');
end