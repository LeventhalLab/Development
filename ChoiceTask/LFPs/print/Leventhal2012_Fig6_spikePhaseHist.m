
medianMult = 6;

for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};

    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT'); % curTrials(trialIds)
end