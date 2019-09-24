if ~exist('all_ts')
    load('session_20180919_NakamuraMRL.mat', 'all_ts')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
end
load('LFPfiles_local_matt');
savePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16_allTs_despiked';
decimateFactor = 16;

waveformBounds = 1; % ms

for iNeuron = selectedLFPFiles'
    sevFile = LFPfiles_local{iNeuron};
    sessionName = analysisConf.sessionNames{iNeuron};
    sameSessions = find(strcmp(analysisConf.sessionNames,sessionName));
    compiled_ts = [];
    for sessId = sameSessions'
        compiled_ts = [compiled_ts;all_ts{sessId}];
    end
    [sevDespiked,header] = despikeLFP(sevFile,compiled_ts,waveformBounds);
    sevFilt = decimate(sevDespiked,decimateFactor);
    Fs = header.Fs / decimateFactor;
    
    [~,name,~] = fileparts(sevFile);
    save(fullfile(savePath,['x16ads_',name,'.sev.mat']),'sevFilt','Fs','decimateFactor');
    
    disp(num2str(iNeuron));
end