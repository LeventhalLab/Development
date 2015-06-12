function lfpVideo(sessionConf,nexData,lfpChannels)
    % get video
    leventhalPaths = buildLeventhalPaths(sessionConf);
    videos = dir(fullfile(leventhalPaths.rawdata,'*.avi'));
    if isempty(videos)
        error('novideo');
    end
    video = VideoReader(fullfile(leventhalPaths.rawdata,videos(1).name));

    plotHalfWidth = 2; % seconds
    behaviorStartTime = getBehaviorStartTime(nexData);
    iFrameStart = ceil((plotHalfWidth + behaviorStartTime) * video.FrameRate);
    
    figureHeight = 800; % pixels
    videoDimDivider = 3;
    figure('Position',[0 0 ceil(video.Width/videoDimDivider) figureHeight]);
    for iFrame=iFrameStart:video.NumberOfFrames
        curEphysTs = (1/video.FrameRate) * iFrame - behaviorStartTime;
        curEphysSample = round(curEphysTs * sessionConf.Fs);
        frame = read(video,iFrame);
        hVid = subplot(length(lfpChannels)+1,1,1);
        set(hVid,'Units','pixels');
        imshow(frame,'border','tight');
        
        hs = []; % subplot handles
        f = 1:80;
        window = round(header.Fs*.5);
        overlap = [];
        for iCh = 1:length(lfpChannels)
            [s,f,t] = spectrogram(sev(5e6:1e7),window,overlap,f,header.Fs);
            hs(iCh) = subplot(length(lfpChannels)+1,1,iCh+1);
        end
        
        set(hVid,'Position',[1 figureHeight-ceil(video.Height/videoDimDivider)...
            ceil(video.Width/videoDimDivider) ceil(video.Height/videoDimDivider)]);
        disp('here');
    end
end

function h = subplottight(n,m,i)
    [c,r] = ind2sub([m n], i);
    ax = subplot('Position', [(c-1)/m, 1-(r)/n, 1/m, 1/n]);
    if(nargout > 0)
      h = ax;
    end
end