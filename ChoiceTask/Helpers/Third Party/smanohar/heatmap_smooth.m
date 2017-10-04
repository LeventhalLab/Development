function [h, c]=heatmap(X,varargin)
%   heatmap( XY )
%   heatmap( X, Y )
%   heatmap( X, Y, [ ngridX, ngridY ] )
%   heatmap( X, ... )
% 
% convenience function to call 
%   contourf( hist3( X ) )
% plot heatmap of paired X,Y data. 
% extra arguments passed to contourf
% sgm 2014

if isvector(X) && nargin>1 && all(size(varargin{1})==size(X))
  X=[X varargin{1}]; 
  varargin(1)=[];
end
[KERNEL D SM plotargs] =parsepvpairs({
  'kernel','windows','smooth','plotargs' },{
  'gauss',  [] ,  [] , {}}, varargin{:});

if isscalar(D) 
  if isscalar(D), D=[D D]; end
else
  D = [1 1] * floor(sqrt(length(X))); 
end
if isempty(SM), SM=floor(D(1)/10);end;

% KERNEL = 'gauss'; % smoothing kernel
% WINDOWS = 15;  % number of windows per line, for smoothing
% SM = floor(D/WINDOWS); 

[h , c]= hist3(X,D); 
if SM
  switch KERNEL
    case 'gauss'
      lin    = linspace(-2.2,2.2,SM(1))';
      kernel = exp(-bsxfun(@plus, lin.^2, lin'.^2));
      kernel = kernel./sum(kernel(:));
    case 'flat'
      kernel = ones(SM); 
  end
  h = conv2(h,kernel,'same');
end
contourf(h,plotargs{:},'edgecolor','none');
  