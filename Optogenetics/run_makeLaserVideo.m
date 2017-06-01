% save('session_20170526_videoParams','video_20msALLs_pulse_binary','video_20msALLs_pulse_ts','video_20msSTARTs_pulse_binary','video_20msSTARTs_pulse_ts','all_tsPeth');

% videoFile = '/Users/mattgaidica/Desktop/R0181_052517_480p.mov';
% video = VideoReader(videoFile);

saveFile = '/Users/mattgaidica/Desktop/R0181_20170525_cylinder1-laserRasters5sOnOff50Hz_ch1357.avi';
doVideo = true;

if doVideo
    newVideo = VideoWriter(saveFile,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 30;
    open(newVideo);
end

protocolStartFrames = 16526:300:19226;
% protocolStartFrames = 432+1500:300:3132+1500;
% pulseStartIdxs = 1:251:2512-251;
pulseInt = 251;
pulseStartIdxs = 1:pulseInt:numel(all_tsPeth);

h1 = figure('position',[0 0 1300 800]);
set(gcf,'color','w');
for iPulse = 1:10
    if iPulse <= 5
        subplot(4,5,iPulse+5);
        hold on;
    else
        subplot(4,5,iPulse+10);
        hold on;
    end
    plotSpikeRaster(all_tsPeth(pulseStartIdxs(iPulse):pulseStartIdxs(iPulse)+pulseInt));
    xlim([-pethWindow pethWindow]);
    title(['Pulse ',num2str(iPulse)]);
end

pulseInc = pulseInt/300;
histMarker = 1;
for iFrame = 1:300 % 300 frames / 30 frames per second = 10 seconds
    for iPulse = 1:10
        frameNumber = protocolStartFrames(iPulse) + iFrame - 1;
        im = read(video,frameNumber);
        im = imcrop(im,[208 118 180 159]);
        
        laserTitle = 'laser off';
        markerColor = [.7 .7 .7];
        histMarker = pulseInc * iFrame;
        if histMarker < 125
            laserTitle = 'laser on';
            markerColor = [0 0 1];
        end
        
        if iPulse <= 5
            subplot(4,5,iPulse+5);
        else
            subplot(4,5,iPulse+10);
        end
        hold on;
        plot(-pethWindow,histMarker,'.','markerSize',20,'color',markerColor);
        
        if iPulse <= 5
            subplot(4,5,iPulse);
        else
            subplot(4,5,iPulse+5);
        end
        imshow(im);
        
        title([laserTitle,', fr ',num2str(frameNumber),', t ',num2str((iFrame-1)/30,'%1.2f')]);
    end
    drawnow;
    if doVideo
        imgcf = frame2im(getframe(gcf));
        writeVideo(newVideo,imgcf);
    end
end

if doVideo
    close(newVideo);
    close(h1);
end