load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/session_20180516_FinishedResubmission.mat', 'all_ts');
load('session_20180901_SpikePhaseAllFreq.mat', 'LFPfiles_local');
% savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16_despiked';
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16';
decimateFactor = 16;

for iNeuron = 1:numel(all_ts)
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    ts = all_ts{iNeuron};
    [sevDespiked,header] = despikeLFP(sevFile,ts,waveformBounds(iNeuron,:));
    sevFilt = decimate(sevDespiked,decimateFactor);
    Fs = header.Fs / decimateFactor;
    save(fullfile(savePath,[name,'_u',num2str(iNeuron,'%03d'),'.mat']),'sevFilt','Fs','decimateFactor');
end

% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles/R0117_20160510a_R0117_20160510a-3_data_ch118.sev';
% [~,name,~] = fileparts(sevFile);
% [sev,header] = read_tdt_sev(sevFile);
% sevFilt = decimate(double(sev),decimateFactor);
% Fs = header.Fs / decimateFactor;
% save(fullfile(savePath,[name,'sev.mat']),'sevFilt','Fs','decimateFactor');

