if ~exist('all_ts')
    load('session_20180919_NakamuraMRL.mat', 'all_ts');
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles');
    load('session_20180901_SpikePhaseAllFreq.mat', 'analysisConf');
end
load('LFPfiles_local_matt');
savePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16_allTs_despiked';
decimateFactor = 10;

waveformBounds = 1; % ms

for iNeuron = selectedLFPFiles(1)'
    sevFile = LFPfiles_local{iNeuron};
    neuronName = analysisConf.neurons{iNeuron};
    sessionName = analysisConf.sessionNames{iNeuron};
    sameSessions = find(strcmp(analysisConf.sessionNames,sessionName));
    sameNeurons = [];
    for sessId = sameSessions'
        thisNeuron = analysisConf.neurons{sessId};
        if strcmp(neuronName(1:end-1),thisNeuron(1:end-1))
            sameNeurons = [sameNeurons;sessId];
        end
    end
    compiled_ts = [];
    for neuronId = sameNeurons'
        compiled_ts = [compiled_ts;all_ts{sessId}];
    end
    [sevDespiked,header] = despikeLFP(sevFile,compiled_ts,waveformBounds);
    sevFilt = decimate(sevDespiked,decimateFactor);
    Fs = header.Fs / decimateFactor;
    
    [~,name,~] = fileparts(sevFile);
    save(fullfile(savePath,['x16ads_',name,'.sev.mat']),'sevFilt','Fs','decimateFactor');
    
    disp(num2str(iNeuron));
end