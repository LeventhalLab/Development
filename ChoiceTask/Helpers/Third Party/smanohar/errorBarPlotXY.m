function errorBarPlotXY(x,y, varargin)
% function errorBarPlotXY(x,y, varargin)
%    x ( subject, x_groups, z_groups )
%    y ( subject, x_groups, z_groups )
% plots y against x scatter with standard errorbars on each point
% with a different line for each z value.
% uses nanmean and nanstd, and calls errorbarxy.
% 
% sgm

mx = sq(nanmean(x));
my = sq(nanmean(y));
sx = sq(nanstd(x))/sqrt(size(x,1)); % standard error
sy = sq(nanstd(y))/sqrt(size(y,1));
prvhold = ishold();
nz=size(x,3); % how many z groups?
if nz>1
  for i=1:nz % plot each line separately, use colour map
    errorbarxy(mx(:,i),my(:,i),sx(:,i),sy(:,i), [],[], colourMap(i,nz));
    hold on
  end
  if ~prvhold
    hold off
  end
else % only one line: use varargin to determine colours etc
  errorbarxy(mx,my,sx,sy, [],[], varargin{:});
end