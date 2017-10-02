function h = pa_regline(beta, style)
% PA_REGLINE(BETA)
%
% Plot regression line with parameters BETA through current axis.
%
% PA_REGLINE(...,'LineSpec') uses the color and linestyle specified by 
% the string 'LineSpec'. See PLOT for possibilities.
%
% H = PA_REGLINE(...) returns a vector of lineseries handles in H.
%
% For example:
%
% X		= rand(100,1);
% Y		= 2*X+3+randn(size(X));
% b		= regstats(Y,X);
% beta	= b.beta;
% 
% plot(X,Y,'k.');
% pa_regline(beta);
% 
%
% See also REFLINE, PA_HORLINE, PA_VERLINE, PA_UNITYLINE
%

% (c) 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com


%% Initialization
if nargin < 2, 
	style = 'k--'; 
end
if nargin < 1, 
	beta = [0 1]'; 
end

%% Axis
x_lim	= get(gca,'Xlim');
oldhold = ishold;
hold on

%% Data
X = [ones(size(x_lim))' x_lim'];
Y = X*beta;
h       = plot(x_lim, Y, style);

%% Return
if ~oldhold
	hold off;
end
