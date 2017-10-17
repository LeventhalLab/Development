function imageCount = sideOutDirection(trials,nexData,videoPath)
behaviorStartTime = getBehaviorStartTime(nexData);
video = VideoReader(videoPath);
savePath = fileparts(videoPath);
nImages = 5;
nBetween = 5;
imageCount = 0;

for iTrial = 1:numel(trials)
    disp(['Trial: ',num2str(iTrial,'%03d')]);
    if isfield(trials(iTrial).timestamps,'sideOut')
        sideOutVideoTs = trials(iTrial).timestamps.sideOut - behaviorStartTime;
        startFrame = round(video.FrameRate * sideOutVideoTs);
        for iImages = 1:nImages
            curFrame = startFrame + (nBetween * (iImages - 1));
            im = read(video,curFrame);
            im = insertText(im,[0,0],['trial: ',num2str(iTrial),', image: ',num2str(iImages),', frame: ',num2str(curFrame)]);
            imwrite(im,fullfile(savePath,['trial',num2str(iTrial,'%03d'),'_image',num2str(iImages),'_frame',num2str(curFrame),'.jpg']));
            imageCount = imageCount + 1;
        end
    end
end