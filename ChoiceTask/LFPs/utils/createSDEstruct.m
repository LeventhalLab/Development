function [all_SDEs,all_MTs,all_RTs,all_trialIds] = createSDEstruct(all_trials,all_ts,eventFieldnames)

all_SDEs = {};

all_tsPeths = {};
all_MTs = {};
all_RTs = {};

tWindow = 2;
for iNeuron = 1:numel(all_ts)
    curTrials = all_trials{iNeuron};
    curTs = all_ts{iNeuron};
% %     trialIdInfo = organizeTrialsById(curTrials);
    [trialIdsMT,curMTs] = sortTrialsBy(curTrials,'MT');
    [trialIdsRT,curRTs] = sortTrialsBy(curTrials,'RT');
    % put MTs into order (use RT order as master for trials)
    rep_curMTs = [];
    for iTrial = 1:numel(trialIdsMT)
        rep_curMTs(find(trialIdsRT == trialIdsMT(iTrial))) = curMTs(iTrial);
    end
    curMTs = rep_curMTs;
    
    tWindow = 2;
    tsPeths = eventsPeth(curTrials(trialIdsRT),curTs,tWindow,eventFieldnames);
    
    SDEs = {};
    tWindow = 1;
    for iTrial = 1:size(tsPeths,1)
        for iEvent = 1:size(tsPeths,2)
            SDEs{iTrial,iEvent} = get_SDE(tsPeths{iTrial,iEvent},tWindow);
        end
    end
    
    all_MTs{iNeuron} = curMTs;
    all_RTs{iNeuron} = curRTs;
    all_tsPeths{iNeuron} = tsPeths; % need this?
    all_SDEs{iNeuron} = SDEs;
    all_trialIds{iNeuron} = trialIdsRT;
end

end

% attempting to keep settings self-contained
function s = get_SDE(ts,tWindow)

binWidth = .001; % 1ms
sigma = .020; % kernel std

binEdges = -tWindow:binWidth:tWindow;
counts = histcounts(ts,binEdges); % bin data
edges = [-3*sigma:binWidth:3*sigma]; % time ranges
kernel = normpdf(edges,0,sigma); % eval guassian kernel
kernel = kernel*binWidth; % multiply by bin width
sConv = conv(counts,kernel); % convolve

halfKernel = ceil(numel(edges)/2); % index of kernel center
s = sConv(halfKernel:halfKernel + numel(counts) - 1); % remove kernel smoothing from edges

end