function [x2,p] = chiSquare(a,b,c,d)
% https://www.youtube.com/watch?v=WXPBoFDqNVk&t=136s
% tests the null hypothesis that there is no difference between expected
% values a,b and observed values c,d.
% p > 0.01 confirms the null hypothesis; observations are random
% p < 0.01 rejects the null hypothesis; observations are dependent
x2 = (((c-a)^2)/a) + (((d-b)^2)/b);
p = chi2cdf(x2,1);