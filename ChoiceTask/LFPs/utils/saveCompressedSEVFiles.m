LFPPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles';
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16';
sevFiles = dir(fullfile(LFPPath,'*.sev'));
decimateFactor = 16;
for iFile = 1:numel(sevFiles)
    sevFile = fullfile(LFPPath,sevFiles(iFile).name);
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    save(fullfile(savePath,[sevFiles(iFile).name,'.mat']),'sevFilt','Fs','decimateFactor');
end