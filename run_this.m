workingDir = '/Users/matt/Documents/Data/ChoiceTask/LFPs/surrogates/rawdata';
iSession = 0;
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,~,~,~,compressedPath] = loadCompressedSEV(sevFile,[]);
    [~,name,ext] = fileparts(compressedPath);
    copyfile(compressedPath,fullfile(workingDir,sprintf('session%02d_%s%s',iSession,name,ext)));
end
