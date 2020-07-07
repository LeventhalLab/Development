if ~exist('selectedLFPFiles')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'all_trials')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
    load('LFPfiles_local_matt.mat')
end
if doSetup
    iSession = 0;
    trialTimeRanges = NaN(1,2);
    trialCount = 1;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        trials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
%         trials = trials(trialIds); % only successful
        
        for iTrial = 1:numel(trials)
            if isfield(trials(iTrial).timestamps,'cueOn')
                trialTimeRanges(trialCount,1) = getfield(trials(iTrial).timestamps,'cueOn');
                if isfield(trials(iTrial).timestamps,'foodRetrieval')
                    trialTimeRanges(trialCount,2) = getfield(trials(iTrial).timestamps,'foodRetrieval');
                    trialCount = trialCount + 1;
                end
            end
        end
    end
end

me = mean(trialTimeRanges(:,2)-trialTimeRanges(:,1));
st = std(trialTimeRanges(:,2)-trialTimeRanges(:,1));
med = median(trialTimeRanges(:,2)-trialTimeRanges(:,1));

fprintf('in-trial mean: %1.3f, median: %1.3f, std: %1.3f\n',me,med,st);

intertrialTimes = [];
for ii = 1:size(trialTimeRanges,1)-1
    if trialTimeRanges(ii,2) < trialTimeRanges(ii+1,1)
        intertrialTimes = [intertrialTimes;trialTimeRanges(ii+1,1)-trialTimeRanges(ii,2)];
    end
end

close all
ff(1200,500);
subplot(121);
histogram(trialTimeRanges(:,2)-trialTimeRanges(:,1),1:2:200);
title('in-trial times');
ylabel('count');
xlabel('seconds');

subplot(122);
histogram(intertrialTimes,1:2:200);
title('inter-trial times');
ylabel('count');
xlabel('seconds');

fprintf('inter-trial mean: %1.3f, median: %1.3f, std: %1.3f\n',...
    mean(intertrialTimes),median(intertrialTimes),std(intertrialTimes));