sevFile = '';
freqList = 20;
timingField = 'RT';

for iNeuron = 1%:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    disp(num2str(iNeuron));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};
    [W,freqList,allTimes,LFP] = getW(sevFile,curTrials,eventFieldnames,freqList,timingField);
end