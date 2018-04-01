function px2mm = openField_px2mm(filename,resizePx)
mmActual = sqrt(17^2+17^2) * 25.4; % 17x17 inch open field base
v = VideoReader(filename);
frame = readFrame(v);
frame_resize = imresize(frame,[resizePx NaN]);
figure;
imshow(frame_resize);
disp('click upper-left then bottom-right corner...');
[xs,ys] = ginput(2);
pxDist = pdist([xs,ys]);
px2mm = mmActual / pxDist;