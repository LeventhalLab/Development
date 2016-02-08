function [diffArray] = getFrameDiff(videoFileName)
% Function to get the diffArray for a rat video
% Input: 
%   videoFileName - rat video file to analyze
% Output: 
%   diffArray - array of differences between pixels

v = VideoReader(videoFileName);
%Take every 20th frame
framesInterval = 20;
diffArray = [];
ii = 1;
 
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
% t = linspace(0, length(diffArray) - 1, length(diffArray));
% a = zeros(1, length(t));
% a = a + 400;
% smoothDiffArray = smooth(abs(diffArray), .2);
% plot(t, smoothDiffArray)
% hold on;
% plot(t, a, '--')
% axis([0 500 0 2500])

end