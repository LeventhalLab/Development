v = VideoReader('R0088_20151101_19-20-11_compressed.m4v');
%Take every 20th frame
frames = 20;
numFrames = v.NumberOfFrames;
difference = [];
jj = 1;

%Go through frames and find difference in pixels
for f = 1 : frames : numFrames - frames
    %Read one frame
    video = read(v, f);
    %Convert to B&W
    bw = im2bw(video, .5);
    %Read next frame
    video2 = read(v, f + frames);
    %Convert to B&W
    bw2 = im2bw(video2, .5);
    d = bw2 - bw;
    %Get number of pixels that are different
    d = sum(d);
    d = sum(d);
    d = sum(d);
    %Store difference in array
    difference(jj) = d;
    jj = jj + 1;
end


v1 = VideoReader('R0088_20151101_19-20-11_compressed.m4v');
ii = 1;
%Create VideoWriter Object
newVideo = VideoWriter('file.avi', 'Motion JPEG AVI');
newVideo.Quality = 75;
newVideo.FrameRate = v1.FrameRate;
open(newVideo);
k = 0;
x = linspace(0, length(difference) - 1, length(difference));
z = smooth(abs(difference));
%Read through frames
while hasFrame(v1)
   frame = readFrame(v1);
   frame = imresize(frame, 1/3);
   %Only take every 20th frame
   if mod(k, 20) == 0   
       %Display video
       hVid = subplot(2,1,1);
       set(hVid,'Units','pixels');
       imshow(frame,'border','tight');
       colormap(hVid,gray);
       hold on;
       %Plot the difference array
        subplot(212);
        plot(x, z)
        axis([0 500 0 2500])
        xlabel('Time (s)');
        hold on;
        %Plot the point corresponding to the video time
        plot(ii, z(ii), '.', 'MarkerSize', 20)
        hold off;
        figFrame = getframe;
        writeVideo(newVideo, figFrame);
        ii = ii + 1;
   end
   k = k + 1;
   
end
close(newVideo)


