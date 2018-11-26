t1 = linspace(0,100,100); % 1Hz
t2 = linspace(0,100,400); % 4Hz

d1 = sin(t1);
d2 = cos(t2);
d1new = equalVectors(d1,d2);

markerSize = 10;
lineWidth = 2;
colors = lines(2);
ff(1400,700);
subplot(311);
plot(t1,d1,'lineWidth',lineWidth,'color',colors(1,:));
hold on;
plot(t2,d2,'lineWidth',lineWidth,'color',colors(lineWidth,:));
plot(t1,d1,'k.','markerSize',markerSize);
plot(t2,d2,'k.','markerSize',markerSize);
xlim([0 100]);
ylim([-1 1]);
xlabel('Time');
ylabel('f(t)');
legend({'d1','d2'});
ffp();
title({'1-D Interpolation using equalVectors',''});

subplot(312);
plot(d1,'lineWidth',lineWidth,'color',colors(1,:));
hold on;
plot(d2,'lineWidth',lineWidth,'color',colors(lineWidth,:));
plot(d1,'k.','markerSize',markerSize);
plot(d2,'k.','markerSize',markerSize);
xlim([0 numel(d2)]);
ylim([-1 1]);
xlabel('Samples');
ylabel('f(t)');
legend({'d1','d2'});
ffp();

subplot(313);
plot(d1new,'lineWidth',lineWidth,'color',colors(1,:));
hold on;
plot(d2,'lineWidth',lineWidth,'color',colors(lineWidth,:));
plot(d1new,'k.','markerSize',markerSize);
plot(d2,'k.','markerSize',markerSize);
xlim([0 numel(d2)]);
ylim([-1 1]);
xlabel('Samples');
ylabel('f(t)');
legend({'d1','d1new'});
ffp();
tightfig;