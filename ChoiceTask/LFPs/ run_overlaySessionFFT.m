subject__names = {'R0088','R0117','R0142','R0154','R0182'};
subject__files = {'/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch42.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0117/R0117-rawdata/R0117_20160504a/R0117_20160504a/R0117_20160504a_R0117_20160504a-2_data_ch93.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0142/R0142-rawdata/R0142_20161207a/R0142_20161207a/R0142_20161207a_R0142_20161207a-1_data_ch42.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154/R0154-rawdata/R0154_20170227a/R0154_20170227a/R0154_20170227a_R0154_20170227a-1_data_ch41.sev',...
    '/Users/mattgaidica/Documents/Data/ChoiceTask/R0182/R0182-rawdata/R0182_20170723a/R0182_20170723a/R0182_20170723a_R0182_20170723a-1_data_ch2.sev'};

all_A = [];
for iSubject = 1:numel(subject__names)
    sevFile = subject__files{iSubject};
    [sev, header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    [A,f] = simpleFFT(sevFilt(1e6:end),Fs,true);
    all_A(iSubject,:) = all_A;
end