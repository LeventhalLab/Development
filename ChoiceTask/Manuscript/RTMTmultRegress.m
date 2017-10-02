validIdx = allTrial_useTime > .05;
x1 = allTrial_useTime(validIdx)'; % RT
x2 = allTrial_useTime2(validIdx)'; % MT
y = mean(allTrial_z(validIdx,20:21),2);
X = [ones(size(x1)) x1 x2 x1.*x2];
[b,bint,r,rint,stats] = regress(y,X)

figure;
scatter3(x1,x2,y,'filled')
hold on
x1fit = 0:.01:1;
x2fit = 0:.01:1;
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1) + b(2)*X1FIT + b(3)*X2FIT + b(4)*X1FIT.*X2FIT;
mesh(X1FIT,X2FIT,YFIT)
xlabel('RT')
ylabel('MT')
zlabel('Z @ t=0')
view(50,10)

% figure;
% mesh(x1,x2,y);
% xlabel('RT')
% ylabel('MT')
% zlabel('Z @ t=0')