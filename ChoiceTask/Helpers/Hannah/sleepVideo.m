% % v = VideoReader('R0088_20151101_19-20-11_compressed.m4v');
% % %Take every 20th frame
% % framesInterval = 20;
% % diffArray = [];
% % ii = 1;
% % 
% % %Go through frames and find difference in pixels
% % hWait = waitbar(0,'Analyzing Frames');
% % for f = 1 : framesInterval : v.NumberOfFrames - framesInterval
% %     waitbar(f/v.NumberOfFrames,hWait);
% %     %Read one frame
% %     curFrame = read(v, f);
% %     %Convert to B&W
% %     curFrame = im2bw(curFrame, .5);
% %     %Read next frame
% %     nextFrame = read(v, f + framesInterval);
% %     %Convert to B&W
% %     nextFrame = im2bw(nextFrame, .5);
% %     d = nextFrame - curFrame;
% %     %Get number of pixels that are different
% %     d = sum(d(:));
% %     %Store difference in array
% %     diffArray(ii) = d;
% %     ii = ii + 1;
% % end
% % close(hWait); clear('hWait');


%Create VideoWriter Object
newVideo = VideoWriter('file.avi', 'Motion JPEG AVI');
newVideo.Quality = 75;
newVideo.FrameRate = v.FrameRate;
open(newVideo);
t = linspace(0, length(diffArray) - 1, length(diffArray));
h = figure('Position',[0 0 600 600]);
ii = 1;
smoothDiffArray = smooth(abs(diffArray));
for f = 1 : framesInterval : v.NumberOfFrames - framesInterval
    %Read one frame
    curFrame = read(v, f);
    curFrame = imresize(curFrame, 1/3);
    hVid = subplot(2,1,1);
    set(hVid,'Units','pixels');
    imshow(curFrame,'border','tight');
%     colormap(hVid,gray);
    hold on;
    %Plot the difference array
    subplot(212);
    plot(t, smoothDiffArray)
    axis([0 500 0 2500])
    xlabel('Time (s)');
    hold on;
    if ii <= length(smoothDiffArray)
        plot(ii, smoothDiffArray(ii), '.', 'MarkerSize', 20)
        hold off;
        %set(hVid,'Position',[1 figureHeight-size(frame,1) size(frame,2) size(frame,1)]);
        figFrame = getframe(h);
        writeVideo(newVideo, figFrame);
        ii = ii + 1;
    end
end

close(h);
close(newVideo)


