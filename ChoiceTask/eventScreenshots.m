function eventScreenshots(sessionConf,nexStruct)
behaviorStartTime = behaviorStartTime(nexStruct);

leventhalPaths = buildLeventhalPaths(sessionConf);
eventScreenshotsPath = fullfile(leventhalPaths.graphs,'eventScreenshots');
if ~isdir(eventScreenshotsPath)
    mkdir(eventScreenshotsPath);
end

aviFile = dir(fullfile(leventhalPaths.rawdata,'*.avi'));

if ~isempty(aviFile)
    aviFile = fullfile(leventhalPaths.rawData,aviFile(1).name);
    video = VideoReader(aviFile);
    
end