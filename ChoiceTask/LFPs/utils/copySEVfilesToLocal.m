destinationPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles';
LFPfiles_local = {};
for iFile = 1:numel(LFPfiles)
    [~,name,ext] = fileparts(LFPfiles{iFile});
    destinationFullfile = fullfile(destinationPath,[name,ext]);
    LFPfiles_local{iFile} = destinationFullfile;
    disp(destinationFullfile);
    if ~exist(destinationFullfile)
        copyfile(LFPfiles{iFile},destinationFullfile);
    end
end

% or use
% % sourcePath = '/Volumes/Gaidica3TB/Data/LFPs/LFPfiles';
% % destPath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles';
% % 
% % for iNeuron = selectedLFPFiles'
% %     [~,name,~] = fileparts(LFPfiles_local{iNeuron});
% %     copyfile(fullfile(sourcePath,[name,'.sev']),fullfile(destPath,[name,'.sev']));
% %     disp(num2str(iNeuron));
% %     disp(name);
% % end