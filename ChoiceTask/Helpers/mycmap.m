function colors = mycmap(filename,varargin)
% read image
A = imread(filename);
% set number of elements to return
n = size(A,2);
if ~isempty(varargin)
    n = varargin{1};
end
% create colors (cmap)
colors = double(squeeze(imresize(A,[1,n]))) ./ 255;