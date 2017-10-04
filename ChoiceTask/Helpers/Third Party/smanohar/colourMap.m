function [ col ] = colourMap( index, maximum )
% colourMap(index, maximum) 
%   an easy and safe way to index into the colour palette.
%   Returns a colour from the current colour map. 
%   'index' should lie from 1 to  maximum.
% colourMap with no arguments:
%   sets the current figure's default line colours using the current
%   colormap, i.e. 
%   set(gcf,'DefaultAxesColorOrder', colormap)
% colourMap(maximum)
%   set the current figure's default line colours using the JET colourmap
%   from 1 to maximum. Also set the colormap.
% colourMap( palette )
%   set the line colours from the given palette
if ~exist('index','var')  % no arguments? set axes color order to color map
  set(gcf, 'DefaultAxesColorOrder', colormap);
  set(gca, 'ColorOrder', colormap);
elseif ~exist('maximum','var') % one argument:
  if isscalar(index) % scalar? create a default colormap with n lines
    if ~exist('othercolor','file') || 0 % Always use Jet palette?
      col = jet(index);
    else % use a random 'othercolor' palette
      col = othercolor( 1+floor(rand*404), index);
    end
    set(gcf, 'DefaultAxesColorOrder', col );
    set(gca, 'ColorOrder', col );
    colormap(col);
  elseif ismatrix(index) && size(index,2)==3 % is it a colourmap? just use that
    set(gcf, 'DefaultAxesColorOrder', index );
    set(gca, 'ColorOrder', index );
  end
else % two arguments: index and maximum for current colormap
  c=colormap;
  index=max(min(index,maximum),1); % force index into range 1:maximum
  ix = floor((size(colormap,1)-1) * (index-1)/maximum) +1; % index into colour palette
  col=c(ix,:);
end