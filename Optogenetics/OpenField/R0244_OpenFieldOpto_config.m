powerList = logFreqList([1 30],5); % for reference
fiberEfficiency = 7/8.9;
requiredPower = powerList ./ fiberEfficiency;

% found empirically using rig
Vos = [0.00;1.70;2.00;2.80;3.60;4.50]; 
nRounds = 5;
Vos_rounds = repmat(Vos,[nRounds,1]);
Vos_rounds_rand = Vos_rounds(randperm(length(Vos_rounds)));
[v,k] = sort(Vos_rounds_rand);

stimIds = [];
ii = 0;
for iVos = 1:numel(Vos)
    for iRounds = 1:nRounds
        ii = ii + 1;
        stimIds(k(ii),1) = iVos;
    end
end
open stimIds
open Vos_rounds_rand

% check
figure;
plot(Vos_rounds_rand);
hold on;
plot(sort(Vos_rounds_rand));