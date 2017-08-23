% prob z
% 0.90 1.645
% 0.95 1.96
% 0.98 2.326
% 0.99 2.576

zthresh = 2.7;

trialTypes = {'correctContra','correctIpsi'};
useEvents = 1:7;
tWindow = 1;
% [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
useSubjects = [88,117,142,154];

all_numSigEvents = [];
all_classSequenceStrings = {};
all_classSequenceCount = [];
maxz_mean = [];
nSequences = 1;
for iNeuron = 1:size(analysisConf.neurons,1)
    if isempty(unitEvents{iNeuron}.class) || ~ismember(sessionConf.subjects__id,useSubjects)
        continue;
    end
    maxz_ordered = unitEvents{iNeuron}.maxz(unitEvents{iNeuron}.class);
    if isempty(maxz_mean)
        maxz_mean = maxz_ordered;
    else
        maxz_mean = mean([maxz_mean;maxz_ordered]);
    end
    numSigEvents = sum(maxz_ordered >= zthresh);
    all_numSigEvents(iNeuron) = numSigEvents;
    if numSigEvents == 0
        continue;
    end
    unitClassSigEvents = unitEvents{iNeuron}.class(1:numSigEvents);
    
    if numel(unitClassSigEvents) > 1
%         unitClassSigEventsString = mat2str(sort(unitClassSigEvents));
        unitClassSigEventsString = mat2str(unitClassSigEvents);
        stringMatchIdxs = strcmp(all_classSequenceStrings,unitClassSigEventsString);
        if any(stringMatchIdxs)
            all_classSequenceCount(stringMatchIdxs) = all_classSequenceCount(stringMatchIdxs) + 1;
        else
            all_classSequenceStrings{nSequences} = unitClassSigEventsString;
            all_classSequenceCount(nSequences) = 1;
            nSequences = nSequences + 1;
        end
    end
end
figure;
hist(all_numSigEvents,[min(all_numSigEvents):max(all_numSigEvents)]);
title('Fraction of units vs. significant events');

figure;
plot(maxz_mean);
title('Mean of sequential events');

figure;
[v,k] = sort(all_classSequenceCount,'descend');
plot(v,'k.','MarkerSize',20);
xticks([1:numel(v)]);
xticklabels(all_classSequenceStrings(k));
xtickangle(90);
xlim([1 numel(find(v>1))]);
% ylim([0 7]);
grid on;