x = unique(sort(all_rt));
figure;
plot(x);
hold on;
for ii = 1:numel(qx_intercepts)
    idx = find(x >= qx_intercepts(ii),1);
    plot(idx,x(idx),'ro');
end

y = 1:numel(y);
x = unique(sort(all_rt));
figure;
plot(x,y);

[fitresult, gof] = curive_smoothingSpline(x,y);
figure;
xx = linspace(0,1,numel(y));
plot(xx,fitresult(xx));

pp = spline(x,y);
figure;
yyaxis left;
fnplt(pp)
hold on
plot(x,y,'o');
yyaxis right;
ppd2 = fnder(pp,2);
fnplt(ppd2);


y2 = smooth(y,200)';
y2d2 = diff(y2,2);
figure;
plot(1:numel(y),y);
hold on;
plot(1:numel(y2),y2);

figure;
plot(1:numel(y2d2),y2d2);


slm = slmengine(x,y2,'plot','on');

figure;
ppd2 = fnder(pp,2);
fnplt(ppd2)
grid on

% % pp = spline(x,y);
% % fnplt(pp)
% % hold on
% % plot(x,y,'o')
% % 
% % ppd2 = fnder(pp,2);
% % fnplt(ppd2)