if doSetup
    iSession = 0;
    trialTimeRanges = NaN(1,2);
    trialCount = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        trials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        trials = trials(trialIds); % only successful
        
        for iTrial = 1:numel(trials)
            if isfield(trials(iTrial).timestamps,'cueOn')
                trialCount = trialCount + 1;
                trialTimeRanges(trialCount,1) = getfield(trials(iTrial).timestamps,'cueOn');
                if isfield(trials(iTrial).timestamps,'foodRetrieval')
                    trialTimeRanges(trialCount,2) = getfield(trials(iTrial).timestamps,'foodRetrieval');
                end
            end
        end
    end
end

me = mean(trialTimeRanges(:,2)-trialTimeRanges(:,1));
st = std(trialTimeRanges(:,2)-trialTimeRanges(:,1));
med = median(trialTimeRanges(:,2)-trialTimeRanges(:,1));

fprintf('mean: %1.3f, median: %1.3f, std: %1.3f\n',me,med,st);

figure;
histogram(trialTimeRanges(:,2)-trialTimeRanges(:,1),1:0.5:10)