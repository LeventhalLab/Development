function trialActograms = processActograms(savePath,resizePx)
cmapIM = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/Optogenetics/OpenField/helpers/stoplight.jpg';
doDebug = true;
doVideo = true;
if doVideo % force
    doDebug = true;
end

trialVideos = dir(fullfile(savePath,'*.mp4'));
binaryT = 0.5;
contrastMap = [0.1 0.4];
SE5 = strel('disk',5);
SE7 = strel('disk',7);

if doDebug
    actogramPath = fullfile(savePath,'actograms');
    if ~exist(actogramPath)
        mkdir(actogramPath);
    end
end

for iVideo = 1:numel(trialVideos)
    filename = trialVideos(iVideo).name;
    trialNumber = str2double(filename(6:7));
    
    v = VideoReader(fullfile(savePath,filename));
    numFrames = ceil(v.FrameRate * v.Duration);
    traceColors = mycmap(cmapIM,numFrames);
    
    iFrame = 0;
    prevFrame = [];
    allCenters = [];
    if doDebug
        h = figuree(400,400);
        if doVideo
            saveFile = fullfile(actogramPath,['trial',num2str(iVideo,'%02d'),'_actogram']);
            newVideo = VideoWriter(saveFile,'MPEG-4');
            newVideo.Quality = 90;
            newVideo.FrameRate = v.FrameRate;
            open(newVideo);
        end
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
        frame_dilate = imdilate(frame_complement,SE5);
        frame_erode = imerode(frame_dilate,SE7);
        
        props = regionprops(frame_erode,'Area','BoundingBox','Centroid','Eccentricity','Extent');
        [~,k] = max([props.Area]);
        % try to fix if too many pixels are bounded
        if props(k).Extent < 0.1
            props(k).Area = 0; % remove
            [~,k] = max([props.Area]);
        end
        allCenters(iFrame,:,:) = props(k).Centroid;
        
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
            imshow(frame_erode);
            title('binary');
            set(gcf,'color','w');
            
            drawnow;
            
            if doVideo
                hFrame = getframe(h);
                arrayfun(@cla,findall(0,'type','axes'));
                writeVideo(newVideo,hFrame);
            end
        end
    end
    
    if doDebug
        close(h);
        if doVideo
            close(newVideo);
        end
    end
    
    trialActograms{iVideo,1} = filename;
    trialActograms{iVideo,2} = trialNumber;
    trialActograms{iVideo,3} = allCenters;
end