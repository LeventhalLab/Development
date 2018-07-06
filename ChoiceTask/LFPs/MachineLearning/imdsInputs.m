function [files,labels,labelsArr] = imdsInputs(allFiles,trainingIds,meanBinsSeconds,scramble)
    iidCount = 0;
    for iid = 1:numel(trainingIds)
        thisId = trainingIds(iid);
        thisXT = str2double(allFiles(thisId).name(16:19));
        if thisXT == 0
            continue;
        end
        iidCount = iidCount + 1;
% %         labelsArr(iidCount) = double(thisRT > longXT);
        labelsArr(iidCount) = sum(thisXT >= meanBinsSeconds*1000) - 1;
        files{iidCount} = fullfile(allFiles(thisId).folder,allFiles(thisId).name);
    end
    if scramble
        labelsArr = labelsArr(randperm(numel(labelsArr)));
    end
    labels = categorical(labelsArr);
end