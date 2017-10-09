% from: http://www.neural-code.com/index.php/tutorials/action/reaction-time/83-reciprobit-distribution
%% Histogram
rt = all_rt(all_rt > .1)*1000;
x  = 0:50:1000; % reaction time bins (ms)
N  = histcounts(rt,x);  % count reactions in bin
N  = 100*N./sum(N); % percentage

figure; % #1 graphics
h  = bar(x(2:end),N); % histogram/bar plot
% Making figure nicer to look at
set(h,'FaceColor',[.7 .7 .7]); % setting the color of the bars to gray
box off; % remove the "box" around the graph
axis square;
xlabel('Reaction time (ms)'); % and setting labels is essential for anyone to understand graphs!
ylabel('Probability (%)');
xlim([0 1000]);

% And test it with a one-sample kolmogorov-smirnov test
% Since this test compares with the normal distribution, we have to
% normalize the data, which we can do with zscore, which is the same as: 
% z = (x-mean(x))/std(x)

% % [h,p]  = kstest(zscore(rt)); % for reaction time
% % if h
% %   str    = ['The null hypothesis that the reaction time distribution is Gaussian distributed is rejected, with P = ' num2str(p)];
% % else
% %   str    = ['The null hypothesis that the reaction time distribution is Gaussian distributed is NOT rejected, with P = ' num2str(p)];
% % end
% % disp(str); % display the results in command window
% % [h,p]  = kstest(zscore(rtinv)); % for inverse reaction time
% % if h
% %   str    = ['The null hypothesis that the inverse reaction time distribution is Gaussian distributed is rejected, with P = ' num2str(p)];
% % else
% %   str    = ['The null hypothesis that the inverse reaction time distribution is Gaussian distributed is NOT rejected, with P = ' num2str(p)];
% % end
% % disp(str); % display the results in command window

%% Inverse reaction time
rtinv  = 1./rt; % inverse reaction time / promptness (ms-1)
 
n    = numel(x); % number of bins in reaction time plot
x = linspace(1/2000,0.01,n); % promptness bins
N    = histcounts(rtinv,x);
N    = 100*N./sum(N);
 
figure; % #2
h = bar(x(2:end)*1000,N);
hold on
set(h,'FaceColor',[.7 .7 .7]);
box off
axis square;
xlabel('Promptness (s^{-1})');
ylabel('Probability (%)');
title('Reciprocal time axis');
 
% Does this look like a Gaussian?
% Let's plot a Gaussian curve with mean and standard deviation from the
% promptness data
mu  = mean(rtinv);
sd  = std(rtinv);
y  = normpdf(x,mu,sd);
y  = y./sum(y)*100;
plot(x*1000,y,'ks-','LineWidth',2,'MarkerFaceColor','w');

%% Cumulative probability
% Normalized scale and nicer shape
x = sort(1000*rtinv);
n = numel(rtinv); % number of data points
y = 100*(1:n)./n; % cumulative probability for every data point
figure; % #3
plot(x,y,'k.');
hold on
 
% Now, plot it cumulative probability in quantiles
% this is easier to compare between different distributions
% % p    = [2 5 10 20 50 80 90 95 98 99]/100; % some arbitrary probabilities
p = round(linspace(1,100,20))/100;
q    = quantile(rtinv,p); % instead of hist, let's use quantiles
 
h = plot(q*1000,p*100,'ko','LineWidth',2,'MarkerFaceColor','r');
hold on
xlabel('Promptness (s^{-1})');
ylabel('Cumulative probability (%)');
title('Cumulative probability plot');
box off
axis square;
xlim([0 15]);
legend(h,'Quantiles','Location','SE');


cdf     = q;
myerf       = 2*cdf - 1;
myerfinv    = sqrt(2)*erfinv(myerf);
chi         = myerfinv;

%% Probit
figure; % #4
% raw data
x = -1./sort((rt)); % multiply by -1 to mirror abscissa
n = numel(rtinv); % number of data points
y = pa_probit((1:n)./n); % cumulative probability for every data point converted to probit scale
plot(x,y,'k.');
hold on
 
% quantiles
probit  = pa_probit(p);
q    = quantile(rt,p);
q    = -1./q;
xtick  = sort(-1./(150+[0 pa_oct2bw(50,-1:5)])); % some arbitrary xticks
 
plot(q,probit,'ko','Color','k','MarkerFaceColor','r','LineWidth',2);
hold on
set(gca,'XTick',xtick,'XTickLabel',-1./xtick);
xlim([min(xtick) max(xtick)]);
set(gca,'YTick',probit,'YTickLabel',p*100);
ylim([pa_probit(0.1/100) pa_probit(99.9/100)]);
axis square;
box off
xlabel('Reaction time (ms)');
ylabel('Cumulative probability');
title('Probit ordinate');
 
% this should be a straight line
x = q;
y = probit;
b = regstats(y,x);
h = pa_regline(b.beta,'k-');
set(h,'Color','r','LineWidth',2);
