% sevFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-rawdata/R0075_20150518a/R0075_20150518a/Unnamed_data_ch7.sev';
% [sev,header] = read_tdt_sev(sevFile);
% [b,a] = butter(4, [0.02 0.2]);
% fdata = filtfilt(b,a,double(sev));
% 
% nexFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/R0075_20150518a_T02_WL48_PL16_DT24.nex';
% tsCell = leventhalNexTs(nexFile);
% 
% ts = tsCell{1,2};
% [burstEpochs,burstFreqs] = findBursts(ts);

burstIdxs = burstEpochs(burstFreqs >= 191,:);
slowIdxs = burstEpochs(burstFreqs < 191,:);
% randomLocs = sort(datasample(min(burstLocs):max(burstLocs),length(burstLocs),'Replace',false));

figure('position',[100 100 800 400]);

hold on;
for ii=1:10:500
    plot(fdata(header.Fs*ts(slowIdxs(ii,1))-header.Fs/1000:header.Fs*ts(slowIdxs(ii,2))+header.Fs/1000),'r');
end

hold on;
for ii=1:10:500
    plot(fdata(header.Fs*ts(burstIdxs(ii,1))-header.Fs/1000:header.Fs*ts(burstIdxs(ii,2))+header.Fs/1000),'b');
end

grid on;