function [LTS, nonLTS] = extractLTS(ts)

hp = .1; %hyperpolarization 100ms
minSpikes = 2; %minimum number of spikes per burst

xBursts = [0.0035 0.010 0.0200]; % experimentally determined
[burstEpochs,burstFreqs] = findBursts(ts,xBursts);

numSpikes = diff(burstEpochs,1,2);
burstEpochs(numSpikes < minSpikes, :) = [];

LTS = [];
nonLTS = [];

%First burst
first = burstEpochs(1,:);
if ts(first) > hp
    LTS = [first(1,1)];
else
    nonLTS = [first(1,1)];
end

rest = [burstEpochs(2:end,:)];

for ii = 2:length(rest)
    if (ts(rest(ii, 1))-ts(rest(ii-1, 2))) > hp
        LTS = [LTS rest(ii,1)];
    else
        nonLTS = [nonLTS rest(ii, 1)];
    end
end
