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