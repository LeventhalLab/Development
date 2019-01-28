Wz_phase = linspace(-pi,pi,1000);

tsPeths = [rand(300,1) - 0.5];
counts = logical(histcounts(tsPeths,linspace(-0.5,0.5,1001)));
close all
figure;
plot(counts)

figure;
plot(Wz_phase(counts));