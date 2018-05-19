function all_SDEs_zscore = convertSDEsToZscore(all_SDEs)
% in previous methods we used cue-2s:cue, here we just use cue-1s:cue+1s
refEvent = 1;

all_SDEs_zscore = {};
for iNeuron = 1:numel(all_SDEs)
    curSDEs = all_SDEs{iNeuron};
    refData = reshape([curSDEs{:,refEvent}],[size(curSDEs,1) size(curSDEs{1,1},2)]);
    refData_single = mean(refData);
    refMean = mean(refData_single);
    refStd = mean(refMean);
    
    SDEs_zscore = [];
    for iTrial = 1:size(curSDEs,1)
        for iEvent = 1:size(curSDEs,2)
            SDEs_zscore{iTrial,iEvent} = (curSDEs{iTrial,iEvent} - refMean) / refStd;
        end
    end
    all_SDEs_zscore{iNeuron} = SDEs_zscore;
end