function [varargout] = fminsearchs(fun, x0, N, varargin)
% fminsearchs( fun, x0, N, .... )
%
%   this dispatches multiple calls to a minimisation algorithm.
%   It can be used similar to fminsearch, 
%   except: x0 is a matrix [ x1_min x2_min x3_min ...
%                            x1_max x2_max x3_max ... ]
%   calls to fminsearch are repeated N times, each time using a random set of 
%   initial parameters, in the range x_min to x_max. N=10 default.
%
%   args can include: 'method', which can be one of
%     'fminsearch' : nelder-mead simplex search (default) 
%     'pattern'    : pattern search (optimisation toolbox)
%     'ga'         : genetic algorithm
%     'cmaes'      : covariance matrix adaptation / evolutionary strategy
%     'anneal'     : simulated annealing
%     which will run the corresponding minimisation algorithm instead of
%     fminsearch.
%
%   Hint: if you change line 26 to parfor 
%   the searches will run MUCH faster on multicores!
%
%   return [bestx, besty, all_best_x]
%   s g manohar
%
if isempty(x0) % no parameters!
  varargout{1}=x0(1,:); % special case: make sure it is a 1 x 0 matrix!
  varargout{2}=fun(x0(1,:));
  return
end

i=find(strcmpi(varargin, 'initial'));
if i>0
  P0 = varargin{i+1};
  varargin([i i+1])=[];
  if length(P0)~=size(x0,2)
    error('initial parameter vector must match parameter range vector!');
  end
else P0 = [];
end

i=find(strcmpi(varargin, 'method'));
if i>0
  METHOD = varargin{i+1};
  varargin([i i+1])=[];
else METHOD = 'fminsearch'
end
p0arg_override=[]; % initial parameters override - for genetic algorithm
switch METHOD
  case 'fminsearch'
    optimfunc = @fminsearch;
    args = varargin;
  case 'pattern'
    optimfunc = @patternsearch;
    args{5}=x0(1,:); % min
    args{6}=x0(2,:); % max
    args(8:8+length(varargin)-1) = varargin;
  case 'ga'
    optimfunc = @ga;
    p0arg_override=size(x0,2);
    args{5}=x0(1,:);
    args{6}=x0(2,:);
    args(8:8+length(varargin)-1) = varargin;
  case 'cmaes'
    optimfunc = @cmaes;
    args{1}=x0(1,:);
    args{2}=x0(2,:);
    args(3:3+length(varargin)-1) = varargin;
  case 'anneal'
    optimfunc = @(f,p)anneal(f,p,struct('MaxConsRej',10000,'MaxTries',10000,...
      'MaxSuccess',10000,'Verbosity',2, 'StopTemp',0.1, 'Generator',@(x) x+rand(size(x))*.5  ));
    args = varargin;
end


if ~exist('N','var'), N=10; end

bestx = repmat(mean(x0), N,1);  % keep track of best value for each iteration
besty = inf(N,1);
% CHANGE TO PARFOR if you have parallel toolbox
for i=1:N                    % run in parallel
  if isempty(P0)
    p0 = rand(1,size(x0,2)).*diff(x0)+x0(1,:); % hazard a starting guess
  else % if a speficied starting point, always use that.
    p0=P0;
  end
  if any(isnan(p0))
    warning('nan parameters for fminsearch')
    p0(isnan(p0))=0;
  end
  bestx(i,:) = p0;
  besty(i)   = fun(p0);  % check the function once at this starting value
  if ~isempty(p0arg_override) % in some functions, the p0 argument is different.
    p0 = p0arg_override;
  end
  if besty(i)<inf  % only continue with fminsearch if the cost is finite
    %[bestx(i,:) besty(i)] = fminsearch(fun, ... % now try minimisation
    %  p0, varargin{:});
    [ bestx(i,:) besty(i) ] = optimfunc( fun, p0, args{:} );
  end
end

[~,m] = min(besty); % index of best function

varargout{1}=bestx(m,:); % return values just like fminsearch would.
varargout{2}=besty(m);

varargout{3} = bestx;


