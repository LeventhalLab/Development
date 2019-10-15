load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles');
load('LFPfiles_local_matt');

savePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/x16_filt';
decimateFactor = 16;

for iNeuron = selectedLFPFiles(1)'
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    [sev,header] = read_tdt_sev(sevFile);
% %     sevButter = butterme(double(sev),header.Fs,[1 600]);
    smoothdata = eegfilt(double(sev),header.Fs,0.5,600);
    sevFilt = decimate(sevButter,decimateFactor);
    Fs = header.Fs / decimateFactor;
    save(fullfile(savePath,[name,'_u',num2str(iNeuron,'%03d'),'.mat']),'sevFilt','Fs','decimateFactor');
end