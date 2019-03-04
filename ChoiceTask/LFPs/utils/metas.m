% function fileLoc = metas(h,savePath,saveFile,metaComment)
% https://www.mathworks.com/matlabcentral/fileexchange/42000-run_exiftool
frame = getframe(h);
im = frame2im(frame);
imwrite(im,'test.png','png','Comment','Hello, world!');