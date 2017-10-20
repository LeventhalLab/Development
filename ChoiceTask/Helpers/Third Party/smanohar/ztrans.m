function zt = ztrans(x, zrange)
% z-transform of a time series
% return a z-plane ranging from -zrange to +zrange (default -5 to +5)
% sgm 2017
if ~exist('zrange','var')
  zrange=5;
end

zR = bsxfun(@plus, ...
          linspace(-zrange,zrange,100), ...
       1j*linspace(-zrange,zrange,100)' ...
     );
% ZT(z)  =  sum_n ( x(n) * z^-n )

zt = ...
  sum( ...
       bsxfun(@times, ...
          bsxfun(@power, ...
             zR,...
             -permute(1:length(x),[1,3,2]) ...
          ), ...
          permute(x,[2,3,1])...
       ), ...
  3);