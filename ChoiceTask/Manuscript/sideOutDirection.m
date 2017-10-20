function sideOutDirection(analysisConf,all_trials)
    excludeSessions = {'R0142_20161207a','R0117_20160508a','R0117_20160510a'}; % corrupt video
    % get all unique sessions
    [sessionNames,IA] = unique(analysisConf.sessionNames);
    for iSession = 1:numel(sessionNames)
        sessionConf = analysisConf.sessionConfs{IA(iSession)};
        if ismember(sessionConf.sessions__name,excludeSessions)
            continue;
        end
        nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
        if exist(nexMatFile,'file')
            disp(['Loading ',nexMatFile]);
            load(nexMatFile);
        else
            error('No NEX .mat file');
        end
        write_sideOutDirection(sessionConf,nexStruct,all_trials{IA(iSession)});
    end
end

function recordMatrix = write_sideOutDirection(sessionConf,nexData,trials)
    recordMatrix = zeros(numel(trials),1);
    behaviorStartTime = getBehaviorStartTime(nexData);
    leventhalPaths = buildLeventhalPathsv2(sessionConf);
    savePath = fullfile(leventhalPaths.graphs,'sideOutScreenshots');
    if ~isdir(savePath)
        mkdir(savePath);
    end
    aviFile = dir(fullfile(leventhalPaths.rawdata,'*.avi'));
    videoPath = fullfile(leventhalPaths.rawdata,aviFile(end).name);
    disp(['Reading ',videoPath]);
    try
        video = VideoReader(videoPath);
    catch ME
        return;
    end
    
    resizeScale = 0.25;
    nImages = 5;
    nBetween = 5;
    imageCount = 0;
    for iTrial = 1:numel(trials)
        disp(['Trial: ',num2str(iTrial,'%03d')]);
        if isfield(trials(iTrial).timestamps,'sideOut')
            recordMatrix(iTrial,1) = 1;
            sideOutVideoTs = trials(iTrial).timestamps.sideOut - behaviorStartTime;
            startFrame = round(video.FrameRate * sideOutVideoTs);
            for iImages = 1:nImages
                curFrame = startFrame + (nBetween * (iImages - 1));
                im = imresize(read(video,curFrame),resizeScale);
                im = insertText(im,[0,0],['trial: ',num2str(iTrial),', image: ',num2str(iImages),', frame: ',num2str(curFrame)]);
                imwrite(im,fullfile(savePath,['trial',num2str(iTrial,'%03d'),'_image',num2str(iImages),'_frame',num2str(curFrame),'.jpg']));
                imageCount = imageCount + 1;
            end
        end
    end
    csvwrite(fullfile(savePath,[sessionConf.sessions__name,'_sideOutAnalysis.csv']),recordMatrix);
end