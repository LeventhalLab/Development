function eventScreenshots(sessionConf,nexData)
behaviorStartTime = getBehaviorStartTime(nexData);

leventhalPaths = buildLeventhalPathsv2(sessionConf);
eventScreenshotsPath = fullfile(leventhalPaths.graphs,'eventScreenshots');
if ~isdir(eventScreenshotsPath)
    mkdir(eventScreenshotsPath);
end

aviFile = dir(fullfile(leventhalPaths.rawdata,'*.avi'));
if isempty(aviFile)
    error('missingAviFile');
end
video = VideoReader(fullfile(leventhalPaths.rawdata,aviFile(1).name));

compiledEvents = loadCompiledEvents();
eventFieldnames = fieldnames(compiledEvents);
for iEvent=1:length(eventFieldnames)
    if strcmp(eventFieldnames(iEvent),'noseIn') || strcmp(eventFieldnames(iEvent),'foodportOn')
        eventTs = compileEventTs(nexData,compiledEvents,eventFieldnames,iEvent);
    else
        continue;
    end
    randomTs = datasample(eventTs,10) - behaviorStartTime;
    for iTs=1:length(randomTs)
        if(randomTs(iTs) <= video.Duration)
            im = read(video,20*randomTs(iTs));
            imwrite(im,fullfile(eventScreenshotsPath,...
                strcat(eventFieldnames{iEvent},'_',num2str(iTs),'.jpg')));
        end
    end
end