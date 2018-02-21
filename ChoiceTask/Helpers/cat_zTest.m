function [z,y,y2] = cat_zTest(p1,p2,n1,n2)

rho1 = p1/n1;
rho2 = p2/n2;
rhoDiff = rho1 - rho2;
rho = (p1 + p2) / (n1 + n2);
stdErr = sqrt(rho*(1-rho)*((1/n1)+(1/n2)));
z = rho / stdErr;

y = normpdf(z);
y2 = normpdf(z^2); % chi-square