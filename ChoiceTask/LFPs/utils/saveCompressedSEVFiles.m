load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/session_20180516_FinishedResubmission.mat', 'all_ts');
load('session_20180901_SpikePhaseAllFreq.mat', 'LFPfiles_local');
LFPPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles';
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16_despiked';
sevFiles = dir(fullfile(LFPPath,'*.sev'));
decimateFactor = 16;

% % for iFile = 1:numel(sevFiles)
% %     sevFile = fullfile(LFPPath,sevFiles(iFile).name);
% %     [sev,header] = read_tdt_sev(sevFile);
% %     sevFilt = decimate(double(sev),decimateFactor);
% %     Fs = header.Fs / decimateFactor;
% %     save(fullfile(savePath,[sevFiles(iFile).name,'.mat']),'sevFilt','Fs','decimateFactor');
% % end

% get x's

for iFile = selectedLFPFiles'
    % get SEV file and data
    sevFile = fullfile(LFPPath,sevFiles(iFile).name);
    [sev,header] = read_tdt_sev(sevFile);
    % loop algorithm to smartly replace timestamps
    sevDespiked = double(sev);
    for iTs = 3%find(strcmp(LFPfiles_local,sevFile))
        ts = all_ts{iTs};
        [sevDespiked] = despikeLFP(sevDespiked,header,ts);
    end
    % despike SEV data
    sevFilt = decimate(sevDespiked,decimateFactor);
    Fs = header.Fs / decimateFactor;
    save(fullfile(savePath,[sevFiles(iFile).name,'.mat']),'sevFilt','Fs','decimateFactor');
end


