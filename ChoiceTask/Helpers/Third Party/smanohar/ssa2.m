% Contents:
% ssa.m - SSA shell: calls ssaeig, pc, and rc.
% ssaeig.m - Calculates SSA eigenvectors/values (calls ac.m).
% ac.m - Estimates the autocovariance function.
% pc.m - Calculates PCs for SSA.
% rc.m - Calculates RCs for SSA.
% ssaconf.m - Calculates variance estimates for eigenvalues.
% itc.m - Uses information theoretic criteria to estimate signal/noise cutoff.
% mesa.m - Calculates maximum entropy spectra using the Burg algorithm.
%
%-------------------------- Begin ssa.m -------------------------------------
  function [E,V,A,R]=ssa(x, M) 
%  Syntax: [E,V,A,R]=ssa(x, M);
%  This function performs an SSA of series 'x', for embedding dimension 'M'.
%  Returns:  E - eigenfunction (T-EOF) matrix in standard form
%            V - vector containing variances (unnormalized eigenvalues)
%            A - Matrix of principal components
%            R - Matrix of reconstructed components
%
%  See Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.     Version date 5/22/95
%  Please send comments and suggestions to eric@gi.alaska.edu   

[E,V]=ssaeig(x,M);
[A]=pc(x,E);
[R]=rc(A,E);
%-------------------------- End ssa.m------------------------------------------

%-------------------------- Begin ssaeig.m ------------------------------------
  function [E,V]=ssaeig(x, M)
%  Syntax: [E,V]=ssaeig(x, M);  
%  This function starts an SSA of series 'x', for embedding dimension 'M'.
%  Returns:    E - eigenfunction matrix in standard form
%                  (columns are the eigenvectors, or T-EOFs)
%              V - vector containing variances (unnormalized eigenvalues)
%  E and V are ordered from large to small.
%  See section 2 of Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.    Version date 5/22/95
%  Please send comments and suggestions to eric@gi.alaska.edu   

[N,col]=size(x);                
if col>N, x=x'; [N,col]=size(x); end   % change x to column vector if needed
if M-1>=N, error('Hey! Too big a lag!'), end
if col>=2, error('Hey! Vectors only!'), end

c=ac(x, M-1);          % calculate autocovariance estimates
T=toeplitz(c);         % create Toeplitz matrix (trajectory matrix)
[E,L]=eig(T);          % calculate eigenvectors, values of T
V=sum(L);              % create eigenvalue vector
[V,ind]=sort(V);       % sort eigenvalues
V=V(M:-1:1);
ind=ind(M:-1:1);  
E=E(:,ind);            % sort eigenvectors
%-------------------------- End ssaeig.m --------------------------------------

%-------------------------- Begin ac.m ----------------------------------------
function  c=ac(x,k,bias)
%    Syntax c=ac(x,k);  c=ac(x,k,'biased');  
%    Ac calculates the auto-covariance for series 
%  x out to k lags. The result is output in c, which 
%  has k+1 elements. The first element is the covariance at lag zero;
%  succeeding elements 2:k+1 are the covariances at lags 1 to k.
%  Bias can be either:   'biased'       (Yule-Walker)  
%                        'unbiased'     The default is 'unbiased'.
%  If you want the autocorrelation rather than the autocovariance, just
%  call c=ac(x/std(x), lag).
%
%  Written by Eric Breitenberger.   Version date 5/17/95
%  Please send comments and suggestions to eric@gi.alaska.edu   
 
[N,col]=size(x);
if col>N, x=x'; [N,col]=size(x); end
if k>=N, error('Hey! Too big a lag!'), end
if col>=2, error('Hey! Vectors only!'), end
x=x-nanmean(x);
c=zeros(1,k+1);

if nargin==2, 
  for i=1:k+1
    c(i)=nansum(x(1:N-i+1).*x(i:N));
    c(i)=c(i)/(N-i+1);
  end
elseif nargin==3,
  for i=1:k+1
    c(i)=nansum(x(1:N-i+1).*x(i:N));
    if strcmp(bias,'unbiased'), c(i)=c(i)./(N-i+1); 
    elseif strcmp(bias,'biased'), c(i)=c(i)./N;
    else, error('Bias incorrectly specified!'), end 
  end
end
%-------------------------- End ac.m ------------------------------------------

