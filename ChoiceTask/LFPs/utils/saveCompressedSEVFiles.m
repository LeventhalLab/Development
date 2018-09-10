load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/session_20180516_FinishedResubmission.mat', 'all_ts');
load('session_20180901_SpikePhaseAllFreq.mat', 'LFPfiles_local');
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16_despiked';
decimateFactor = 16;

for iNeuron = 1:numel(all_ts)
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    ts = all_ts{iNeuron};
    [sevDespiked,header] = despikeLFP(sevFile,ts);
    sevFilt = decimate(sevDespiked,decimateFactor);
    Fs = header.Fs / decimateFactor;
    save(fullfile(savePath,[name,'_u',num2str(iNeuron,'%03d'),'.mat']),'sevFilt','Fs','decimateFactor');
end