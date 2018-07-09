allFiles = dir(fullfile('/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/MachineLearning/trainingData-500msRT','*.jpg')); % u364_e7_t094_RT0687_id18291

for iFile = 1:numel(allFiles)
    if ismember(str2num(allFiles(iFile).name(2:4)),selectedLFPFiles)
        copyfile(fullfile(allFiles(iFile).folder,allFiles(iFile).name),...
            fullfile('/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/MachineLearning/trainingData-500msRTsel',allFiles(iFile).name));
    end
end