%-------------------------- Begin pc.m ----------------------------------------
  function [A]=pc(x, E)
%        Syntax: [A]=pc(x, E); 
%  This function calculates the principal components of the series x
%  from the eigenfunction matrix E, which is output from ssaeig.m
%  Returns:      A - principal components matrix (N-M+1 x M)
%  See section 2.4 of Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.    Version date 5/20/95
%  Please send comments and suggestions to eric@gi.alaska.edu   

[N,col]=size(x);
if min(N,col)>1, error('x must be a vector.'), end
if col>1, x=x'; N=col; end     % convert x to column if necessary.
x=x-nanmean(x);
[M,c]=size(E);                
if M~=c, error('E is improperly dimensioned'), end
A=zeros(N-M+1,M);
for i=1:N-M+1;                 
  w=x(i:i+M-1);          
  A(i,:)=w'*E;
end
%-------------------------- End pc.m ------------------------------------------

%-------------------------- Begin rc.m ----------------------------------------
  function [R]=rc(A,E)
% Syntax: [R]=rc(A,E);
% This function calculates the 'reconstructed components' using the 
% eigenvectors (E, from ssaeig.m) and principal components (A, from pc.m).
% R is N x M, where M is the embedding dimension used in ssaeig.m.
%
% See section 2.5 of Vautard, Yiou, and Ghil, Physica D 58, 95-126, 1992.
%
%  Written by Eric Breitenberger.   Version date 5/18/95
%  Please send comments and suggestions to eric@gi.alaska.edu   

[M,c]=size(E);
[ra, ca]=size(A);
if M~=c, error('E is improperly dimensioned.'),end
if ca~=M, error('A is improperly dimensioned.'),end
N=ra+M-1;  % Assumes A has N-M+1 rows.

R=zeros(N,M);
Z=zeros(M-1,M);
A=[A' Z'];
A=A';


% Calculate RCs
for k=1:M
  R(:,k)=filter(E(:,k),M,A(:,k));
end

% Adjust first M-1 rows and last M-1 rows
for i=1:M-1
  R(i,:)=R(i,:)*(M/i);
  R(N-i+1,:)=R(N-i+1,:)*(M/i);
end
%-------------------------- End rc.m ------------------------------------------

%-------------------------- Begin ssaconf.m -----------------------------------
function [f,g,v]=ssaconf(V,N)
% Calculates various heuristic confidence limits for SSA.
% Syntax: [f,g,v]=ssaconf(V,N);
% Given a singular value vector V and the number of points
% in the original series N, ssaconf returns vectors containing
% the 95% confidence interval. These are calculated according 
% to the variance formulas of:
%     f: Fraedrich 1986
%     g: Ghil and Mo 1991a
%     v: Vautard, Yiou, and Ghil 1992.
% All estimates are for the 95% confidence level.
% These simple estimates may be adequate for some purposes,
% but none of them adequately consider the autocorrelation 
% of the time series. The estimates g and v are very similar
% for N>>M. They are usually fairly conservative, as they
% correspond to a decorrelation time of M. The Fraedrich
% estimate is valid only for uncorrelated data, so it tends  
% to give error estimates which are too small.
%
% Written by Eric Breitenberger, version date 11/3/95.
% Please send comments to eric@gi.alaska.edu

M=length(V);
f=2*sqrt(2/N)*V;
g=sqrt(2*M/(N-M))*V;
v=1.96*sqrt(M/(2*N))*V;
%-------------------------- End ssaconf.m -------------------------------------

%-------------------------- Begin itc.m ---------------------------------------
function [kaic,kmdl,aic,mdl]=itc(V,n);
% Syntax: [kaic,kmdl,aic,mdl]=itc(V,n);
% Compute signal/noise separation using information-theoretic
% criteria. Two estimates are returned: the Akaike 
% information-theoretic criterion (AIC), and the minimum
% description length (MDL). The order for which AIC or MDL is
% minimum gives the number of significant components in the 
% signal. The two methods often give considerably different 
% results: AIC usually performs better than MDL in low SNR
% situations, but MDL is a consistent estimator, and thus 
% performs better in large-sample situations.
%
% See Wax and Kailath, 1985, Trans. IEEE, ASSP-33, 387-392.
%
% Input:   V: an eigenspectrum (sorted in decreasing order)
%          n: the number of samples used to compute V.
% Outputs: kaic: the order for which AIC is minimum;
%          kmdl: the order for which MDL is minimum;
%          aic: vector containing AIC estimates;
%          mdl: vector containing MDL estimates.
%
% Written by Eric Breitenberger, version 10/4/95, please send 
% any comments and suggestions to eric@gi.alaska.edu

