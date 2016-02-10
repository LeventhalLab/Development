function sleepVideo(vFileName, smoothDiffArray, filename)
% Function to create a video file with rat and plot of activity
% Input: 
%   v - VideoReader object
%   diffArray - output from getFrameDiff
%   filename - the name of the video being created
v = VideoReader(vFileName);
framesInterval = 20;
thresh = 400;
smoothFactor = .2;

%Create VideoWriter Object
newVideo = VideoWriter(filename, 'Motion JPEG AVI');
newVideo.Quality = 75;
newVideo.FrameRate = v.FrameRate;
open(newVideo);
t = linspace(0, length(smoothDiffArray) - 1, length(smoothDiffArray));
threshArray = zeros(1, length(t)) + thresh;
h = figure('Position',[0 0 600 600]);
ii = 1;
for f = 1 : framesInterval : v.NumberOfFrames - framesInterval
    %Read one frame
    curFrame = read(v, f);
%    curFrame = imresize(curFrame, 1/3);
    hVid = subplot(2,1,1);
    set(hVid,'Units','pixels');
    imshow(curFrame,'border','tight');
%     colormap(hVid,gray);
    hold on;
    %Plot the difference array
    subplot(212);
    plot(t, smoothDiffArray)
    hold on;
    plot(t, threshArray, '--')
    ylim([0 2500])
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


