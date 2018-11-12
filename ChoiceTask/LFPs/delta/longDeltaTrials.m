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

% % 1 98 - RT 1.32
% % 1 122 - RT 1
% % 2 63 - RT 1.04
% % 2 119 - RT 1.05
% % 5 2 - RT 1.17
% % 5 34 - RT 5.01
% % 5 37 - RT 2.74
% % 5 52 - RT 1.12
% % 7 31 - RT 1.04
% % 7 112 - RT 1.79
% % 8 45 - RT 1.49
% % 8 60 - RT 1.5
% % 8 70 - RT 1.53
% % 8 84 - RT 1.06
% % 9 37 - RT 2.25
% % 10 62 - RT 2.65
% % 10 75 - RT 1.69
% % 10 81 - RT 2.29
% % 10 91 - RT 1.52
% % 10 97 - RT 2.23
% % 10 110 - RT 1.88
% % 10 117 - RT 1.36
% % 15 6 - RT 1
% % 30 24 - RT 1.07
% % 30 31 - RT 1.56