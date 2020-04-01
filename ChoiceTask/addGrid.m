% imPath = '/Users/matt/Documents/MATLAB/mypalim_text.png';
% Y = imread(imPath);
% function addGrid(Y,newmap,rows,cols)
rows = 7;
cols = 5;
lw = 2;

xs = linspace(1,size(Y,1),rows);
ys = linspace(1,size(Y,2),cols);

% close all
figure;
imshow(Y,newmap);
% imshow(Y);
set(gcf,'position',[0,0,800,800]);
hold on;
for ii = 1:numel(xs) % rows
    plot([1,size(Y,2)],[xs(ii),xs(ii)],'k','linewidth',lw);
end
for ii = 1:numel(ys) % rows
    plot([ys(ii),ys(ii)],[1,size(Y,1)],'k','linewidth',lw);
end

for ii = 1:numel(xs)-1
    for jj = 1:numel(ys)-1
        text(ys(jj),xs(ii),[char(ii+64) char(48+jj)],'color','r','fontsize',16)
    end
end