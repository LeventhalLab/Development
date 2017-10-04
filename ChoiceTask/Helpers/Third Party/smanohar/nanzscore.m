function Z=nanzscore(X)
%  Z = nanzscore (X)
%  Z = ( X - nanmean(X) ) / nanstd( X )
%      with singleton expansion
% i.e. 
%    = bsxfun(@rdivide, bsxfun(@minus, X, nanmean(X,1)), 
%                       nanstd(X, [], 1));
% sgm
Z = bsxfun(@rdivide, bsxfun(@minus, X, nanmean(X,1)), nanstd(X, [], 1));

if isempty(Z) return; end
% allow some constant columns
badcolumns = all(isnan(Z));
if any(badcolumns)
  warning('input to nanzscore contains constant columns - ignored');
  Z(:,badcolumns) = X(:,badcolumns);
end
