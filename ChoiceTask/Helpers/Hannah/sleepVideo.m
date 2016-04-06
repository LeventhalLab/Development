function [sleepEpochs, smoothDiffArray] = sleepVideo(inputFile,outputFile)
% Function to create a video file with rat and plot of activity
% Input: 
%   inputFile - path of sleep video to be analyzed
%   outputFile - path where output video should go with new name
% Output:
%   sleepEpochs - 2D matrix with start and end times of sleep in seconds
%   smoothDiffArray - array of differences between pixels


v = VideoReader(inputFile);
%Read every 40th frame
framesInterval = 40;
diffArray = [];
ii = 1;
smoothFactor = .2;
sleepEpochStart = [];
sleepEpochEnd = [];
%Threshold for sleep
thresh = 390;
 
%Go through frames and find difference in pixels
hWait = waitbar(0,'Analyzing Frames');
for f = 1 : framesInterval : v.NumberOfFrames - framesInterval
    waitbar(f/v.NumberOfFrames,hWait);
    %Read one frame
    curFrame = read(v, f);
    %Convert to B&W
    curFrame = im2bw(curFrame, .5);
    %Read next frame
    nextFrame = read(v, f + framesInterval);
    %Convert to B&W
    nextFrame = im2bw(nextFrame, .5);
    d = nextFrame - curFrame;
    %Get number of pixels that are different
    d = sum(d(:));
    %Store difference in array
    diffArray(ii) = d;
    ii = ii + 1;
end
close(hWait); clear('hWait');

%Smooth the array
smoothDiffArray = smooth(abs(diffArray), smoothFactor);

%Find sleep epochs from smoothDiffArray
for jj = 2:length(smoothDiffArray) - 1
    %If an element is greater than or equal to the thresh and next element
    %is less than thresh, that is the start of an epoch
    if smoothDiffArray(jj) >= thresh && smoothDiffArray(jj + 1) < thresh
        sleepEpochStart = [sleepEpochStart jj];
    %If an element is less than the thresh and the next element is
    %greater than or equal to the thresh, that is the end of an epoch
    elseif smoothDiffArray(jj) < thresh && smoothDiffArray(jj + 1) >= thresh
        sleepEpochEnd = [sleepEpochEnd jj];
    else
    end
end

%Fix issue if there is an element right at the end that goes below thresh
if length(sleepEpochStart) > length(sleepEpochEnd)
    l = length(sleepEpochStart) - length(sleepEpochEnd);
    L = zeros(1, l);
    L = L + length(smoothDiffArray);
    sleepEpochEnd = [sleepEpochEnd L];
end 

sleepEpochs = [sleepEpochStart; sleepEpochEnd];

%Put sleepEpochs in seconds
sleepEpochs = sleepEpochs.*framesInterval./v.FrameRate;

%Create VideoWriter Object
newVideo = VideoWriter(outputFile);
newVideo.Quality = 75;
newVideo.FrameRate = v.FrameRate;
open(newVideo);

%Time array for plot
t = linspace(0, length(smoothDiffArray) - 1, length(smoothDiffArray));
threshArray = zeros(1, length(t)) + thresh;
h = figure('Position',[0 0 600 600]);
ii = 1;

%Create new video
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
%    ylim([0 2500])
    xlabel('Time (s)');
    hold on;
    %Plot the marker on the graph
    if ii <= length(smoothDiffArray)
        plot(ii, smoothDiffArray(ii), '.', 'MarkerSize', 20)
        hold off;
        %set(hVid,'Position',[1 figureHeight-size(frame,1) size(frame,2) size(frame,1)]);
        figFrame = getframe(h);
        writeVideo(newVideo, figFrame);
        clf(h);
        ii = ii + 1;
    end
end

close(h);
close(newVideo)


