function lfpEventAnalysis(sessionConf)

decimateFactor = 10;
scalogramWindow = 2; % seconds
plotEventIdx = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
fpass = [1 100];

leventhalPaths = buildLeventhalPaths(sessionConf);
rawDataPath = fullfile(sessionConf.nasPath,sessionConf.ratID,[sessionConf.ratID,'-rawdata']);
rawDirs = dir(rawDataPath);
rawDirs = {rawDirs.name};

dirIds = listdlg('PromptString','Select directories:',...
                'SelectionMode','multiple','ListSize',[200 200],...
                'ListString',rawDirs);
            
for iDir=dirIds
    disp(['Working on ',rawDirs{iDir}]);
    sessionConf = exportSessionConf(rawDirs{iDir},'nasPath',sessionConf.nasPath);
    leventhalPaths = buildLeventhalPaths(sessionConf);
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    
    % get events
    % load log from raw directory
    matFiles = dir(fullfile(leventhalPaths.finished,'*.mat'));
    if isempty(matFiles)
        error('NOMATFILE','No .mat file found');
    else
        % load the nexStruct (first file)
        load(fullfile(leventhalPaths.finished,matFiles(1).name),'nexStruct');
    end

    logFile = dir(fullfile(leventhalPaths.rawdata,'*.log'));
    fnames = {logFile.name};
    logFile = cellfun(@isempty,regexp(fnames,'old.log')); %logical
    logFile = fnames{logFile};

    logData = readLogData(fullfile(leventhalPaths.rawdata,logFile));
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    correctTrials = find([trials.correct]==1);
    
    
    for iTet=1:length(tetrodes)
        lfpChannel = sessionConf.lfpChannels(tetrodes(iTet));
        [sev,header] = read_tdt_sev(fullSevFiles{sessionConf.chMap(5,lfpChannel+1)});
        sev = decimate(double(sev),decimateFactor);
        Fs = header.Fs/decimateFactor;
        scalogramWindowSamples = round(scalogramWindow * Fs);
        allScalograms = [];
        for iField=plotEventIdx
            for iTrial=correctTrials
                eventFieldnames = fieldnames(trials(iTrial).timestamps);
                eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});
                eventSample = round(eventTs * Fs);
                data(:,iTrial) = sev((eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1));
            end
            [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass);
            allScalograms(iField,:,:) = squeeze(mean(abs(W).^2, 2))';
        end
        t = [0:size(W,1)-1]./Fs;
        for iField=plotEventIdx
            figure;
            imagesc(t,freqList,log(squeeze(allScalograms(iField,:,:))))
            ylabel('Frequency (Hz)')
            xlabel('Time (s)');
            set(gca, 'YDir', 'normal')
            colormap(jet);
            title([eventFieldnames{iField}]);
        end
        disp('here');
    end
end