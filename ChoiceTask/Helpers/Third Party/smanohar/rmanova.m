function [ A, model ] = rmanova(T, varnames, varargin)
% [  ANOVA , model ] = rmanova( T, varnames )
%   T is either a N-dimensional array (factorial form data), 
%      or an N-column matrix (long-form data).
%     column/dimension 1 is subject 
%     column/dimension N is the data (dependent variable)
%     other colulmns are factors / predictors.
% Extra parmeters are passed to fitgmle, e.g. 'covariancepattern'. 
% to do a pure ANOVA, use 'CovariancePattern','CompSymm'.
% 
% returns: model = glme object with parameters and AIC
%          A     = anova table for F-tests of categorical variables.
%  -- requires fitglme (Matlab 2015 or later)
% sgm 2017

% which random effects to model?
RE = enum({'FACTORIAL','INTERCEPT'});
re = RE.INTERCEPT;


NOCATEG = true; % prevent categoricalising factor variables?

if ndims(T)>2
  T=dePivot(T);
  if exist('varnames','var') &&  length(varnames) == size(T,2)-1 % have they omitted the dependent var name?
    varnames{end+1}='y';
  end
end

T(:,[2:end-1]) = nanzscore(T(:,[2:end-1])); % zscore the factor columns
constcol = find(nanvar(T)==0); % any constant columns?
if any(constcol)
  warning('Intercept present by default, so constant terms removed');
  T(:,constcol)=[];
end


if ~iscell(varnames) || length(varnames)==0
  % default variable names
  varnames = ['subject', arrayfun(@(i)sprintf('factor%g',i),1:size(T,2)-2,'uni',0), 'y'];
end


subs=unique(T(:,1)); % get first column: subjects
if length(subs)<3 || length(subs)>100 ||  ~all(unique(diff(subs))==1)
  % is it all integers, at least 2?
  error('first column/dimension should be subjects')
end



t = array2table(T,'variablenames',varnames);
vn = t.Properties.VariableNames;
for j=1:length(vn)
  uj = unique(t.(vn{j}));
  if length(uj)>1 && length(uj)<=8 && (j==1 || ~NOCATEG) % is it categorical?
    t.(vn{j}) = categorical(t.(vn{j}));
    if j~=1
      warning('treating %s as categorical',vn{j});
    end
  end
end
factorial = varnames(2:end-1); % build the factorial design with vars 2:N-1
factorial = flat( [factorial; [repmat({'*'},1,length(factorial)-1), ' ']] );
switch re
  case RE.FACTORIAL
    reparams = [factorial{:}]; % all random effects included
  case RE.INTERCEPT
    reparams  = '1'; % random intercept only
end
% build the model string
model = [ varnames{end}  ' ~ ' factorial{:} ' + ( ' reparams ' | ' varnames{1} ')' ];
if length(unique(T(:,end))) == 2 % dependent variable is binomial?  do logistic regression instead
  warning('using logistic regression');
  varargin = [varargin 'link','logit','distribution','binomial']
end
%%%%%%%%%%%%% Actually fit the model here %%%%%%%%%%%%%%%  
model = fitglme(t,model, varargin{:});
A = anova(model);

