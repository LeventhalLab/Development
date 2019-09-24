sourcePath = '/Volumes/Gaidica3TB/Data/LFPs/LFPfiles';
destPath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles';

for iNeuron = selectedLFPFiles'
    [~,name,~] = fileparts(LFPfiles_local{iNeuron});
    copyfile(fullfile(sourcePath,[name,'.sev']),fullfile(destPath,[name,'.sev']));
    disp(num2str(iNeuron));
    disp(name);
end