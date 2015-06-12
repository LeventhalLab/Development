function lfpVideo(sessionConf,nexData,lfpChannels)
    % get video
    leventhalPaths = buildLeventhalPaths(sessionConf);
    videos = dir(fullfile(leventhalPaths.rawdata,'*.avi'));
    if isempty(videos)
        error('novideo');
    end
    video = VideoReader(fullfile(leventhalPaths.rawdata,videos(1).name));
    
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
    plotHalfWidthSample = round(plotHalfWidthSec * sessionConf.Fs);
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
    
    smoothdata = [];
    for iCh = 1:length(lfpChannels)
        [sev,header] = read_tdt_sev(fullSevFiles{lfpChannels(iCh)});
        sev = decimate(double(sev(1:1e6)),decimateFactor);
        smoothdata(iCh,:) = eegfilt(sev,header.Fs,[],hicutoff); % lowpass
    end
        
    for iFrame=iFrameStart:iFrameStart+10%video.NumberOfFrames
        curEphysTs = (1/video.FrameRate) * iFrame - behaviorStartTime;
        curEphysSample = round(curEphysTs * dFs);
        sampleRange = curEphysSample - round(plotHalfWidthSample/decimateFactor) + 1:curEphysSample + round(plotHalfWidthSample/decimateFactor);
        frame = read(video,iFrame);
        hVid = subplot(length(lfpChannels)+1,1,1);
        set(hVid,'Units','pixels');
        imshow(frame,'border','tight');
        
        hs = []; % subplot handles
        for iCh = 1:length(lfpChannels)
            hs(iCh) = subplot(length(lfpChannels)+1,1,iCh+1);
            
            [S1,t,f] = mtspecgramc(smoothdata(iCh,sampleRange)',movingwin,params);
            sLog = 10*log10(abs(S1));
            tAdj = t - plotHalfWidthSec;
          
            imagesc(tAdj,f,sLog');
            hold on;
            plot([0 0],[min(f) max(f)],'k','LineWidth',2);
            set(gca,'YDir','normal');
            axis xy; 
            axis tight;
            colormap('jet');
            caxis([-4.5 65]);
            ticklabelinside(hs(iCh));
        end
        
        for iCh = 1:length(lfpChannels)
            set(hs(iCh),'Units','pixels');
            bottomPos = (length(lfpChannels) - iCh) * subplotHeight;
            set(hs(iCh),'Position',[1 bottomPos ceil(video.Width/videoDimDivider) subplotHeight]);
        end
        
        set(hVid,'Position',[1 figureHeight-ceil(video.Height/videoDimDivider)...
            ceil(video.Width/videoDimDivider) ceil(video.Height/videoDimDivider)]);
        
        figFrame = getframe(h);
        writeVideo(newVideo,figFrame);
    end
    
    close(newVideo);
end

function h = subplottight(n,m,i)
    [c,r] = ind2sub([m n], i);
    ax = subplot('Position', [(c-1)/m, 1-(r)/n, 1/m, 1/n]);
    if(nargout > 0)
      h = ax;
    end
end