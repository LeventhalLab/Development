iSession = 0;
calcRT = [];
sessNum = [];
trialNum = [];
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    curTrials = all_trials{iNeuron};
    for iTrial = 1:numel(curTrials)
        if isfield(curTrials(iTrial).timestamps,'tone') && isfield(curTrials(iTrial).timestamps,'centerOut')
            calcRT = [calcRT curTrials(iTrial).timestamps.centerOut - curTrials(iTrial).timestamps.tone];
            sessNum = [sessNum iSession];
            trialNum = [trialNum iTrial];
        end
    end
end
clc
idxs = find(calcRT > 1);
for idx = idxs
    disp([num2str(sessNum(idx)),' ',num2str(trialNum(idx)),' - RT ',num2str(calcRT(idx),3)]);
end