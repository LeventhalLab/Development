function lfpEventAnalysis(sessionConf,tetrodes)
% UNFINISHED!
decimateFactor = 10;

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
        for iTrial=correctTrials
            
        end
    end
end