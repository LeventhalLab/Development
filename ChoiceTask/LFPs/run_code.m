dataPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/datastore/Ray_LFPspikeCorr';

loadedFile = [];
neuronCount = 0;
for iNeuron = 1:366
    neuronCount = neuronCount + 1;
    unitLookup(neuronCount) = iNeuron;
%     load(fullfile(dataPath,['zSDE_u',num2str(iNeuron,'%03d')]),'zSDE');
    load(fullfile(dataPath,['tsPeths_u',num2str(iNeuron,'%03d')]),'tsPeths');
    LFPfile = fullfile(dataPath,['Wz_power_s',num2str(LFP_lookup(iNeuron),'%03d')]);
    if isempty(loadedFile) || ~strcmp(loadedFile,LFPfile)
        load(LFPfile,'Wz_power');
    end
    
    if size(Wz_power,3) ~= size(tsPeths,1)
        fprintf('--> issue with u%03d\n',iNeuron);
    else
        fprintf('no issue with u%03d\n',iNeuron);
    end
end