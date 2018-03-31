powerList = logFreqList([1 30],5); % for reference
fiberEfficiency = 7/8.9;
requiredPower = powerList ./ fiberEfficiency;

% found empirically using rig
Vos = [1.85000000000000;2.05000000000000;2.55000000000000;3.15000000000000;4.05000000000000]; 
nRounds = 5;
Vos_rounds = repmat(Vos,[nRounds,1]);
Vos_rounds_rand = Vos_rounds(randperm(length(Vos_rounds)));

% check
figure;
plot(Vos_rounds_rand);
hold on;
plot(sort(Vos_rounds_rand));