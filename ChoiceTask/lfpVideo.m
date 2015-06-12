function lfpVideo(sessionConf,nexData,lfpChannels)
    % get video
    leventhalPaths = buildLeventhalPaths(sessionConf);
    videos = dir(fullfile(leventhalPaths.rawdata,'*.avi'));
    if isempty(videos)
        error('novideo');
    end
    video = VideoReader(fullfile(leventhalPaths.rawdata,videos(1).name));

    plotHalfWidthSec = 4; % seconds
    plotHalfWidthSample = plotHalfWidthSec * sessionConf.Fs;
    behaviorStartTime = getBehaviorStartTime(nexData);
    iFrameStart = ceil((plotHalfWidthSec + behaviorStartTime) * video.FrameRate);
    
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    
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
        hicutoff = 500;
        decmiateFactor = 10;% floor((sessionConf.Fs/2) / hicutoff);
        window = round((sessionConf.Fs/decmiateFactor)*.1);
        overlap = [];
%         overlap = window/10;
        for iCh = 1:length(lfpChannels)
            [sev,header] = read_tdt_sev(fullSevFiles{lfpChannels(iCh)});
            data = sev(curEphysSample-plotHalfWidthSample+1:curEphysSample+plotHalfWidthSample);
            smoothdata = eegfilt(data,header.Fs,[],hicutoff); % lowpass
            smoothdata = decimate(smoothdata,decmiateFactor);
            [s,f,t] = spectrogram(smoothdata,window,overlap,f,header.Fs/decmiateFactor);
            sLog = 10*log10(abs(s));
            hs(iCh) = subplot(length(lfpChannels)+1,1,iCh+1);
            
            
%             movingwin=[0.5 0.05];
%             params.fpass = [0 80];
%             params.tapers = [5 9];
%             params.Fs = sessionConf.Fs/decmiateFactor;
%             [S1,t,f] = mtspecgramc(smoothdata',movingwin,params);
%             sLog = 10*log10(abs(S1));
%             
            imagesc(t,f,sLog);
            set(gca,'YDir','normal');
            axis xy; 
            axis tight;
            colormap('jet');
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