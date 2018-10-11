function [meanPower, stdPower] = calc_trialLFP_stats(LFP, trials, freqList, Fs, tWindow)
% calculate mean and standard deviation of LFP power during trials for full
% session

% assumes correct trials for now
numSamps = round(tWindow * Fs);
scaloData = zeros(length(trials),numSamps*2 + 1);
for iTr = 1 : length(trials)
    
    trialStart = trials(iTr).timestamps.tone - tWindow;
    trialStartSamp = round(trialStart * Fs);
    trialSamps = trialStartSamp : trialStartSamp + numSamps*2;
    
    scaloData(iTr,:) = LFP(trialSamps);
    
end

[W, ~] = calculateComplexScalograms_EnMasse(scaloData,'Fs',Fs,'freqList',freqList,'doplot',false);
LFPpower = abs(W(:)).^2;

meanPower = mean(LFPpower);
stdPower = std(LFPpower);