function lfpVideo(sessionConf,nexData,lfpChannels)
    tic
    % get video
    leventhalPaths = buildLeventhalPaths(sessionConf);
    videos = dir(fullfile(leventhalPaths.rawdata,'*.avi'));
    if isempty(videos)
        error('novideo');
    end
    video = VideoReader(fullfile(leventhalPaths.rawdata,videos(1).name));
    % [] select nose ports, food port, house light?
    h = figure;
    imshow(read(video,20));
    [xEventCoords,yEventCoords] = ginput(7);
    close(h);
    
    % setup new video
    lfpVideoPath = fullfile(leventhalPaths.graphs,'lfpVideos');
    if ~isdir(lfpVideoPath)
        mkdir(lfpVideoPath);
    end
    saveVideoAs = fullfile(lfpVideoPath,[sessionConf.sessionName,'_',strrep(num2str(lfpChannels),'  ','-')]);
    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = video.FrameRate;
    open(newVideo);

    plotHalfWidthSec = 4; % seconds
    behaviorStartTime = getBehaviorStartTime(nexData);
    iFrameStart = ceil((plotHalfWidthSec + behaviorStartTime) * video.FrameRate);
    
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    
    videoDimDivider = 3;
    figureHeight = 800; % pixels
    subplotHeight = (figureHeight - ceil(video.Height/videoDimDivider)) / length(lfpChannels);
    h = figure('Position',[0 0 ceil(video.Width/videoDimDivider) figureHeight]);
    
    hicutoff = 500;
    decimateFactor = floor((sessionConf.Fs/2) / hicutoff); % optimized
    dFs = sessionConf.Fs / decimateFactor;
    movingwin=[0.5 0.05];
    params.fpass = [0 80];
    params.tapers = [5 9];
    params.Fs = dFs;
    
    S = [];
    for iCh = 1:length(lfpChannels)
        [sev,header] = read_tdt_sev(fullSevFiles{lfpChannels(iCh)});
        sev = decimate(double(sev),decimateFactor);
        sev = eegfilt(sev,header.Fs,[],hicutoff); % lowpass
        disp(['Computing sepctrogram for ch',num2str(lfpChannels(iCh)),'...']);
        [S1,t,f] = mtspecgramc(sev',movingwin,params);
        S(iCh,:,:) = 10*log10(abs(S1));
    end
    
    orderedEventsTs = orderAllNexTs(nexData);
    cue1 = false;
    cue2 = false;
    cue3 = false;
    cue4 = false;
    cue5 = false;
    nose1 = false;
    nose2 = false;
    nose3 = false;
    nose4 = false;
    nose5 = false;
    tone = false;
    food = false;
    foodport = false;
    houselight = false;
    gotrial = false;
    
    for iFrame=1:iFrameStart+5000 %video.NumberOfFrames
        curEphysTs = (1/video.FrameRate) * (iFrame-1) + behaviorStartTime;
        
        frame = rgb2gray(read(video,iFrame));
        frameEvents = orderedEventsTs(orderedEventsTs(:,2) >= curEphysTs - (1/video.FrameRate) &...
            orderedEventsTs(:,2) < curEphysTs + (1/video.FrameRate));
        
        hs = []; % subplot handles
        for iCh = 1:length(lfpChannels)
            hs(iCh) = subplot(length(lfpChannels)+1,1,iCh+1);
            if iFrameStart <= iFrame
                tRange = find(t >= curEphysTs - plotHalfWidthSec & t < curEphysTs + plotHalfWidthSec);
                imagesc(linspace(-plotHalfWidthSec,plotHalfWidthSec,length(tRange)),f,squeeze(S(iCh,tRange,:))');
                hold on;
                plot([0 0],[min(f) max(f)],'k','LineWidth',2);
            end
            set(gca,'YDir','normal');
            axis xy; 
            axis tight;
            colormap(hs(iCh),jet);
            caxis([-4.5 65]);
            ticklabelinside(hs(iCh));
        end
        
        for iCh = 1:length(lfpChannels)
            set(hs(iCh),'Units','pixels');
            bottomPos = (length(lfpChannels) - iCh) * subplotHeight;
            set(hs(iCh),'Position',[1 bottomPos ceil(video.Width/videoDimDivider) subplotHeight]);
        end
        
        hVid = subplot(length(lfpChannels)+1,1,1);
        set(hVid,'Units','pixels');
        imshow(frame,'border','tight');
        colormap(hVid,gray);
        hold on;
        set(hVid,'Position',[1 figureHeight-ceil(video.Height/videoDimDivider)...
            ceil(video.Width/videoDimDivider) ceil(video.Height/videoDimDivider)]);
        for iEvent=1:length(frameEvents)
            switch frameEvents(iEvent)
                case 1
                    cue1 = true;
                case 2
                    cue1 = false;
                case 3
                    cue2 = true;
                case 4
                    cue2 = false;
                case 5
                    cue3 = true;
                case 6
                    cue3 = false;
                case 7
                    cue4 = true;
                case 8
                    cue4 = false;
                case 9
                    cue5 = true;
                case 10
                    cue5 = false;
                case 11
                    houselight = true;
                case 12
                    houselight = false;
                case 13
                    food = true;
                case 14
                    food = false;
                case 17
                    nose1 = true;
                case 18
                    nose1 = false;
                case 19
                    nose2 = true;
                case 20
                    nose2 = false;
                case 21
                    nose3 = true;
                case 22
                    nose3 = false;
                case 23
                    nose4 = true;
                case 24
                    nose4 = false;
                case 25
                    nose5 = true;
                case 26
                    nose5 = false;
                case 27
                    foodport = true;
                case 28
                    foodport = false;
                case 33
                    tone = true;
                case 34
                    tone = false;
                case 39
                    gotrial = true;
                case 40
                    gotrial = false;
                otherwise
            end
        end
        
        markerLarge = 25;
        markerSmall = 15;
        markerColor1 = 'b';
        markerColor2 = 'r';
        lineWidth = 3;
        marker1 = 'o';
        marker2 = 'x';
        if cue1
            plot(hVid,xEventCoords(1),yEventCoords(1),marker1,'Color',markerColor1,'LineWidth',lineWidth,'MarkerSize',markerLarge);
        end
        if cue2
            plot(hVid,xEventCoords(2),yEventCoords(2),marker1,'Color',markerColor1,'LineWidth',lineWidth,'MarkerSize',markerLarge);
        end
        if cue3
            plot(hVid,xEventCoords(3),yEventCoords(3),marker1,'Color',markerColor1,'LineWidth',lineWidth,'MarkerSize',markerLarge);
        end
        if cue4
            plot(hVid,xEventCoords(4),yEventCoords(4),marker1,'Color',markerColor1,'LineWidth',lineWidth,'MarkerSize',markerLarge);
        end
        if cue5
            plot(hVid,xEventCoords(5),yEventCoords(5),marker1,'Color',markerColor1,'LineWidth',lineWidth,'MarkerSize',markerLarge);
        end

        if nose1
            plot(hVid,xEventCoords(1),yEventCoords(1),marker2,'Color',markerColor2,'LineWidth',lineWidth,'MarkerSize',markerSmall);
        end
        if nose2
            plot(hVid,xEventCoords(2),yEventCoords(2),marker2,'Color',markerColor2,'LineWidth',lineWidth,'MarkerSize',markerSmall);
        end
        if nose3
            plot(hVid,xEventCoords(3),yEventCoords(3),marker2,'Color',markerColor2,'LineWidth',lineWidth,'MarkerSize',markerSmall);
        end
        if nose4
            plot(hVid,xEventCoords(4),yEventCoords(4),marker2,'Color',markerColor2,'LineWidth',lineWidth,'MarkerSize',markerSmall);
        end
        if nose5
            plot(hVid,xEventCoords(5),yEventCoords(5),marker2,'Color',markerColor2,'LineWidth',lineWidth,'MarkerSize',markerSmall);
        end

        if foodport
            plot(hVid,xEventCoords(6),yEventCoords(6),marker2,'Color',markerColor2,'LineWidth',lineWidth,'MarkerSize',markerSmall);
        end
        if food
            plot(hVid,xEventCoords(6),yEventCoords(6),marker1,'Color',markerColor1,'LineWidth',lineWidth,'MarkerSize',markerLarge);
        end
        if houselight
            plot(hVid,xEventCoords(7),yEventCoords(7),marker1,'Color',markerColor1,'LineWidth',lineWidth,'MarkerSize',markerLarge);
        end

        figFrame = getframe(h);
        writeVideo(newVideo,figFrame);
    end
    
    close(newVideo);
    toc
end