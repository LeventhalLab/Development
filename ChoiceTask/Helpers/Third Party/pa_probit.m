function chi = pa_probit(cdf)
% CHI = PA_PROBIT(CDF)
%
% The probit function is the quantile function, i.e., the inverse
% cumulative distribution function (CDF), associated with the standard
% normal distribution. 
%
% This is useful for plotting reaction times.
%

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

myerf       = 2*cdf - 1;
myerfinv    = sqrt(2)*erfinv(myerf);
chi         = myerfinv;