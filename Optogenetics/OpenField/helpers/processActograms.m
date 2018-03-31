function trialActograms = processActograms(savePath,resizePx)
doDebug = true;

trialVideos = dir(fullfile(savePath,'*.mp4'));
binaryT = 0.5;
contrastMap = [0.1 0.4];
SE = strel('disk',5);

for iVideo = 1%:numel(trialVideos)
    filename = trialVideos(iVideo).name;
    trialNumber = str2double(filename(6:7));
    
    v = VideoReader(fullfile(savePath,filename));
    numFrames = ceil(v.FrameRate * v.Duration);
    traceColors = cool(numFrames);
    
    iFrame = 0;
    frameData = [];
    prevFrame = [];
    allCenters = [];
    if doDebug
        figuree(800,800);
    end
    
    while hasFrame(v)
        disp(num2str(v.CurrentTime));
        
        iFrame = iFrame + 1;
        
        frame = readFrame(v);
        frame_resize = imresize(frame,[resizePx NaN]);
        frame_gray = rgb2gray(frame_resize);
        frame_contrast = imadjust(frame_gray,contrastMap);
        frame_binary = imbinarize(frame_contrast,binaryT);
        frame_complement = imcomplement(frame_binary);
        frame_dilate = imdilate(frame_complement,SE);
        
        props = regionprops(frame_dilate,'Area','BoundingBox','Centroid');
        [~,k] = max([props.Area]);
        allCenters(iFrame,:) = props(k).Centroid;
        
        if doDebug
            subplot(221);
            IM = insertShape(frame_resize,'Rectangle',props(k).BoundingBox,'Color','r');
            IM = insertShape(IM,'FilledCircle',[props(k).Centroid 5],'Color','r');
            imshow(IM);
            title('resized');
            
            subplot(222);
            imshow(frame_gray);
            hold on;
            scatter(allCenters(:,1),allCenters(:,2),25,traceColors(1:size(allCenters,1),:),'filled');
            if iFrame > 1
                z = smoothn({allCenters(:,1),allCenters(:,2)},'robust');
                plot(z{1},z{2},'r');
            end
            title('gray');
            
            subplot(223);
            imshow(frame_contrast);
            title('contrast');
            
            subplot(224);
            imshow(frame_dilate);
            title('diff(prevFrame)');
            set(gcf,'color','w');
            drawnow;
        end
        frameData(iFrame,:,:) = frame_binary; % store binary, old: abs(mean2(frame - prevFrame));
    end
    
    trialActograms{iVideo,1} = filename;
    trialActograms{iVideo,2} = trialNumber;
    trialActograms{iVideo,3} = allCenters;
end