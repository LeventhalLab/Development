t = linspace(0,10,1000);
a = sin(t);
b = cos(t*2 + 5);
figure
plot(a);
hold on;
plot(b);

[R,P] = corr(a',b')