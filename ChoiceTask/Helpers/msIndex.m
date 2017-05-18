function [mi,si] = msIndex(zscore)
% [ ] normalize output somehow (to whole session values?), standardize area
% under curve?
mi = 0.5 * trapz(abs(diff(zscore)));
si = trapz(abs(zscore)) - mi;

% figure;
% plot(zscore,'linewidth',2);
% hold on;
% plot(abs((zscore)));
% plot(abs(diff(zscore)));
% legend('z','abs(z)','abs(diff(z))');