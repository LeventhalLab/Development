function videoFiles = chopVideos(filename,savePath,trialTimes)

v = VideoReader(filename);
frame = readFrame(v);
disp('select behavior ROI');
h = figure;
imshow(frame);
pos = getPosition(imrect);
close(h);

if ~exist(savePath)
    mkdir(savePath);
end

for iTrial = 1:size(trialTimes,1)
    saveFile = fullfile(savePath,['trial',num2str(iTrial,'%02d')]);
    newVideo = VideoWriter(saveFile,'MPEG-4');
    newVideo.Quality = 100;
    newVideo.FrameRate = v.FrameRate;
    open(newVideo);
    
    v.CurrentTime = trialTimes(iTrial,1);
    while hasFrame(v)
        disp(num2str(v.CurrentTime));
        frame = readFrame(v);
        cropFrame = imcrop(frame,pos);
        writeVideo(newVideo,cropFrame);
        if v.CurrentTime >= trialTimes(iTrial,2)
            break;
        end
    end
    close(newVideo);
    videoFiles{iTrial} = [saveFile,'.mp4'];
end