p=length(V);
V=V(p:-1:1);

% Calculate log-likelihood function:
L=zeros(1,p);
nrm=p:-1:1;
sumlog=cumsum(log(V));
sumlog=sumlog(p:-1:1);
logsum=log(cumsum(V));
logsum=logsum(p:-1:1);

L=n*nrm.*((sumlog./nrm)-logsum+log(nrm));

% Calculate penalty function:
pen=(0:p-1);
pen=pen.*(2*p-pen);

% Calculate AIC and MDL, and find minima:
aic=-L+pen;
mdl=-L+pen*log(n)/2;
kaic=find(aic==min(aic))-1;
kmdl=find(mdl==min(mdl))-1;
%-------------------------- End itc.m -----------------------------------------

%-------------------------- Begin mesa.m ---------------------------------------
  function [p] = mesa(x,m,nfreq)
% SYNTAX: p = mesa(x,m,nfreq);
% For a vector x, this function calculates a maximum-entropy spectrum
% of order m. The spectral estimate is returned in the vector p, which
% has nfreq points linearly spaced in the Nyquist frequency interval 0-.5.
% The psd is normalized such that the mean square value of x equals the
% integral of p from -.5 to .5, so sum(x.^2)/N ~= sum(p)/nfreq.
% Mesa is based on the Burg algorithm, as described in Numerical Recipes
% and implemented in their memcof and evlmem subroutines.
%
% Written by Eric Breitenberger        Version 5/24/95 
% Please send comments and suggestions to eric@gi.alaska.edu 

if min(size(x))>1, error('Row or column vectors only!'), end
[n,c]=size(x);
if c>n, x=x'; n=c; end  % x is now a column vector of size n
x=x-mean(x);  % center the series

% set up workspace column vectors
wk1=zeros(n,1);
wk2=zeros(n,1);
wk3=zeros(n,1);
wkm=zeros(m,1);
ak=zeros(m,1);

% initialize
a0=sum(x.^2)/n;
wk1(1)=x(1);
wk2(n-1)=x(n);
wk1(2:n-1)=x(2:n-1);
wk2(1:n-2)=x(2:n-1);

% Now calculate a0 and ak via recursion
for k=1:m
  pneum=0;
  denom=0;
  pneum=sum(wk1(1:n-k).*wk2(1:n-k));
  denom=sum(wk1(1:n-k).^2+wk2(1:n-k).^2);
  ak(k)=2.*pneum/denom;
  a0=a0*(1.-ak(k).^2);
  if k>1 
    ak(1:k-1)=wkm(1:k-1)-ak(k)*wkm(k-1:-1:1);
  end
  if k==m, break, end
  wkm(1:k)=ak(1:k);
  wk3=wk1;
  wk1(1:n-k-1)=wk1(1:n-k-1)-wkm(k)*wk2(1:n-k-1);
  wk2(1:n-k-1)=wk2(2:n-k)-wkm(k)*wk3(2:n-k);
end

% The coefficients a0 and ak have been calculated, now use these
% to evaluate the psd at nfreq frequencies (eqn. 12.8.4 Num. Rec.).
% By changing how p is initialized, the spacing in f can be changed.
% For example, one could use logspace instead of linspace.

p=2*pi*linspace(0,.5,nfreq);
fc=cos(p);
fs=sin(p);
lc=ones(1,nfreq);     % initialize 'last' cosine and sine
ls=zeros(1,nfreq);
temp=zeros(1,nfreq);
sc=ones(1,nfreq);     % initialize sum of cosine and sine terms
ss=zeros(1,nfreq);

% This next loop can be vectorized but memory use goes way up for only 
% a small improvement in speed.
for k=1:m
  temp=lc;
  lc=lc.*fc - ls.*fs;
  ls=ls.*fc + temp.*fs;
  sc=sc-ak(k).*lc;
  ss=ss-ak(k).*ls;
end
p=a0./(sc.^2 + ss.^2);
%-------------------------- End mesa.m -----------------------------------------
