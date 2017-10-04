function p = wrapnormpdf (x, m, s)
% WRAPNORMPDF Wrapped normal probability density function (pdf)
%   Y = WRAPNORMPDF(THETA,MU,SIGMA) returns the pdf of the wrapped normal 
%   distribution with mean MU and standard deviation SIGMA, evaluated at 
%   the values in THETA (given in radians).

p = zeros(size(x));

rho = exp(- s^2 / 2);
if length(find(~isnan(x)))>0
    %fprintf([ num2str(nanmin(nanmin(x-m))) ':' num2str(nanmax(nanmax(x-m))) ',s' num2str(s) '\n']);

    i = 0;
    while (1)
        i=i+1;
    
        f = rho ^ (i^2) * cos(i * (x - m));        
        p = p + f;

        if nanmax(nanmax(abs(f)))<eps, break; end        
    end

    p = 1/(2*pi) * (1 + 2*p);
    fprintf('.');
end;

